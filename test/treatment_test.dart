import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/models/treatment_history.dart';
import 'package:mockito/mockito.dart';

// Create a mock for DocumentSnapshot
class DocumentSnapshotMock extends Mock implements DocumentSnapshot {}

void main() {
  group('TreatmentHistory Tests', () {
    // Test case 1: Check if TreatmentHistory is instantiated correctly
    test('Positive: should create TreatmentHistory with correct properties', () {
      final treatmentHistory = TreatmentHistory(
        treatment: 'Checkup',
        date: '2023-10-14',
        doctor: '123',
        doctorName: 'Dr. John Doe',
        description: 'Routine checkup',
        prescription: 'None',
      );

      expect(treatmentHistory.treatment, 'Checkup');
      expect(treatmentHistory.date, '2023-10-14');
      expect(treatmentHistory.doctor, '123');
      expect(treatmentHistory.doctorName, 'Dr. John Doe');
      expect(treatmentHistory.description, 'Routine checkup');
      expect(treatmentHistory.prescription, 'None');
    });

    // test('Negative: should throw an error when properties are missing', () {
    //   expect(
    //     () => TreatmentHistory(
    //       treatment: '',  // Missing treatment
    //       date: '2023-10-14',
    //       doctor: '123',
    //       doctorName: 'Dr. John Doe',
    //       description: 'Routine checkup',
    //       prescription: 'None',
    //     ),
    //     throwsA(isA<ArgumentError>()), // Adjust this according to your constructor error handling
    //   );
    // });

    // Test case 2: Positive test for converting TreatmentHistory to a Map
    test('Positive: toMap should return a Map with the correct data', () {
      final treatmentHistory = TreatmentHistory(
        treatment: 'Checkup',
        date: '2023-10-14',
        doctor: '123',
        doctorName: 'Dr. John Doe',
        description: 'Routine checkup',
        prescription: 'None',
      );

      final expectedMap = {
        'treatment': 'Checkup',
        'date': '2023-10-14',
        'doctor': '123',
        'doctorName': 'Dr. John Doe',
        'description': 'Routine checkup',
        'prescription': 'None',
      };

      expect(treatmentHistory.toMap(), expectedMap);
    });

    test('Negative: toMap should not include incorrect data', () {
      final treatmentHistory = TreatmentHistory(
        treatment: 'Checkup',
        date: '2023-10-14',
        doctor: '123',
        doctorName: 'Dr. John Doe',
        description: 'Routine checkup',
        prescription: 'None',
      );

      final map = treatmentHistory.toMap();
      expect(map, isNot(contains('invalidField')));
    });

    // Test case 3: Positive test for fromSnapshot method
    test('Positive: fromSnapshot should create TreatmentHistory from DocumentSnapshot', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn({
        'treatment': 'Checkup',
        'date': '2023-10-14',
        'doctor': '123',
        'doctorName': 'Dr. John Doe',
        'description': 'Routine checkup',
        'prescription': 'None',
      });

      final treatmentHistory = TreatmentHistory.fromSnapshot(snapshot);

      expect(treatmentHistory.treatment, 'Checkup');
      expect(treatmentHistory.date, '2023-10-14');
      expect(treatmentHistory.doctor, '123');
      expect(treatmentHistory.doctorName, 'Dr. John Doe');
      expect(treatmentHistory.description, 'Routine checkup');
      expect(treatmentHistory.prescription, 'None');
    });

    test('Negative: fromSnapshot should throw an error when data is incomplete', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn({
        'treatment': 'Checkup',
        'date': '2023-10-14',
        // Missing doctor, doctorName, description, and prescription
      });

      expect(
        () => TreatmentHistory.fromSnapshot(snapshot),
        throwsA(isA<TypeError>()), // Assuming that your fromSnapshot method checks for required fields
      );
    });

    test('Negative: fromSnapshot should throw an error when snapshot data is null', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn(null);

      expect(
        () => TreatmentHistory.fromSnapshot(snapshot),
        throwsA(isA<TypeError>()), // Adjust according to your method's error handling
      );
    });
  });
}
