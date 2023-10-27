// ticket_bloc.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';
import 'package:timezone/timezone.dart' as tz;

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
    // _initializeLocalNotifications(flutterLocalNotificationsPlugin, context);
  }

  // static void _initializeLocalNotifications(
  //     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  //     BuildContext context) async {
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');
  //   InitializationSettings initializationSettings =
  //       const InitializationSettings(android: initializationSettingsAndroid);
  //   await flutterLocalNotificationsPlugin.initialize(
  //     initializationSettings,
  //     onDidReceiveNotificationResponse: (notification) =>
  //         _onDidReceiveLocalNotification(
  //             notification as NotificationResponse?, context),
  //     onDidReceiveBackgroundNotificationResponse: (notification) =>
  //         _onDidReceiveBackgroundLocalNotification(
  //             notification as NotificationResponse?),
  //   );
  // }

  static void _onDidReceiveLocalNotification(
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

  static void _onDidReceiveBackgroundLocalNotification(
      NotificationResponse? notification) async {
    if (notification != null) {
      String title = notification.title ?? 'Default Title';
      String body = notification.body ?? 'Default Body';

      print('Received background notification - Title: $title, Body: $body');
    }
  }

  Future<void> _scheduleNotification(
      String problemTitle, FlutterLocalNotificationsPlugin plugin) async {
    // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
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
          await _scheduleNotification(
              event.ticket.problemTitle, flutterLocalNotificationsPlugin);
          yield TicketCreatedState();
        } else {
          yield TicketErrorState('User not authenticated');
        }
      } catch (e) {
        yield TicketErrorState('Failed to create ticket');
      }
    }
  }
}
