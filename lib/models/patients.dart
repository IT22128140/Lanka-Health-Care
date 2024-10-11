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
      required this.gender});

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
      dob: data['dob'],
      phone: data['phone'],
      gender: data['gender'],
    );
  }
}
