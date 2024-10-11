import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String doctoruid;
  final String patientuid;
  final String date;
  final String time;
  final String status;
  final String paymentStatus;

  Appointment(
      {required this.doctoruid,
      required this.patientuid,
      required this.date,
      required this.time,
      required this.status,
      required this.paymentStatus,});

  Map<String, dynamic> toMap() {
    return {
      'doctoruid': doctoruid,
      'patientuid': patientuid,
      'date': date,
      'time': time,
      'status': status,
      'paymentStatus': paymentStatus,
    };
  }

  factory Appointment.fromSnapshot(DocumentSnapshot snapshot) {
    return Appointment(
      doctoruid: snapshot['doctoruid'],
      patientuid: snapshot['patientuid'],
      date: snapshot['date'],
      time: snapshot['time'],
      status: snapshot['status'],
      paymentStatus: snapshot['paymentStatus'],
    );
  }
}
