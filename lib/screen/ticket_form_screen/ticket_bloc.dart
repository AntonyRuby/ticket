// ticket_bloc.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';
import 'package:timezone/timezone.dart' as tz;

class Ticket {
  final String problemTitle;
  final String problemDescription;
  final String location;
  final DateTime date;
  final String attachmentUrl;

  Ticket({
    required this.problemTitle,
    required this.problemDescription,
    required this.location,
    required this.date,
    required this.attachmentUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'problemTitle': problemTitle,
      'problemDescription': problemDescription,
      'location': location,
      'date': date.toIso8601String(),
      'attachmentUrl': attachmentUrl,
    };
  }
}

class NotificationResponse {
  final String? title;
  final String? body;

  NotificationResponse({this.title, this.body});
}

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final BuildContext context;

  TicketBloc(this.flutterLocalNotificationsPlugin, this.context)
      : super(TicketInitialState()) {
    _initializeLocalNotifications();
  }

  void _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    InitializationSettings initializationSettings =
        const InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notification) =>
          _onDidReceiveLocalNotification(
              notification as NotificationResponse?, context),
      onDidReceiveBackgroundNotificationResponse: (notification) =>
          _onDidReceiveBackgroundLocalNotification(
              notification as NotificationResponse?),
    );
  }

  void _onDidReceiveLocalNotification(
    NotificationResponse? notification,
    BuildContext context,
  ) {
    // Handle received local notification when the app is in the foreground
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification?.title ?? 'Default Title'),
          content: Text(notification?.body ?? 'Default Body'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _onDidReceiveBackgroundLocalNotification(
      NotificationResponse? notification) async {
    // Handle received local notification when the app is in the background
    if (notification != null) {
      // Do something with the background notification data, e.g., navigate to a specific screen
      // You can use the information from the notification (notification.title, notification.body) to determine the appropriate action.
      // For example, you can use named routes to navigate to a specific screen:
      // Navigator.pushNamed(context, '/details', arguments: notification);

      // Or you can handle the notification in any way that suits your app's logic.
    }
  }
}

Future<void> _scheduleNotification(String problemTitle,
    FlutterLocalNotificationsPlugin localNotificationsPlugin) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    // 'your channel description',
    importance: Importance.max,
    priority: Priority.high,
  );
  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await localNotificationsPlugin.zonedSchedule(
    0,
    'Ticket Created',
    'Ticket: $problemTitle has been created successfully!',
    tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)),
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    payload: 'item x',
  );
}

@override
Stream<TicketState> mapEventToState(TicketEvent event) async* {
  if (event is CreateTicketEvent) {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      // ignore: unnecessary_null_comparison
      if (user != null) {
        await firestore.collection('tickets').add(event.ticket.toMap());
        // await _scheduleNotification(
        //     event.ticket.problemTitle, localNotificationsPlugin);
        yield TicketCreatedState();
      } else {
        yield TicketErrorState('User not authenticated');
      }
    } catch (e) {
      yield TicketErrorState('Failed to create ticket');
    }
  }
}
