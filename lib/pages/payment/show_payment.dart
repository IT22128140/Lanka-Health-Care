import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/models/payment.dart';
import 'package:lanka_health_care/services/database.dart';
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
    localPaymentStatus = widget.paymentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('View Payment'),
      content: SizedBox(
        height: 400, // Adjust the height as needed
        width: 300, // Adjust the width as needed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              items: <String>['Recurring', 'Completed', 'Pending']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  localPaymentStatus = newValue!;
                });
                database.updateAppointmentPaymentStatus(
                    widget.appointmentId, localPaymentStatus);
              },
              value: localPaymentStatus,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    database.getPaymentByAppointmentId(widget.appointmentId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No Payment found');
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
                            Text('Bank Name: ${payment.bankName}'),
                            Text('Account Number: ${payment.accountNumber}'),
                            Text('Account Name: ${payment.accountName}'),
                            Text('Amount: ${payment.amount}'),
                            Text('Date: ${payment.date}'),
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
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                    ),
                                  );
                                }
                              },
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                debugPrint('Error loading image: $error');
                                debugPrint('Stack trace: $stackTrace');
                                return const Column(
                                  children: [
                                    Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 100,
                                    ),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                );
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                EditPaymentDialog().show(context,
                                    widget.appointmentId, payment, paymentId);
                              },
                              child: const Text('Edit Payment'),
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
        TextButton(
          onPressed: () {
            database.deletePayment(widget.appointmentId, paymentId);
            database.updateAppointmentPaymentStatus(
                widget.appointmentId, 'Pending');
          },
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () {
            AddPaymentDialog().show(context, widget.appointmentId);
          },
          child: const Text('Add Payment'),
        ),
        TextButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
