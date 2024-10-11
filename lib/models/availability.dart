import 'package:cloud_firestore/cloud_firestore.dart';

class Availability {
  final String date;
  final String arrivetime;
  final String leavetime;

  Availability({required this.date, required this.arrivetime, required this.leavetime});

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
