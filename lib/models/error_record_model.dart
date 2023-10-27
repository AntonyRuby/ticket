class ErrorRecord {
  final int transId;
  final String transDesc;
  final String transStatus;
  final String transDateTime;

  ErrorRecord({
    required this.transId,
    required this.transDesc,
    required this.transStatus,
    required this.transDateTime,
  });

  // Convert ErrorRecord object to a Map
  Map<String, dynamic> toMap() {
    return {
      'transId': transId,
      'transDesc': transDesc,
      'transStatus': transStatus,
      'transDateTime': transDateTime,
    };
  }
}