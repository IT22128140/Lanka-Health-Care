import 'package:cloud_firestore/cloud_firestore.dart';

import '../shared/constants.dart';

class Appointment {
  // Appointment class fields
  final String doctoruid;
  final String patientuid;
  final String date;
  final String time;
  final String status;
  final String paymentStatus;

  // Constructor that requires all fields and calls the validate method
  Appointment(
      {required this.doctoruid,
      required this.patientuid,
      required this.date,
      required this.time,
      required this.status,
      required this.paymentStatus,}) {
        // Validation to ensure all fields are properly initialized
    validate();
  }

 // Method to validate the fields of the Appointment class
  void validate() {
    if (doctoruid.isEmpty) {
      throw ArgumentError();// Throws error if doctoruid is empty
    }
    if (patientuid.isEmpty) {
      throw ArgumentError(AppStrings.patientUidValidation);// Throws error if patientuid is empty with a specific message
    }
    if (date.isEmpty) {
      throw ArgumentError(AppStrings.dateError);// Throws error if date is empty with a specific message
    }
    if (time.isEmpty) {
      throw ArgumentError(AppStrings.timeValidation);// Throws error if time is empty with a specific message
    }
    if (status.isEmpty) {
      throw ArgumentError(AppStrings.statusValidation);// Throws error if status is empty with a specific message
    }
    if (paymentStatus.isEmpty) {
      throw ArgumentError(AppStrings.paymentStatusValidation);// Throws error if paymentStatus is empty with a specific message
    }
  }

 // Converts the Appointment instance into a Map to be stored in Firestore
  Map<String, dynamic> toMap() {
    return {
      AppStrings.doctorUid: doctoruid, // Doctor UID field
      AppStrings.patientUid: patientuid, // Patient UID field
      AppStrings.date: date, // Date field
      AppStrings.time: time, // Time field
      AppStrings.status: status, // Status field
      AppStrings.paymentStatus: paymentStatus, // Payment Status field
    };
  }

  // Factory method to create an Appointment object from a Firestore DocumentSnapshot
  factory Appointment.fromSnapshot(DocumentSnapshot snapshot) {
    return Appointment(
      doctoruid: snapshot[AppStrings.doctorUid], // Extract doctoruid from snapshot
      patientuid: snapshot[AppStrings.patientUid], // Extract patientuid from snapshot
      date: snapshot[AppStrings.date], // Extract date from snapshot
      time: snapshot[AppStrings.time], // Extract time from snapshot
      status: snapshot[AppStrings.status], // Extract status from snapshot
      paymentStatus: snapshot[AppStrings.paymentStatus], // Extract payment status from snapshot
    );
  }
}
