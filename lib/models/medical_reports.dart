import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/shared/constants.dart';

class MedicalReports {
  // MedicalReports class fields
  final String allergies;
  final String medications;
  final String surgeries;

  // Constructor that requires allergies, medications, and surgeries to be provided
  MedicalReports({required this.allergies, required this.medications, required this.surgeries});

  // Method to convert the MedicalReports instance to a Map, suitable for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      AppStrings.allergies: allergies, // Store allergies in the map
      AppStrings.medications: medications, // Store medications in the map
      AppStrings.surgeries: surgeries, // Store surgeries in the map
    };
  }

 // Factory method to create a MedicalReports object from Firestore DocumentSnapshot
  factory MedicalReports.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>; // Cast snapshot data to Map
    return MedicalReports(
      allergies: data[AppStrings.allergies], // Extract allergies from the snapshot data
      medications: data[AppStrings.medications], // Extract medications from the snapshot data
      surgeries: data[AppStrings.surgeries], // Extract surgeries from the snapshot data
    );
  }
}