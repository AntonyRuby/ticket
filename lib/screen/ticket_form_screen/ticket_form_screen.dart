import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:error_records_git_ticket/screen/ticket_form_screen/ticket_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

CollectionReference ticketsCollection =
    FirebaseFirestore.instance.collection('tickets');

Future<void> addTicket(String problemTitle, String problemDescription,
    String location, String attachmentUrl) async {
  DateTime now = DateTime.now();
  Timestamp timestamp = Timestamp.fromDate(now);

  FirebaseFirestore.instance.collection('tickets').add({
    'Problem Title': problemTitle,
    'Problem Description': problemDescription,
    'Location': location,
    'Date': timestamp,
    'Attachment URL': attachmentUrl,
  }).then((value) {});
}

class TicketFormScreen extends StatelessWidget {
  final TicketBloc ticketBloc;

  const TicketFormScreen(this.ticketBloc, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TicketForm(ticketBloc: ticketBloc),
      ),
    );
  }
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getTickets() async {
    QuerySnapshot querySnapshot = await _firestore.collection('tickets').get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}

class FirebaseListView extends StatelessWidget {
  final FirebaseService firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: firebaseService.getTickets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tickets available.'));
        } else {
          return Expanded(
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> ticket = snapshot.data![index];
                return ListTile(
                  title: Text(ticket['problemTitle'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ticket['problemDescription'] ?? ''),
                      Text('Location: ${ticket['Location'] ?? ''}'),
                      Text(
                          'Date: ${ticket['Date'].toDate()}'), // Convert Timestamp to DateTime
                      Text('Attachment URL: ${ticket['Attachment URL']}'),
                    ],
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}

class TicketForm extends StatefulWidget {
  final TicketBloc ticketBloc;

  const TicketForm({Key? key, required this.ticketBloc}) : super(key: key);

  @override
  _TicketFormState createState() => _TicketFormState();
}

class _TicketFormState extends State<TicketForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? attachmentUrl; // Store the attachment URL after upload

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  bool _isUploading = false;

  Future<void> _pickImage() async {
    var galleryStatus = await Permission.storage.request();
    if (galleryStatus.isGranted) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _isUploading = true; // Start the upload, show loading indicator
        });

        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('uploads/${DateTime.now()}.png');
        UploadTask uploadTask = storageReference.putFile(File(pickedFile.path));

        await uploadTask.whenComplete(() async {
          String url = await storageReference.getDownloadURL();
          setState(() {
            attachmentUrl = url;
            _isUploading = false; // Upload completed, hide loading indicator
          });
        });
      }
    } else {
      // Gallery permission denied, show a message or handle it accordingly
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Permission Denied'),
            content:
                const Text('Gallery permission is required to pick an image.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Problem Title'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Problem Description'),
          ),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: ElevatedButton(
              onPressed: _isUploading
                  ? null
                  : _pickImage, // Disable button during upload
              child: _isUploading
                  ? const CircularProgressIndicator() // Show loading indicator
                  : const Text('Pick Image'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 28.0),
            child: ElevatedButton(
              onPressed: _isUploading
                  ? null
                  : _handleSubmit, // Call the _handleSubmit function when the button is pressed
              child: const Text('Submit Ticket'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    String title = _titleController.text;
    String description = _descriptionController.text;
    String location = _locationController.text;

    if (title.isNotEmpty && description.isNotEmpty && location.isNotEmpty) {
      // Check if attachmentUrl is null or empty before adding it to the Firestore document
      String attachment = attachmentUrl ??
          ''; // Use the selected attachment URL if not null, otherwise, use an empty string

      // Upload ticket information to Firestore
      await addTicket(title, description, location, attachment);

      // Show a success message or navigate to a different screen
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ticket submitted successfully!'),
      ));

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

      await flutterLocalNotificationsPlugin.show(
        0, // Notification ID (use a different ID for each notification if needed)
        'Title', // Notification title
        'Body', // Notification body
        platformChannelSpecifics,
        payload: 'item x',
      );
      // await flutterLocalNotificationsPlugin.zonedSchedule(
      //   0,
      //   'Ticket Created',
      //   'Ticket:  has been created successfully!',
      //   tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)),
      //   platformChannelSpecifics,
      //   androidAllowWhileIdle: true,
      //   uiLocalNotificationDateInterpretation:
      //       UILocalNotificationDateInterpretation.absoluteTime,
      //   payload: 'item x',
      // );
      // Send a push notification
      // You can use Firebase Cloud Messaging to send notifications here.
      // For example, you can use the `firebase_messaging` plugin to send notifications.
      // Refer to the official documentation for detailed implementation.
    } else {
      // Show an error message if any of the required fields are empty
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill out all required fields.'),
      ));
    }
  }
}
