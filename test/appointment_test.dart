import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/models/appointment.dart';
import 'package:mockito/mockito.dart';

class DocumentSnapshotMock extends Mock implements DocumentSnapshot {}

void main() {
  group('Appointment Tests', () {
    // Positive Test Case 1: Creating an Appointment with valid data
    test('Positive: Creating an Appointment with valid data', () {
      final appointment = Appointment(
        doctoruid: 'doctor123',
        patientuid: 'patient456',
        date: '2024-10-14',
        time: '10:00 AM',
        status: 'Confirmed',
        paymentStatus: 'Paid',
      );

      // Check if the appointment object is created correctly
      expect(appointment.doctoruid, 'doctor123');
      expect(appointment.patientuid, 'patient456');
      expect(appointment.date, '2024-10-14');
      expect(appointment.time, '10:00 AM');
      expect(appointment.status, 'Confirmed');
      expect(appointment.paymentStatus, 'Paid');
    });

    // Positive Test Case 2: Creating an Appointment with different valid data
    test('Positive: Creating an Appointment with different valid data', () {
      final appointment = Appointment(
        doctoruid: 'doctor789',
        patientuid: 'patient012',
        date: '2024-10-15',
        time: '11:00 AM',
        status: 'Pending',
        paymentStatus: 'Not Paid',
      );

      // Check if the data is correct
      expect(appointment.doctoruid, 'doctor789');
      expect(appointment.patientuid, 'patient012');
      expect(appointment.date, '2024-10-15');
      expect(appointment.time, '11:00 AM');
      expect(appointment.status, 'Pending');
      expect(appointment.paymentStatus, 'Not Paid');
    });

    // Positive Test Case 3: toMap method returns correct map
    test('Positive: toMap should return a Map with correct data', () {
      final appointment = Appointment(
        doctoruid: 'doctor123',
        patientuid: 'patient456',
        date: '2024-10-14',
        time: '10:00 AM',
        status: 'Confirmed',
        paymentStatus: 'Paid',
      );
      
      // Expected Map
      final expectedMap = {
        'doctoruid': 'doctor123',
        'patientuid': 'patient456',
        'date': '2024-10-14',
        'time': '10:00 AM',
        'status': 'Confirmed',
        'paymentStatus': 'Paid',
      };

      // Compare the expected map with the actual map
      expect(appointment.toMap(), expectedMap);
    });

    // Negative Test Case 1: Creating an Appointment with an empty doctoruid
    test('Negative: Creating an Appointment should throw an error when doctoruid is empty', () {
      expect(() => Appointment(
        doctoruid: '',
        patientuid: 'patient456',
        date: '2024-10-14',
        time: '10:00 AM',
        status: 'Confirmed',
        paymentStatus: 'Paid',
      ), throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Doctor UID cannot be empty')));
    });

    // Negative Test Case 2: Creating an Appointment with an empty date
    test('Negative: Creating an Appointment should throw an error when date is empty', () {
      expect(() => Appointment(
        doctoruid: 'doctor123',
        patientuid: 'patient456',
        date: '',
        time: '10:00 AM',
        status: 'Confirmed',
        paymentStatus: 'Paid',
      ), throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Date cannot be empty')));
    });

    // Negative Test Case 3: Creating an Appointment with an empty paymentStatus
    test('Negative: Creating an Appointment should throw an error when paymentStatus is empty', () {
      expect(() => Appointment(
        doctoruid: 'doctor123',
        patientuid: 'patient456',
        date: '2024-10-14',
        time: '10:00 AM',
        status: 'Confirmed',
        paymentStatus: '',
      ), throwsA(isA<ArgumentError>().having((e) => e.message, 'message', 'Payment Status cannot be empty')));
    });
  });
}
