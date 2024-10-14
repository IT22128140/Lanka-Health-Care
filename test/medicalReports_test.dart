import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/models/medical_reports.dart';
import 'package:mockito/mockito.dart';

class DocumentSnapshotMock extends Mock implements DocumentSnapshot {}

void main() {
  group('MedicalReports Tests', () {
    // Test case 1: Positive test for mapping MedicalReports
    test('Positive: toMap should return a Map with the correct data', () {
      final medicalReports = MedicalReports(
        allergies: 'Peanuts',
        medications: 'Ibuprofen',
        surgeries: 'Appendectomy',
      );

      final expectedMap = {
        'allergies': 'Peanuts',
        'medications': 'Ibuprofen',
        'surgeries': 'Appendectomy',
      };

      expect(medicalReports.toMap(), expectedMap);
    });

  

    // Test case 3: Positive test for fromSnapshot method
    test('Positive: fromSnapshot should create MedicalReports from DocumentSnapshot', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn({
        'allergies': 'Peanuts',
        'medications': 'Ibuprofen',
        'surgeries': 'Appendectomy',
      });

      final medicalReports = MedicalReports.fromSnapshot(snapshot);

      expect(medicalReports.allergies, 'Peanuts');
      expect(medicalReports.medications, 'Ibuprofen');
      expect(medicalReports.surgeries, 'Appendectomy');
    });

    // Test case 4: Negative test for fromSnapshot method with missing data
    test('Negative: fromSnapshot should throw an error when data is missing', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn({
        'allergies': 'Peanuts',
        'medications': 'Ibuprofen',
        // 'surgeries' is missing
      });

      // Expecting that missing fields will cause a runtime error
      expect(
        () => MedicalReports.fromSnapshot(snapshot),
        throwsA(isA<TypeError>()), // Adjust based on your implementation of MedicalReports
      );
    });

    // Test case 5: Negative test for fromSnapshot method with incorrect data type
    test('Negative: fromSnapshot should throw an error when data types are incorrect', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn({
        'allergies': 123, // Invalid data type
        'medications': 'Ibuprofen',
        'surgeries': 'Appendectomy',
      });

      // Expecting that incorrect data types will cause a runtime error
      expect(
        () => MedicalReports.fromSnapshot(snapshot),
        throwsA(isA<TypeError>()), // Adjust based on your implementation of MedicalReports
      );
    });

    // Test case 6: Positive test for fromSnapshot method with default values
    test('Positive: fromSnapshot should set default values when fields are null', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn({
        'allergies': null,
        'medications': null,
        'surgeries': null,
      });

      final medicalReports = MedicalReports.fromSnapshot(snapshot);

      expect(medicalReports.allergies, isNull); // Assuming your model handles nulls correctly
      expect(medicalReports.medications, isNull);
      expect(medicalReports.surgeries, isNull);
    });
  });
}
