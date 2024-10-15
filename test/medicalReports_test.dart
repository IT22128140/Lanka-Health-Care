import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:lanka_health_care/models/medical_reports.dart';

class DocumentSnapshotMock extends Mock implements DocumentSnapshot {}

void main() {
  group('MedicalReports Tests', () {
    // Test case 1: Positive test case for mapping MedicalReports
    test('Positive: toMap should return a Map with the correct data', () {
      final medicalReports = MedicalReports(
        allergies: 'Pollen',
        medications: 'Paracetamol',
        surgeries: 'Appendectomy',
      );

      // Expected map
      final expectedMap = {
        'allergies': 'Pollen',
        'medications': 'Paracetamol',
        'surgeries': 'Appendectomy',
      };

      // Compare the expected map with the actual map
      expect(medicalReports.toMap(), expectedMap);
    });

    // Test case 2: Positive test case for fromSnapshot method
    test('Positive: fromSnapshot should create MedicalReports from DocumentSnapshot', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn({
        'allergies': 'Pollen',
        'medications': 'Paracetamol',
        'surgeries': 'Appendectomy',
      });

      final medicalReports = MedicalReports.fromSnapshot(snapshot);

      expect(medicalReports.allergies, 'Pollen');
      expect(medicalReports.medications, 'Paracetamol');
      expect(medicalReports.surgeries, 'Appendectomy');
    });

    // Test case 3: Negative test for fromSnapshot method with missing fields
    test('Negative: fromSnapshot should throw an error when fields are missing', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn({
        'allergies': 'Pollen',
        // 'medications' is missing
        'surgeries': 'Appendectomy',
      });

      expect(
        () => MedicalReports.fromSnapshot(snapshot),
        throwsA(isA<Error>()), // Expect an error due to missing fields
      );
    });

    // Test case 4: Negative test for fromSnapshot method with null values
    test('Negative: fromSnapshot should throw an error when any value is null', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn({
        'allergies': null,  // Null value
        'medications': 'Paracetamol',
        'surgeries': 'Appendectomy',
      });

      expect(
        () => MedicalReports.fromSnapshot(snapshot),
        throwsA(isA<TypeError>()), // Expect TypeError due to null
      );
    });
  });
}
