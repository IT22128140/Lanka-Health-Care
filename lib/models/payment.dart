import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/shared/constants.dart';

class Payment {
  // Fields to store payment details
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String amount;
  final String date;
  final String depositSlip;

  // Constructor to initialize the Payment object with required fields
  Payment(
      {required this.bankName,
      required this.accountNumber,
      required this.accountName,
      required this.amount,
      required this.date,
      required this.depositSlip});

 // Converts the Payment object to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      AppStrings.bankname: bankName, // Bank name field
      AppStrings.accnumber: accountNumber, // Account number field
      AppStrings.accname: accountName,  // Account name field
      AppStrings.amt: amount, // Payment amount field
      AppStrings.date: date, // Date field
      AppStrings.depositSlip: depositSlip, // Deposit slip field
    };
  }

 // Factory method to create a Payment object from a Firestore DocumentSnapshot
  factory Payment.fromSnapshot(DocumentSnapshot snapshot) {
    return Payment(
      bankName: snapshot[AppStrings.bankname], // Extract bank name from snapshot
      accountNumber: snapshot[AppStrings.accnumber], // Extract account number from snapshot
      accountName: snapshot[AppStrings.accname], // Extract account name from snapshot
      amount: snapshot[AppStrings.amt],  // Extract payment amount from snapshot
      date: snapshot[AppStrings.date], // Extract date from snapshot
      depositSlip: snapshot[AppStrings.depositSlip], // Extract deposit slip from snapshot
    );
  }

 // Method to validate the Payment object based on several conditions
  bool isValid() {
    return _isValidBankName(bankName) && // Validate bank name
        _isValidAccountNumber(accountNumber) && // Validate account number
        _isValidAccountName(accountName) && // Validate account name
        _isValidAmount(amount) && // Validate amount
        _isValidDate(date) && // Validate date
        _isValidDepositSlip(depositSlip); // Validate deposit slip
  }

 // Checks if the bank name is valid (non-empty)
  bool _isValidBankName(String bankName) {
    return bankName.isNotEmpty;
  }

  // Checks if the account number is valid (non-empty and exactly 10 characters long)
  bool _isValidAccountNumber(String accountNumber) {
    return accountNumber.isNotEmpty && accountNumber.length == 10;
  }

  // Checks if the account name is valid (non-empty)
  bool _isValidAccountName(String accountName) {
    return accountName.isNotEmpty;
  }

 // Checks if the amount is valid (parses to a non-negative number)
  bool _isValidAmount(String amount) {
    return double.tryParse(amount) != null && double.parse(amount) > 0;
  }

  // Checks if the date is valid (add further validation if needed)
  bool _isValidDate(String date) {
    // Add your date validation logic here
    return date.isNotEmpty;
  }

  // Checks if the deposit slip is valid (non-empty)
  bool _isValidDepositSlip(String depositSlip) {
    return depositSlip.isNotEmpty;
  }
}