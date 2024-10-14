import 'package:cloud_firestore/cloud_firestore.dart';

class TreatmentHistory {
  final String treatment;
  final String date;
  final String doctor;
  final String doctorName;
  final String description;
  final String prescription;

  TreatmentHistory({
    required this.treatment,
    required this.date,
    required this.doctor,
    required this.description,
    required this.prescription,
    required this.doctorName,
  }) {
    // Validate fields during initialization
    if (treatment.isEmpty) {
      throw ArgumentError('Treatment cannot be empty.');
    }
    if (date.isEmpty) {
      throw ArgumentError('Date cannot be empty.');
    }
    if (doctor.isEmpty) {
      throw ArgumentError('Doctor cannot be empty.');
    }
    if (doctorName.isEmpty) {
      throw ArgumentError('Doctor Name cannot be empty.');
    }
    if (description.isEmpty) {
      throw ArgumentError('Description cannot be empty.');
    }
    if (prescription.isEmpty) {
      throw ArgumentError('Prescription cannot be empty.');
    }
  }

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
    
    // Check for required fields and throw an error if missing
    if (data['treatment'] == null || data['date'] == null || data['doctor'] == null ||
        data['doctorName'] == null || data['description'] == null || data['prescription'] == null) {
      throw ArgumentError('One or more required fields are missing.');
    }

    return TreatmentHistory(
      treatment: data['treatment'],
      date: data['date'],
      doctor: data['doctor'],
      doctorName: data['doctorName'],
      description: data['description'],
      prescription: data['prescription'],
    );
  }

  bool validate() {
    return treatment.isNotEmpty &&
        date.isNotEmpty &&
        doctor.isNotEmpty &&
        doctorName.isNotEmpty &&
        description.isNotEmpty &&
        prescription.isNotEmpty;
  }
}
