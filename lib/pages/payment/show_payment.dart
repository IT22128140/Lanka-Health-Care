import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/models/payment.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';
import 'add_payment_dialog.dart';
import 'edit_payment_dialog.dart';

class ViewPaymentDialog extends StatefulWidget {
  final String appointmentId;
  final String paymentStatus;

  const ViewPaymentDialog(
      {super.key, required this.appointmentId, required this.paymentStatus});

  @override
  _ViewPaymentDialogState createState() => _ViewPaymentDialogState();
}

class _ViewPaymentDialogState extends State<ViewPaymentDialog> {
  final DatabaseService database = DatabaseService();
  var paymentId;
  var payment;
  late String localPaymentStatus;

  @override
  void initState() {
    super.initState();
    // Initialize localPaymentStatus with the value passed from the parent widget
    localPaymentStatus = widget.paymentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.viewPayment),
      content: SizedBox(
        height: 400,
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown to select payment status
            DropdownButton<String>(
              items: <String>[
                AppStrings.recurring,
                AppStrings.completed,
                AppStrings.pending
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  localPaymentStatus = newValue!;
                });
                // Update payment status in the database
                database.updateAppointmentPaymentStatus(
                    widget.appointmentId, localPaymentStatus);
              },
              value: localPaymentStatus,
            ),
            Expanded(
              // StreamBuilder to fetch and display payment details
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    database.getPaymentByAppointmentId(widget.appointmentId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('${AppStrings.error} ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text(AppStrings.noPaymentFound);
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final documentSnapshot = snapshot.data!.docs[index];
                        paymentId = documentSnapshot.id;
                        payment = Payment.fromSnapshot(documentSnapshot);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display payment details
                            Text(
                                '${AppStrings.colonbankName} ${payment.bankName}'),
                            Text(
                                '${AppStrings.colonaccountNumber} ${payment.accountNumber}'),
                            Text(
                                '${AppStrings.colonaccountName} ${payment.accountName}'),
                            Text('${AppStrings.colonamount} ${payment.amount}'),
                            Text('${AppStrings.colondate} ${payment.date}'),
                            // Display deposit slip image
                            Image.network(
                              payment.depositSlip,
                              width: 100,
                              height: 100,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ?? 1)
                                              : null,
                                    ),
                                  );
                                }
                              },
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                debugPrint(
                                    '${AppStrings.errLoadingImage} $error');
                                debugPrint(
                                    '${AppStrings.stackTrace} $stackTrace');
                                return const Column(
                                  children: [
                                    Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 100,
                                    ),
                                    Text(
                                      AppStrings.failedLoadImage,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                );
                              },
                            ),
                            // Button to edit payment details
                            TextButton(
                              onPressed: () {
                                EditPaymentDialog().show(context,
                                    widget.appointmentId, payment, paymentId);
                              },
                              child: const Text(AppStrings.editPayment),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        // Button to delete payment
        TextButton(
          onPressed: () {
            database.deletePayment(widget.appointmentId, paymentId);
            database.updateAppointmentPaymentStatus(
                widget.appointmentId, AppStrings.pending);
          },
          child: const Text(AppStrings.deleteButton),
        ),
        // Button to add new payment
        TextButton(
          onPressed: () {
            AddPaymentDialog().show(context, widget.appointmentId);
          },
          child: const Text(AppStrings.addPayment),
        ),
        // Button to close the dialog
        TextButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: const Text(AppStrings.close),
        ),
      ],
    );
  }
}
