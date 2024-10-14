import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String amount;
  final String date;
  final String depositSlip;

  Payment(
      {required this.bankName,
      required this.accountNumber,
      required this.accountName,
      required this.amount,
      required this.date,
      required this.depositSlip});

  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'amount': amount,
      'date': date,
      'depositSlip': depositSlip,
    };
  }

  factory Payment.fromSnapshot(DocumentSnapshot snapshot) {
    return Payment(
      bankName: snapshot['bankName'],
      accountNumber: snapshot['accountNumber'],
      accountName: snapshot['accountName'],
      amount: snapshot['amount'],
      date: snapshot['date'],
      depositSlip: snapshot['depositSlip'],
    );
  }

  bool isValid() {
    return _isValidBankName(bankName) &&
        _isValidAccountNumber(accountNumber) &&
        _isValidAccountName(accountName) &&
        _isValidAmount(amount) &&
        _isValidDate(date) &&
        _isValidDepositSlip(depositSlip);
  }

  bool _isValidBankName(String bankName) {
    return bankName.isNotEmpty;
  }

  bool _isValidAccountNumber(String accountNumber) {
    return accountNumber.isNotEmpty && accountNumber.length == 10;
  }

  bool _isValidAccountName(String accountName) {
    return accountName.isNotEmpty;
  }

  bool _isValidAmount(String amount) {
    return double.tryParse(amount) != null && double.parse(amount) > 0;
  }

  bool _isValidDate(String date) {
    // Add your date validation logic here
    return date.isNotEmpty;
  }

  bool _isValidDepositSlip(String depositSlip) {
    return depositSlip.isNotEmpty;
  }
}