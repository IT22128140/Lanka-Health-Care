import 'package:cloud_firestore/cloud_firestore.dart';

class Availability {
  final String date;
  final String arrivetime;
  final String leavetime;

  Availability({required this.date, required this.arrivetime, required this.leavetime}) {
    validate();
  }

  void validate() {
    if (date.isEmpty) {
      throw ArgumentError('Date cannot be empty');
    }
    if (arrivetime.isEmpty) {
      throw ArgumentError('Arrival time cannot be empty');
    }
    if (leavetime.isEmpty) {
      throw ArgumentError('Leave time cannot be empty');
    }
    // Add more validations as needed, e.g., date format, time format, etc.
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'arrivetime': arrivetime,
      'leavetime': leavetime,
    };
  }

  factory Availability.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Availability(
      date: data['date'],
      arrivetime: data['arrivetime'],
      leavetime: data['leavetime'],
    );
  }
}
