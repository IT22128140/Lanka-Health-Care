import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/models/patients.dart';
import 'package:mockito/mockito.dart';

class DocumentSnapshotMock extends Mock implements DocumentSnapshot {}

void main() {
  group('Patients Class Tests', () {
    // Test for object creation with valid data
    test('Patients object is created successfully with valid data', () {
      final patient = Patients(
        firstName: 'John',
        lastName: 'Doe',
        dob: DateTime(1990, 1, 1),
        phone: '+1234567890',
        gender: 'Male',
      );

      expect(patient.firstName, 'John');
      expect(patient.lastName, 'Doe');
      expect(patient.dob, DateTime(1990, 1, 1));
      expect(patient.phone, '+1234567890');
      expect(patient.gender, 'Male');
    });

    // Test for empty first name
    test('Patients constructor throws error for empty first name', () {
      expect(() {
        Patients(
          firstName: '',
          lastName: 'Doe',
          dob: DateTime(1990, 1, 1),
          phone: '+1234567890',
          gender: 'Male',
        );
      }, throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'First name cannot be empty')));
    });

    // Test for empty last name
    test('Patients constructor throws error for empty last name', () {
      expect(() {
        Patients(
          firstName: 'John',
          lastName: '',
          dob: DateTime(1990, 1, 1),
          phone: '+1234567890',
          gender: 'Male',
        );
      }, throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Last name cannot be empty')));
    });

    // Test for future date of birth
    test('Patients constructor throws error for future date of birth', () {
      expect(() {
        Patients(
          firstName: 'John',
          lastName: 'Doe',
          dob: DateTime.now().add(Duration(days: 1)), // Future date
          phone: '+1234567890',
          gender: 'Male',
        );
      }, throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Date of birth cannot be in the future')));
    });

    // Test for invalid phone number
    test('Patients constructor throws error for invalid phone number', () {
      expect(() {
        Patients(
          firstName: 'John',
          lastName: 'Doe',
          dob: DateTime(1990, 1, 1),
          phone: 'invalid_phone', // Invalid phone format
          gender: 'Male',
        );
      }, throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Invalid phone number')));
    });

    // Test for invalid gender
    test('Patients constructor throws error for invalid gender', () {
      expect(() {
        Patients(
          firstName: 'John',
          lastName: 'Doe',
          dob: DateTime(1990, 1, 1),
          phone: '+1234567890',
          gender: 'Unknown', // Invalid gender
        );
      }, throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Invalid gender')));
    });

    // Test for fromSnapshot method
    test('fromSnapshot method creates Patients from DocumentSnapshot', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn({
        'firstName': 'Jane',
        'lastName': 'Smith',
        'dob': Timestamp.fromDate(DateTime(1985, 5, 20)),
        'phone': '+0987654321',
        'gender': 'Female',
      });

      final patient = Patients.fromSnapshot(snapshot);

      expect(patient.firstName, 'Jane');
      expect(patient.lastName, 'Smith');
      expect(patient.dob, DateTime(1985, 5, 20));
      expect(patient.phone, '+0987654321');
      expect(patient.gender, 'Female');
    });
  });
}
