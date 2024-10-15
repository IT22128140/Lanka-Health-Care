import 'package:cloud_firestore/cloud_firestore.dart';

import '../shared/constants.dart';

class TreatmentHistory {
  //Fields to store treatment history details
  final String treatment;
  final String date;
  final String doctor;
  final String doctorName;
  final String description;
  final String prescription;

  // Constructor to initialize a TreatmentHistory object with required fields
  TreatmentHistory({
    required this.treatment,
    required this.date,
    required this.doctor,
    required this.description,
    required this.prescription,
    required this.doctorName,
  }) {
    // Validations: Throwing an error if any of the required fields is empty
    if (treatment.isEmpty) {
      throw ArgumentError(AppStrings.treatmentValidation);
    }
    if (date.isEmpty) {
      throw ArgumentError(AppStrings.dateError);
    }
    if (doctor.isEmpty) {
      throw ArgumentError(AppStrings.doctorValidation);
    }
    if (doctorName.isEmpty) {
      throw ArgumentError(AppStrings.doctorNameValidation);
    }
    if (description.isEmpty) {
      throw ArgumentError(AppStrings.descriptionValidation);
    }
    if (prescription.isEmpty) {
      throw ArgumentError(AppStrings.prescriptionValidation);
    }
  }

 // Method to convert the TreatmentHistory object into a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      AppStrings.treatment: treatment,
      AppStrings.date: date,
      AppStrings.doctor: doctor,
      AppStrings.doctorName: doctorName,
      AppStrings.description: description,
      AppStrings.prescription: prescription,
    };
  }

 // Factory method to create a TreatmentHistory object from a Firestore DocumentSnapshot
  factory TreatmentHistory.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    
    // Validate that required fields are present in the data, throw error if missing
    if (data[AppStrings.treatment] == null || data[AppStrings.date] == null || data[AppStrings.doctor] == null ||
        data[AppStrings.doctorName] == null || data[AppStrings.description] == null || data[AppStrings.prescription] == null) {
      throw ArgumentError(AppStrings.requiredFieldsMissing);
    }

    // Return a TreatmentHistory object populated with the snapshot data
    return TreatmentHistory(
      treatment: data[AppStrings.treatment],
      date: data[AppStrings.date],
      doctor: data[AppStrings.doctor],
      doctorName: data[AppStrings.doctorName],
      description: data[AppStrings.description],
      prescription: data[AppStrings.prescription],
    );
  }

  // Method to validate the treatment history fields, ensuring none are empty
  bool validate() {
    return treatment.isNotEmpty &&
        date.isNotEmpty &&
        doctor.isNotEmpty &&
        doctorName.isNotEmpty &&
        description.isNotEmpty &&
        prescription.isNotEmpty;
  }
}
