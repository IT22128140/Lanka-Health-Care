import 'package:cloud_firestore/cloud_firestore.dart';

class Patients {
  final String firstName;
  final String lastName;
  final DateTime dob;
  final String phone;
  final String gender;

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
      throw ArgumentError('First name cannot be empty');
    }
    if (lastName.isEmpty) {
      throw ArgumentError('Last name cannot be empty');
    }
    if (dob.isAfter(DateTime.now())) {
      throw ArgumentError('Date of birth cannot be in the future');
    }
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone)) {
      throw ArgumentError('Invalid phone number');
    }
    if (gender.isEmpty || !(gender == 'Male' || gender == 'Female' || gender == 'Other')) {
      throw ArgumentError('Invalid gender');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob,
      'phone': phone,
      'gender': gender,
    };
  }

  factory Patients.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Patients(
      firstName: data['firstName'],
      lastName: data['lastName'],
      dob: (data['dob'] as Timestamp).toDate(),
      phone: data['phone'],
      gender: data['gender'],
    );
  }
}
