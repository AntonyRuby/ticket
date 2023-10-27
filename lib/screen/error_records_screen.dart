import 'package:error_records_git_ticket/models/error_record_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// Error Records Handling (Use Case 1) - SQFlite Implementation
class EmailService {
  static Future<void> sendErrorRecordsEmail(
      List<ErrorRecord> errorRecords) async {
    final Email email = Email(
      subject: 'Error Records Report', // Email subject
      recipients: ['admin@example.com'], // Administrator's email address
      body: _composeEmailBody(errorRecords),
    );

    try {
      await FlutterEmailSender.send(email);
      print('Email sent successfully.'); // Added this line for debugging
    } catch (error) {
      print('Error sending email: $error');
    }
  }

  static String _composeEmailBody(List<ErrorRecord> errorRecords) {
    String body = 'Error Records:\n\n';
    for (var record in errorRecords) {
      body += 'TransID: ${record.transId}\n';
      body += 'TransDesc: ${record.transDesc}\n';
      body += 'TransStatus: ${record.transStatus}\n';
      body += 'TransDateTime: ${record.transDateTime}\n\n';
    }
    return body;
  }
}

Future<void> scheduleDailyNotification() async {
  tz.initializeTimeZones(); // Initialize time zones
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Set local time zone

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('ic_launcher');
  // var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    // iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
  );

  // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    // iOS: iOSPlatformChannelSpecifics,
  );

  // var scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(days: 1));

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID (use a different ID for each notification if needed)
    'Daily Error Records',
    'Check if there are any error records to send.',
    platformChannelSpecifics,
    payload: 'item x',
  );

  // await flutterLocalNotificationsPlugin.zonedSchedule(
  //   0,
  //   'Daily Error Records',
  //   'Check if there are any error records to send.',
  //   scheduledTime,
  //   platformChannelSpecifics,
  //   uiLocalNotificationDateInterpretation:
  //       UILocalNotificationDateInterpretation.absoluteTime,
  //   androidAllowWhileIdle: true,
  // );
}

class ErrorRecordDatabase {
  late final Database _database;

  Future<void> initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'error_records_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE error_records(id INTEGER PRIMARY KEY, TransID INTEGER, TransDesc TEXT, TransStatus TEXT, TransDateTime TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertErrorRecord(ErrorRecord errorRecord) async {
    try {
      await _database.insert(
        'error_records',
        errorRecord.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Record inserted successfully');
    } catch (e) {
      print('Error inserting record: $e');
      // Handle the error based on the specific exception type or error message.
      if (e is DatabaseException) {
        // Handle database-related errors (e.g., constraint violations).
        if (e.isUniqueConstraintError()) {
          // Handle unique constraint violation error.
          // Show a user-friendly error message.
          print('Duplicate record: The record already exists in the database.');
        } else {
          // Handle other database errors.
          print('Database error: $e');
        }
      } else {
        // Handle other types of errors.
        // Show a generic error message or log the error for debugging.
        print('Unexpected error occurred: $e');
      }
      // Optionally, re-throw the exception to propagate it to the calling code.
      // rethrow;
    }
  }

  Future<List<ErrorRecord>> getErrorRecords() async {
    try {
      final List<Map<String, dynamic>> maps =
          await _database.query('error_records');
      return List.generate(maps.length, (i) {
        return ErrorRecord(
          transId: maps[i]['TransID'],
          transDesc: maps[i]['TransDesc'],
          transStatus: maps[i]['TransStatus'],
          transDateTime: maps[i]['TransDateTime'],
        );
      });
    } catch (e) {
      print('Error retrieving records: $e');
      // Handle the error as needed (e.g., show an error message to the user).
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Failed to retrieve records. Please try again later.'),
          duration: Duration(seconds: 3),
        ),
      );
      return []; // Return an empty list or handle the error state accordingly.
    }
  }
}

class ErrorRecordsScreen extends StatelessWidget {
  // final ErrorRecordDatabase _errorRecordDatabase = ErrorRecordDatabase();

  ErrorRecordsScreen({super.key});

  // Define errorRecordsList as a list of ErrorRecord objects
  final List<ErrorRecord> errorRecordsList = [
    ErrorRecord(
      transId: 1,
      transDesc: 'UpdateTask',
      transStatus: 'Success',
      transDateTime: '12-05-2022 10:00',
    ),
    ErrorRecord(
      transId: 2,
      transDesc: 'UpdateStatus',
      transStatus: 'Pending',
      transDateTime: '12-05-2022 11:00',
    ),
    // Add more ErrorRecord objects as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Error Records'),
        ),
        body: ElevatedButton(
          onPressed: () {
            // Assuming errorRecordsList contains the list of error records to send
            EmailService.sendErrorRecordsEmail(errorRecordsList);
          },
          child: const Text('Send Error Records Email'),
        )

        // FutureBuilder<List<ErrorRecord>>(
        //   future: _errorRecordDatabase.getErrorRecords(),
        //   builder: (context, snapshot) {
        //     if (snapshot.hasData) {
        //       return ListView.builder(
        //         itemCount: snapshot.data!.length,
        //         itemBuilder: (context, index) {
        //           return ListTile(
        //             title: Text('TransID: ${snapshot.data![index].transId}'),
        //             subtitle:
        //                 Text('Status: ${snapshot.data![index].transStatus}'),
        //           );
        //         },
        //       );
        //     } else if (snapshot.hasError) {
        //       return Center(
        //         child: Text('Error: ${snapshot.error}'),
        //       );
        //     }
        //     return const Center(
        //       child: CircularProgressIndicator(),
        //     );
        //   },
        // ),
        );
  }
}
