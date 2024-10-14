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

      expect(treatmentHistory.toMap(), expectedMap);
    });

    test(
        'Positive: fromSnapshot should create TreatmentHistory from valid DocumentSnapshot',
        () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn({
        'treatment': 'Physical Therapy',
        'date': '2024-10-14',
        'doctor': 'D12345',
        'doctorName': 'Dr. Smith',
        'description': 'Therapy for knee pain',
        'prescription': 'Exercise regimen',
      });

      final treatmentHistory = TreatmentHistory.fromSnapshot(snapshot);

      expect(treatmentHistory.treatment, 'Physical Therapy');
      expect(treatmentHistory.date, '2024-10-14');
      expect(treatmentHistory.doctor, 'D12345');
      expect(treatmentHistory.doctorName, 'Dr. Smith');
      expect(treatmentHistory.description, 'Therapy for knee pain');
      expect(treatmentHistory.prescription, 'Exercise regimen');
    });

    test('Positive: validate should return true for valid TreatmentHistory',
        () {
      final treatmentHistory = TreatmentHistory(
        treatment: 'Physical Therapy',
        date: '2024-10-14',
        doctor: 'D12345',
        doctorName: 'Dr. Smith',
        description: 'Therapy for knee pain',
        prescription: 'Exercise regimen',
      );

      expect(treatmentHistory.validate(), isTrue);
    });

    // Negative test cases
    test('Negative: constructor should throw error when treatment is empty',
        () {
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

    test('Negative: fromSnapshot should throw error when fields are missing',
        () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn({
        'treatment': 'Physical Therapy',
        'date': '2024-10-14',
        // Missing doctor field
        'doctorName': 'Dr. Smith',
        'description': 'Therapy for knee pain',
        'prescription': 'Exercise regimen',
      });

      expect(
        () => TreatmentHistory.fromSnapshot(snapshot),
        throwsA(
            isA<ArgumentError>()), // Expect ArgumentError for missing fields
      );
    });

    test('Negative: constructor should throw error when prescription is empty',
        () {
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
