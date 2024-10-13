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
}