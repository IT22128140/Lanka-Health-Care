import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:lanka_health_care/models/patients.dart';

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  group('Patient Class Tests', () {
    //Test Case 1 : Positive test case for field validations
    test('Positive Case: Create Patients object with valid inputs', () {
      final patient = Patients(
        firstName: 'John',
        lastName: 'Doe',
        dob: DateTime(1990, 1, 1),
        phone: '1234567890',
        gender: 'Male',
      );

      expect(patient.firstName, equals('John'));
      expect(patient.lastName, equals('Doe'));
      expect(patient.dob, equals(DateTime(1990, 1, 1)));
      expect(patient.phone, equals('123-456-7890'));
      expect(patient.gender, equals('Male'));
    });

    //Test Case 1 : Negative test case for field validations
    test('Negative Case: Create Patients object with invalid inputs', () {
      final patient = Patients(
        firstName: '',
        lastName: '',
        dob: DateTime(1990, 1, 1),
        phone: '1234567890', 
        gender: 'Male' ,
      );

      expect(patient.firstName, isEmpty);
      expect(patient.lastName, isEmpty);  
    });

  });
}
