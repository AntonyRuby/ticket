import 'package:equatable/equatable.dart';
import 'package:error_records_git_ticket/models/ticket_model.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object?> get props => [];
}

class CreateTicketEvent extends TicketEvent {
  final Ticket ticket; // Accepts a Ticket object as a parameter

  const CreateTicketEvent(this.ticket); // Constructor with the Ticket parameter

  @override
  List<Object?> get props =>
      [ticket]; // Include the ticket object in the props list
}
