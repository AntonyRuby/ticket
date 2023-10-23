// ticket_state.dart

abstract class TicketState {}

class TicketInitialState extends TicketState {}

class TicketCreatedState extends TicketState {}

class TicketErrorState extends TicketState {
  final String error;

  TicketErrorState(this.error);

  @override
  String toString() => 'TicketErrorState: $error';
}
