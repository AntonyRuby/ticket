import 'package:error_records_git_ticket/screen/ticket_form_screen/ticket_bloc.dart';
import 'package:error_records_git_ticket/screen/ticket_form_screen/ticket_state.dart';
import 'package:error_records_git_ticket/screen/ticket_form_screen/ticket_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketFormScreen extends StatelessWidget {
  final TicketBloc ticketBloc;

  const TicketFormScreen(this.ticketBloc, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TicketBloc ticketBloc = BlocProvider.of<TicketBloc>(context);
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String? downloadUrl; // Store the attachment URL after upload

  // Future<void> _pickImage() async {
  //   final pickedFile =
  //       await ImagePicker().getImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     // Handle the picked file (upload it to Firebase Storage, for example)
  //     // You can use the pickedFile.path to get the file path and upload it to Firebase Storage.
  //     // After successful upload, set the _attachmentUrl state variable with the download URL.
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        ElevatedButton(
          onPressed: () {
            String title = _titleController.text;
            String description = _descriptionController.text;
            String location = _locationController.text;
            String attachmentUrl = '';
            DateTime date = DateTime.now();

            Ticket ticket = Ticket(
              problemTitle: title,
              problemDescription: description,
              location: location,
              date: date,
              attachmentUrl: attachmentUrl,
            );

            widget.ticketBloc.add(CreateTicketEvent(ticket));
          },
          child: const Text('Submit Ticket'),
        ),
      ],
    );
  }
}

class TicketScreen extends StatelessWidget {
  const TicketScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    final TicketBloc ticketBloc = BlocProvider.of<TicketBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
            BlocBuilder<TicketBloc, TicketState>(
              builder: (context, state) {
                if (state is TicketInitialState) {
                  return const Text('Initial State');
                } else if (state is TicketCreatedState) {
                  return const Text('Ticket Created Successfully!');
                } else if (state is TicketErrorState) {
                  return Text('Error: ${state.error}');
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
