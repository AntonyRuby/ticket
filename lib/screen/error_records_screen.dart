import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';

// Error Records Handling (Use Case 1) - SQFlite Implementation

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
    await _database.insert(
      'error_records',
      errorRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ErrorRecord>> getErrorRecords() async {
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
  }
}

class ErrorRecordsScreen extends StatelessWidget {
  final ErrorRecordDatabase _errorRecordDatabase = ErrorRecordDatabase();

  ErrorRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Records'),
      ),
      body: FutureBuilder<List<ErrorRecord>>(
        future: _errorRecordDatabase.getErrorRecords(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('TransID: ${snapshot.data![index].transId}'),
                  subtitle:
                      Text('Status: ${snapshot.data![index].transStatus}'),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
