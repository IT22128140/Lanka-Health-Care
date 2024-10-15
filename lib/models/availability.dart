import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/shared/constants.dart';

class Availability {
  // Availability class fields
  final String date;
  final String arrivetime;
  final String leavetime;

  // Constructor that requires date, arrivetime, and leavetime
  Availability({required this.date, required this.arrivetime, required this.leavetime}) {
    // Call validate method to ensure all fields are valid
    validate();
  }
  // Validation method to check if required fields are non-empty
  void validate() {
    if (date.isEmpty) {
      throw ArgumentError(AppStrings.dateError);// Throw error if date is empty
    }
    if (arrivetime.isEmpty) {
      throw ArgumentError(AppStrings.arrivalTimeError); // Throw error if arrivetime is empty
    }
    if (leavetime.isEmpty) {
      throw ArgumentError(AppStrings.leaveTimeError);// Throw error if leavetime is empty
    }
  }

   // Method to convert Availability instance to a Map, suitable for Firestore
  Map<String, dynamic> toMap() {
    return {
      AppStrings.date: date, // Store date in the map
      AppStrings.arrivetime: arrivetime, // Store arrival time in the map
      AppStrings.leavetime: leavetime, // Store leave time in the map
    };
  }

 // Factory method to create Availability object from Firestore DocumentSnapshot
  factory Availability.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>; // Cast snapshot data to Map
    return Availability(
      date: data[AppStrings.date], // Extract date from the snapshot data
      arrivetime: data[AppStrings.arrivetime], // Extract arrivetime from the snapshot data
      leavetime: data[AppStrings.leavetime], // Extract leavetime from the snapshot data
    );
  }
}
