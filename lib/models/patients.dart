import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/shared/constants.dart';

class Patients {
  //Patients class fields
  final String firstName;
  final String lastName;
  final DateTime dob;
  final String phone;
  final String gender;

  //Constructs a Patient object and performs validation on the provided data
  Patients(
      {required this.firstName,
      required this.lastName,
      required this.dob,
      required this.phone,
      required this.gender}) {
    _validate();
  }

  void _validate() {
    if (firstName.isEmpty) {
      throw ArgumentError(
          AppStrings.firstnameEmpty); //Checks if the firstname is empty
    }
    if (lastName.isEmpty) {
      throw ArgumentError(
          AppStrings.lastnameEmpty); //Checks if the lastname is empty
    }
    if (dob.isAfter(DateTime.now())) {
      throw ArgumentError(
          AppStrings.dobNotFuture); //Checks if date of birth is in the future
    }
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone)) {
      throw ArgumentError(
          AppStrings.phoneInvalid); //Checks if phone number is invalid
    }
    if (gender.isEmpty ||
        !(gender == AppStrings.male ||
            gender == AppStrings.female ||
            gender == AppStrings.other)) {
      throw ArgumentError(
          AppStrings.genderInvalid); //Checks if gender is invalid
    }
  }

  //Method to convert the Patients instance to a Map, suitable for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      AppStrings.patientfirstName: firstName,
      AppStrings.patientlastName: lastName,
      AppStrings.patientdob: dob,
      AppStrings.patientPhone: phone,
      AppStrings.patientGender: gender,
    };
  }

  // Factory method to create a Patients object from Firestore DocumentSnapshot
  factory Patients.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Patients(
      firstName: data[AppStrings.patientfirstName],
      lastName: data[AppStrings.patientlastName],
      dob: (data[AppStrings.patientdob] as Timestamp).toDate(),
      phone: data[AppStrings.patientPhone],
      gender: data[AppStrings.patientGender],
    );
  }
}
