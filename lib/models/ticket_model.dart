class Ticket {
  final String id;
  final String problemTitle;
  final String problemDescription;
  final String location;
  final String attachmentUrl;

  Ticket({
    required this.id,
    required this.problemTitle,
    required this.problemDescription,
    required this.location,
    required this.attachmentUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'problemTitle': problemTitle,
      'problemDescription': problemDescription,
      'location': location,
      'attachmentUrl': attachmentUrl,
    };
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? '',
      problemTitle: json['problemTitle'] ?? '',
      problemDescription: json['problemDescription'] ?? '',
      location: json['location'] ?? '',
      attachmentUrl: json['attachmentUrl'] ?? '',
    );
  }
}
