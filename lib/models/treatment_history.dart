import 'package:cloud_firestore/cloud_firestore.dart';

class TreatmentHistory {
  final String treatment;
  final String date;
  final String doctor;
  final String doctorName;
  final String description;
  final String prescription;

  TreatmentHistory(
      {required this.treatment,
      required this.date,
      required this.doctor,
      required this.description,
      required this.prescription,
      required this.doctorName});

  Map<String, dynamic> toMap() {
    return {
      'treatment': treatment,
      'date': date,
      'doctor': doctor,
      'doctorName': doctorName,
      'description': description,
      'prescription': prescription,
    };
  }

  factory TreatmentHistory.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return TreatmentHistory(
      treatment: data['treatment'],
      date: data['date'],
      doctor: data['doctor'],
      doctorName: data['doctorName'],
      description: data['description'],
      prescription: data['prescription'],
    );
  }
}
