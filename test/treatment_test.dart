import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/models/treatment_history.dart';
import 'package:mockito/mockito.dart';

class DocumentSnapshotMock extends Mock implements DocumentSnapshot {}

void main() {
  group('TreatmentHistory Tests', () {
    // Positive test cases

    // Test case to ensure the `toMap` method returns the correct map structure
    test('Positive: toMap should return correct Map', () {
      final treatmentHistory = TreatmentHistory(
        treatment: 'Physical Therapy',
        date: '2024-10-14',
        doctor: 'D12345',
        doctorName: 'Dr. Smith',
        description: 'Therapy for knee pain',
        prescription: 'Exercise regimen',
      );

      // Expected Map representation
      final expectedMap = {
        'treatment': 'Physical Therapy',
        'date': '2024-10-14',
        'doctor': 'D12345',
        'doctorName': 'Dr. Smith',
        'description': 'Therapy for knee pain',
        'prescription': 'Exercise regimen',
      };
      
      // Check if toMap() matches the expected map
      expect(treatmentHistory.toMap(), expectedMap);
    });

     // Test case to ensure `fromSnapshot` correctly creates an instance from a valid snapshot(firestore documentSnapshot)
    test(
        'Positive: fromSnapshot should create TreatmentHistory from valid DocumentSnapshot',
        () {
      final snapshot = DocumentSnapshotMock();
      // Simulate a valid snapshot data
      when(snapshot.data()).thenReturn({
        'treatment': 'Physical Therapy',
        'date': '2024-10-14',
        'doctor': 'D12345',
        'doctorName': 'Dr. Smith',
        'description': 'Therapy for knee pain',
        'prescription': 'Exercise regimen',
      });
      
      // Create TreatmentHistory from the snapshot
      final treatmentHistory = TreatmentHistory.fromSnapshot(snapshot);

      // Check if the fields match the expected values
      expect(treatmentHistory.treatment, 'Physical Therapy');
      expect(treatmentHistory.date, '2024-10-14');
      expect(treatmentHistory.doctor, 'D12345');
      expect(treatmentHistory.doctorName, 'Dr. Smith');
      expect(treatmentHistory.description, 'Therapy for knee pain');
      expect(treatmentHistory.prescription, 'Exercise regimen');
    });

    // Test case to ensure `validate` returns true for a valid TreatmentHistory
    test('Positive: validate should return true for valid TreatmentHistory',
        () {

       // Create a valid TreatmentHistory instance   
      final treatmentHistory = TreatmentHistory(
        treatment: 'Physical Therapy',
        date: '2024-10-14',
        doctor: 'D12345',
        doctorName: 'Dr. Smith',
        description: 'Therapy for knee pain',
        prescription: 'Exercise regimen',
      );

      // Check if validate() returns true for the valid data
      expect(treatmentHistory.validate(), isTrue);
    });

    // Negative test cases

    // Test case to ensure the constructor throws an error when the treatment is empty
    test('Negative: constructor should throw error when treatment is empty',
        () {
          // Create an instance with an empty treatment field and expect an error
      expect(
        () => TreatmentHistory(
          treatment: '', // Invalid: empty
          date: '2024-10-14',
          doctor: 'D12345',
          doctorName: 'Dr. Smith',
          description: 'Therapy for knee pain',
          prescription: 'Exercise regimen',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    // Test case to ensure `fromSnapshot` throws an error when fields are missing
    test('Negative: fromSnapshot should throw error when fields are missing',
        () {
      final snapshot = DocumentSnapshotMock();

      // Simulate snapshot data with a missing 'doctor' field
      when(snapshot.data()).thenReturn({
        'treatment': 'Physical Therapy',
        'date': '2024-10-14',
        // Missing doctor field
        'doctorName': 'Dr. Smith',
        'description': 'Therapy for knee pain',
        'prescription': 'Exercise regimen',
      });

      // Expect an error when creating a TreatmentHistory from the snapshot
      expect(
        () => TreatmentHistory.fromSnapshot(snapshot),
        throwsA(
            isA<ArgumentError>()), // Expect ArgumentError for missing fields
      );
    });

    // Test case to ensure `validate` returns false for an invalid TreatmentHistory
    test('Negative: constructor should throw error when prescription is empty',
        () {

      // Create an instance with an empty prescription field and expect an error    
      expect(
        () => TreatmentHistory(
          treatment: 'Physical Therapy',
          date: '2024-10-14',
          doctor: 'D12345',
          doctorName: 'Dr. Smith',
          description: 'Therapy for knee pain',
          prescription: '', // Invalid: empty
        ),
        throwsA(isA<ArgumentError>()), // Expect constructor to throw an error
      );
    });
  });
}
