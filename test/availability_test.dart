import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/models/availability.dart';
import 'package:mockito/mockito.dart';

class DocumentSnapshotMock extends Mock implements DocumentSnapshot {}

void main() {
  group('Availability Class Tests', () {
    // Test for object creation with valid data
    test('Availability object is created successfully with valid data', () {
      final availability = Availability(
        date: '2024-10-14',
        arrivetime: '09:00',
        leavetime: '17:00',
      );

      expect(availability.date, '2024-10-14');
      expect(availability.arrivetime, '09:00');
      expect(availability.leavetime, '17:00');
    });

    // Test for empty date
    test('Availability constructor throws error for empty date', () {
      expect(() {
        Availability(
          date: '', // Empty date
          arrivetime: '09:00',
          leavetime: '17:00',
        );
      }, throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Date cannot be empty')));
    });

    // Test for empty arrival time
    test('Availability constructor throws error for empty arrival time', () {
      expect(() {
        Availability(
          date: '2024-10-14',
          arrivetime: '', // Empty arrival time
          leavetime: '17:00',
        );
      }, throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Arrival time cannot be empty')));
    });

    // Test for empty leave time
    test('Availability constructor throws error for empty leave time', () {
      expect(() {
        Availability(
          date: '2024-10-14',
          arrivetime: '09:00',
          leavetime: '', // Empty leave time
        );
      }, throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Leave time cannot be empty')));
    });

    // Test for fromSnapshot method
    test('fromSnapshot method creates Availability from DocumentSnapshot', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot.data()).thenReturn({
        'date': '2024-10-14',
        'arrivetime': '09:00',
        'leavetime': '17:00',
      });

      final availability = Availability.fromSnapshot(snapshot);

      expect(availability.date, '2024-10-14');
      expect(availability.arrivetime, '09:00');
      expect(availability.leavetime, '17:00');
    });

    // Test for toMap method
    test('toMap method returns correct map', () {
      final availability = Availability(
        date: '2024-10-14',
        arrivetime: '09:00',
        leavetime: '17:00',
      );

      final map = availability.toMap();

      expect(map['date'], '2024-10-14');
      expect(map['arrivetime'], '09:00');
      expect(map['leavetime'], '17:00');
    });
  });
}
