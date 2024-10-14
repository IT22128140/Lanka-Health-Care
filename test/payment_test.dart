import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/models/payment.dart';
import 'package:mockito/mockito.dart';

class DocumentSnapshotMock extends Mock implements DocumentSnapshot {}

void main() {
  group('Payment Class Tests', () {
    // Test for toMap method
    test('toMap method returns correct map', () {
      final payment = Payment(
        bankName: 'Bank of Flutter',
        accountNumber: '1234567890',
        accountName: 'John Doe',
        amount: '100.50',
        date: '2024-10-14',
        depositSlip: 'slip123.png',
      );

      final map = payment.toMap();

      expect(map['bankName'], 'Bank of Flutter');
      expect(map['accountNumber'], '1234567890');
      expect(map['accountName'], 'John Doe');
      expect(map['amount'], '100.50');
      expect(map['date'], '2024-10-14');
      expect(map['depositSlip'], 'slip123.png');
    });

    // Test for fromSnapshot method
    test('fromSnapshot method creates Payment from DocumentSnapshot', () {
      final snapshot = DocumentSnapshotMock();
      when(snapshot['bankName']).thenReturn('Bank of Flutter');
      when(snapshot['accountNumber']).thenReturn('1234567890');
      when(snapshot['accountName']).thenReturn('John Doe');
      when(snapshot['amount']).thenReturn('100.50');
      when(snapshot['date']).thenReturn('2024-10-14');
      when(snapshot['depositSlip']).thenReturn('slip123.png');

      final payment = Payment.fromSnapshot(snapshot);

      expect(payment.bankName, 'Bank of Flutter');
      expect(payment.accountNumber, '1234567890');
      expect(payment.accountName, 'John Doe');
      expect(payment.amount, '100.50');
      expect(payment.date, '2024-10-14');
      expect(payment.depositSlip, 'slip123.png');
    });

    // Test for isValid method
    test('isValid returns true for valid payment details', () {
      final payment = Payment(
        bankName: 'Bank of Flutter',
        accountNumber: '1234567890',
        accountName: 'John Doe',
        amount: '100.50',
        date: '2024-10-14',
        depositSlip: 'slip123.png',
      );

      expect(payment.isValid(), true); // Expecting valid payment details to return true
    });

    test('isValid returns false for invalid account number', () {
      final payment = Payment(
        bankName: 'Bank of Flutter',
        accountNumber: '123', // Invalid account number
        accountName: 'John Doe',
        amount: '100.50',
        date: '2024-10-14',
        depositSlip: 'slip123.png',
      );

      expect(payment.isValid(), false); // Expecting invalid account number to return false
    });

    test('isValid returns false for empty bank name', () {
      final payment = Payment(
        bankName: '', // Empty bank name
        accountNumber: '1234567890',
        accountName: 'John Doe',
        amount: '100.50',
        date: '2024-10-14',
        depositSlip: 'slip123.png',
      );

      expect(payment.isValid(), false); // Expecting empty bank name to return false
    });

    test('isValid returns false for negative amount', () {
      final payment = Payment(
        bankName: 'Bank of Flutter',
        accountNumber: '1234567890',
        accountName: 'John Doe',
        amount: '-100.50', // Negative amount
        date: '2024-10-14',
        depositSlip: 'slip123.png',
      );

      expect(payment.isValid(), false); // Expecting negative amount to return false
    });

    test('isValid returns false for empty deposit slip', () {
      final payment = Payment(
        bankName: 'Bank of Flutter',
        accountNumber: '1234567890',
        accountName: 'John Doe',
        amount: '100.50',
        date: '2024-10-14',
        depositSlip: '', // Empty deposit slip
      );

      expect(payment.isValid(), false); // Expecting empty deposit slip to return false
    });
  });
}
