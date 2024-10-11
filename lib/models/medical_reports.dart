import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalReports {
  final String allergies;
  final String medications;
  final String surgeries;

  MedicalReports({required this.allergies, required this.medications, required this.surgeries});

  Map<String, dynamic> toMap() {
    return {
      'allergies': allergies,
      'medications': medications,
      'surgeries': surgeries,
    };
  }

  factory MedicalReports.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return MedicalReports(
      allergies: data['allergies'],
      medications: data['medications'],
      surgeries: data['surgeries'],
    );
  }
}