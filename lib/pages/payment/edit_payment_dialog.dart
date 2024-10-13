import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:lanka_health_care/models/payment.dart';
import 'package:lanka_health_care/services/database.dart';

class EditPaymentDialog {
  final DatabaseService database = DatabaseService();

  void show(BuildContext context, String appointmentId, Payment payment, String paymentId) {
    final TextEditingController bankNameController = TextEditingController(text: payment.bankName);
    final TextEditingController accountNumberController = TextEditingController(text: payment.accountNumber);
    final TextEditingController accountNameController = TextEditingController(text: payment.accountName);
    final TextEditingController amountController = TextEditingController(text: payment.amount);
    final TextEditingController depositSlipController = TextEditingController(text: payment.depositSlip);

    dynamic image;
    bool isImageSelected = false;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Payment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: bankNameController,
                    decoration: const InputDecoration(labelText: 'Bank Name'),
                  ),
                  TextField(
                    controller: accountNumberController,
                    decoration: const InputDecoration(labelText: 'Account Number'),
                  ),
                  TextField(
                    controller: accountNameController,
                    decoration: const InputDecoration(labelText: 'Account Name'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      image = await ImagePickerWeb.getImageAsBytes();
                      if (image != null) {
                        setState(() {
                          isImageSelected = true;
                        });
                      }
                    },
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                  if (!isImageSelected)
                    const Text(
                      'Upload slip',
                      style: TextStyle(color: Color.fromARGB(255, 250, 230, 35)),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          setState(() {
                            isUploading = true;
                          });
                          String uniqueName = DateTime.now().millisecondsSinceEpoch.toString();
                          Reference refImages = FirebaseStorage.instance.ref();
                          Reference refImagesDir = refImages.child('slip_images');
                          Reference referenceImageToUpload = refImagesDir.child('$uniqueName.jpg');
                          try {
                            await referenceImageToUpload.putData(image);
                            String downloadUrl = await referenceImageToUpload.getDownloadURL();
                            depositSlipController.text = downloadUrl;
                          } catch (e) {
                            debugPrint('Error uploading image: $e');
                          }
                          if (Navigator.of(context).canPop()) {
                            await database.editPayment(
                              appointmentId,
                              paymentId,
                              Payment(
                                bankName: bankNameController.text,
                                accountNumber: accountNumberController.text,
                                accountName: accountNameController.text,
                                amount: amountController.text,
                                date: DateTime.now().toString(),
                                depositSlip: depositSlipController.text,
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                          setState(() {
                            isUploading = false;
                          });
                        },
                  child: const Text('Edit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}