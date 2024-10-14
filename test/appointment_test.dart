import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/models/appointment.dart';
import 'package:mockito/mockito.dart';

class DocumentSnapshotMock extends Mock implements DocumentSnapshot {}

void main() {
  group('Appointment Tests', () {
    // Test case 1: Positive test for converting Appointment to a Map
    test('Positive: toMap should return a Map with the correct data', () {
      final appointment = Appointment(
        doctoruid: 'doctor123',
        patientuid: 'patient456',
        date: '2023-10-14',
        time: '10:00 AM',
        status: 'Scheduled',
        paymentStatus: 'Paid',
      );

      final expectedMap = {
        'doctoruid': 'doctor123',
        'patientuid': 'patient456',
        'date': '2023-10-14',
        'time': '10:00 AM',
        'status': 'Scheduled',
        'paymentStatus': 'Paid',
      };

      expect(appointment.toMap(), expectedMap);
    });

    // // Negative test case for toMap method (missing fields)
    // test('Negative: toMap should throw an error when properties are missing', () {
    //   final appointment = Appointment(
    //     doctoruid: 'doctor123',
    //     patientuid: 'patient456',
    //     date: '2023-10-14',
    //     time: '10:00 AM',
    //     status: '', // Missing status
    //     paymentStatus: 'Paid',
    //   );

    //   // Assuming that you have validation in your constructor
    //   expect(() => appointment.toMap(), throwsA(isA<ArgumentError>()));
    // });

    // Test case 2: Positive test for fromSnapshot method
    test('Positive: fromSnapshot should create Appointment from DocumentSnapshot', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot['doctoruid']).thenReturn('doctor123');
      when(snapshot['patientuid']).thenReturn('patient456');
      when(snapshot['date']).thenReturn('2023-10-14');
      when(snapshot['time']).thenReturn('10:00 AM');
      when(snapshot['status']).thenReturn('Scheduled');
      when(snapshot['paymentStatus']).thenReturn('Paid');

      final appointment = Appointment.fromSnapshot(snapshot);

      expect(appointment.doctoruid, 'doctor123');
      expect(appointment.patientuid, 'patient456');
      expect(appointment.date, '2023-10-14');
      expect(appointment.time, '10:00 AM');
      expect(appointment.status, 'Scheduled');
      expect(appointment.paymentStatus, 'Paid');
    });

    // Negative test case for fromSnapshot method (missing fields)
    test('Negative: fromSnapshot should throw an error when required fields are missing', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot['doctoruid']).thenReturn(null); // Missing required field

      expect(() => Appointment.fromSnapshot(snapshot), throwsA(isA<TypeError>()));
    });

    // Test case 3: Positive test for fromSnapshot method with a valid date format
    test('Positive: fromSnapshot should handle valid date format', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot['doctoruid']).thenReturn('doctor123');
      when(snapshot['patientuid']).thenReturn('patient456');
      when(snapshot['date']).thenReturn('2023-10-14'); // Valid date format
      when(snapshot['time']).thenReturn('10:00 AM');
      when(snapshot['status']).thenReturn('Scheduled');
      when(snapshot['paymentStatus']).thenReturn('Paid');

      final appointment = Appointment.fromSnapshot(snapshot);

      expect(appointment.date, '2023-10-14'); // Ensures the valid date format is handled correctly
    });

    // // Negative test case for fromSnapshot method with an invalid date format
    // test('Negative: fromSnapshot should throw an error when date format is invalid', () {
    //   final snapshot = DocumentSnapshotMock();
    //   when(snapshot['doctoruid']).thenReturn('doctor123');
    //   when(snapshot['patientuid']).thenReturn('patient456');
    //   when(snapshot['date']).thenReturn('14-10-2023'); // Invalid date format
    //   when(snapshot['time']).thenReturn('10:00 AM');
    //   when(snapshot['status']).thenReturn('Scheduled');
    //   when(snapshot['paymentStatus']).thenReturn('Paid');

    //   // Assuming that you want to throw an error when the date format is invalid.
    //   expect(() => Appointment.fromSnapshot(snapshot), throwsA(isA<TypeError>()));
    // });
  });
}
