import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/models/availability.dart';
import 'package:mockito/mockito.dart';

class DocumentSnapshotMock extends Mock implements DocumentSnapshot {}

void main() {
  group('Availability Class Tests', () {
    // Test Case 01 : Positive case for toMap method
    test('toMap method returns correct map', () {
      final availability = Availability(
        date: '2024-10-15',
        arrivetime: '14:00',
        leavetime: '16:00',
      );

      final map = availability.toMap();

      expect(map['date'], '2024-10-15');
      expect(map['arrivetime'], '14:00');
      expect(map['leavetime'], '16:00');
    });

   // Test Case 01 : Negative case for toMap method
    test('toMap method with null values throws error', () {
      try {
        final availability = Availability(
          date: '2024-10-15',
          arrivetime: '', // Empty string as a form of null value
          leavetime: '16:00',
        );

        availability.toMap(); // This should not throw an error
        expect(false, 'Expected to throw an error for empty arrival time');
      } catch (e) {
        expect(e, isA<AssertionError>()); // Expecting an assertion error
      }
    });

    // Test case 02: Positive case for fromSnapshot method
    test('fromSnapshot method creates Availability from DocumentSnapshot', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn({
        'date': '2024-10-15',
        'arrivetime': '14:00',
        'leavetime': '16:00',
      });

      final availability = Availability.fromSnapshot(snapshot);

      expect(availability.date, '2024-10-15');
      expect(availability.arrivetime, '14:00');
      expect(availability.leavetime, '16:00');
    });

    // Test case 02: Negative case for fromSnapshot method
    test('fromSnapshot with missing fields returns null', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn({
        // Missing 'arrivetime'
        'date': '2024-10-15',
        'leavetime': '16:00',
      });

      final availability = Availability.fromSnapshot(snapshot);

      expect(availability.arrivetime, null); // Expecting null due to missing data
    });

    // Test case 03: Positive case for Object Creation
    test('Availability object is created successfully', () {
      final availability = Availability(
        date: '2024-10-15',
        arrivetime: '14:00',
        leavetime: '16:00',
      );

      expect(availability.date, '2024-10-15');
      expect(availability.arrivetime, '14:00');
      expect(availability.leavetime, '16:00');
    });
    
    // Test case 03: Negative case for Object Creation
    test('Creating Availability with null values throws error', () {
      try {
        final availability = Availability(
          date: '2024-10-15',
          arrivetime: '', // Inserting null value
          leavetime: '16:00',
        );

        expect(false, 'Expected to throw an error for null arrival time');
      } catch (e) {
        expect(e, isA<ArgumentError>()); // Expecting an argument error due to null value
      }
    });
  });
}
