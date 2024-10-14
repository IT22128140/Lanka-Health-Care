import 'package:flutter_test/flutter_test.dart';
import 'package:lanka_health_care/models/payment.dart';

void main() {
  group('Payment toMap,Payment Field Validations,Payment Date Formattting', () {
    //Test Case 1 : Positive test case for toMap method
    test('Positive Case: Correctly converts to map', () {
      final payment = Payment(
        bankName: 'Test Bank',
        accountNumber: '1234567890',
        accountName: 'John Doe',
        amount: '100.00',
        date: '2023-10-14',
        depositSlip: 'slip.jpg',
      );

      final map = payment.toMap();

      expect(map, {
        'bankName': 'Test Bank',
        'accountNumber': '1234567890',
        'accountName': 'John Doe',
        'amount': '100.00',
        'date': '2023-10-14',
        'depositSlip': 'slip.jpg',
      });
    });

    //Test Case 1 : Negative test case for toMap method
    test('Negative Case: Map is incorrect if a field is null', () {
      final payment = Payment(
        bankName: '',
        accountNumber: '',
        accountName: 'John Doe',
        amount: '',
        date: '2023-10-14',
        depositSlip: 'slip.jpg',
      );

      final map = payment.toMap();

      expect(map['bankName'], isEmpty);
      expect(map['accountNumber'], isEmpty);
      expect(map['amount'], isEmpty);
    });

    //Test Case 2 : Positive test case for field validations
    test('Positive Case: All fields are not-null and correctly assigned', () {
      final payment = Payment(
        bankName: 'Test Bank',
        accountNumber: '1234567890',
        accountName: 'John Doe',
        amount: '100.00',
        date: '2023-10-14',
        depositSlip: 'slip.jpg',
      );

      expect(payment.bankName, isNotEmpty);
      expect(payment.accountNumber, isNotEmpty);
      expect(payment.amount, isNotEmpty);
      expect(payment.date, isNotEmpty);
      expect(payment.depositSlip, isNotEmpty);
    });

    //Test Case 2 : Negative test case for field validations
    test('Negative Case: Fields with empty strings fail validation', () {
      final payment = Payment(
        bankName: '',
        accountNumber: '',
        accountName: 'John Doe',
        amount: '',
        date: '2023-10-14',
        depositSlip: 'slip.jpg',
      );

      expect(payment.bankName, isEmpty);
      expect(payment.accountNumber, isEmpty);
      expect(payment.amount, isEmpty);
    });

    //Test Case 3 : Positive test case for date formatting
     test('Positive Case: Valid date should be formatted correctly', () {
      final payment = Payment(
        bankName: 'Test Bank',
        accountNumber: '1234567890',
        accountName: 'John Doe',
        amount: '100.00',
        date: '2023-10-14', // Valid date format
        depositSlip: 'slip.jpg',
      );
      expect(payment.date, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$'))); // YYYY-MM-DD
    });

    //Test Case 3 : Negative test case for date formatting
    // test('Negative Case: Invalid date format should throw an error', () {
    //   expect(
    //     () => Payment(
    //       bankName: 'Test Bank',
    //       accountNumber: '1234567890',
    //       accountName: 'John Doe',
    //       amount: '100.00',
    //       date: 'Invalid Date', // Invalid date format
    //       depositSlip: 'slip.jpg',
    //     ),
    //     throwsA(isA<FormatException>()), // Assuming you throw an error for invalid date
    //   );
    // });
  });
}
