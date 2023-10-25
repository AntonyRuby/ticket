import 'package:error_records_git_ticket/screen/home_screen.dart';
import 'package:error_records_git_ticket/screen/ticket_form_screen/ticket_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle notification when the app is in the background.
  print("Handling a background message: ${message.messageId}");

  // Initialize the local notifications plugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          'app_icon'); // Replace 'app_icon' with your app's icon name
  InitializationSettings initializationSettings =
      const InitializationSettings(android: initializationSettingsAndroid);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'your_channel_id', // Replace with your own channel ID
    'your_channel_name', // Replace with your own channel name
    channelDescription:
        'your_channel_description', // Replace with your own channel description
    importance: Importance.max,
    priority: Priority.high,
  );

  var platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Extract notification data
  String? title = message.notification?.title ?? 'Default Title';
  String? body = message.notification?.body ?? 'Default Body';

  // Show the notification
  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID (use a different ID for each notification if needed)
    title, // Notification title
    body, // Notification body
    platformChannelSpecifics,
    payload: 'item x',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    TicketBloc ticketBloc =
        TicketBloc(flutterLocalNotificationsPlugin, context);

    return BlocProvider(
      create: (context) => TicketBloc(flutterLocalNotificationsPlugin, context),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: HomeScreen(ticketBloc: ticketBloc),
      ),
    );
  }
}
