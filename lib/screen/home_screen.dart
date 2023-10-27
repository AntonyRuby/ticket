import 'package:error_records_git_ticket/screen/create_screen.dart';
import 'package:error_records_git_ticket/screen/error_records_screen.dart';
import 'package:error_records_git_ticket/screen/github_rep_screen.dart';
import 'package:error_records_git_ticket/screen/ticket_form_screen/ticket_bloc.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final TicketBloc ticketBloc;
  const HomeScreen({super.key, required this.ticketBloc});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ticket Management App'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.error), text: 'Error Records'),
              Tab(icon: Icon(Icons.star), text: 'GitHub Repos'),
              Tab(icon: Icon(Icons.add), text: 'Create Ticket'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ErrorRecordsScreen(),
            const GithubRepositoriesScreen(),
            // TicketFormScreen(ticketBloc),
            TicketScreen(
              ticketBloc: ticketBloc,
            )
          ],
        ),
      ),
    );
  }
}
