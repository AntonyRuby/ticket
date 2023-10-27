import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:error_records_git_ticket/screen/ticket_form_screen/ticket_bloc.dart';
import 'package:error_records_git_ticket/screen/ticket_form_screen/ticket_form_screen.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getTickets() async {
    QuerySnapshot querySnapshot = await _firestore.collection('tickets').get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}

CollectionReference ticketsCollection =
    FirebaseFirestore.instance.collection('tickets');

Future<void> addTicket(String problemTitle, String problemDescription,
    String location, String attachmentUrl) async {
  DateTime now = DateTime.now();
  Timestamp timestamp = Timestamp.fromDate(now);

  // return ticketsCollection.add({
  //   'Problem Title': problemTitle,
  //   'Problem Description': problemDescription,
  //   'Location': location,
  //   'Date': timestamp,
  //   'Attachment URL': attachmentUrl,
  // });
  // ignore: dead_code
  FirebaseFirestore.instance.collection('tickets').add({
    'Problem Title': problemTitle,
    'Problem Description': problemDescription,
    'Location': location,
    'Date': timestamp,
    'Attachment URL': attachmentUrl,
  }).then((value) {});
}

class TicketScreen extends StatelessWidget {
  final TicketBloc ticketBloc;

  const TicketScreen({required this.ticketBloc, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Screen'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Navigate to the TicketFormScreen when the button is pressed.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TicketFormScreen(ticketBloc),
                ),
              );
            },
            child: const Text('Create Ticket'),
          ),
          Expanded(
            child: FirebaseListView(), // Display list of tickets
          ),
        ],
      ),
    );
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
