import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:lanka_health_care/models/payment.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class EditPaymentDialog {
  final DatabaseService database = DatabaseService();

  void show(BuildContext context, String appointmentId, Payment payment,
      String paymentId) {
        // Define controllers for the text fields
    final TextEditingController bankNameController =
        TextEditingController(text: payment.bankName);
    final TextEditingController accountNumberController =
        TextEditingController(text: payment.accountNumber);
    final TextEditingController accountNameController =
        TextEditingController(text: payment.accountName);
    final TextEditingController amountController =
        TextEditingController(text: payment.amount);
    final TextEditingController depositSlipController =
        TextEditingController(text: payment.depositSlip);

// Define variables for the image and state
    dynamic image;
    bool isImageSelected = false;
    bool isUploading = false;

    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Return the dialog with the form
            return AlertDialog(
              title: const Text(AppStrings.editPayment),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Add text form fields for the payment details
                    TextFormField(
                      controller: bankNameController,
                      decoration:
                          const InputDecoration(labelText: AppStrings.bankName),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.banktypeValidation;
                        }
                        return null;
                      },
                    ),
                    // Add text form fields for the payment details
                    TextFormField(
                      controller: accountNumberController,
                      decoration: const InputDecoration(
                          labelText: AppStrings.accountNumber),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.accountNumberValidation;
                        }
                        return null;
                      },
                    ),
                    // Add text form fields for the payment details
                    TextFormField(
                      controller: accountNameController,
                      decoration: const InputDecoration(
                          labelText: AppStrings.accountName),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.accountNameValidation;
                        }
                        return null;
                      },
                    ),
                    // Add text form fields for the payment details
                    TextFormField(
                      controller: amountController,
                      decoration:
                          const InputDecoration(labelText: AppStrings.amount),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.amountValidation;
                        }
                        return null;
                      },
                    ),
                    // Add text form fields for the payment details
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
                        AppStrings.uploadSlip,
                        style:
                            TextStyle(color: Color.fromARGB(255, 250, 230, 35)),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                // Cancel button
                TextButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(AppStrings.cancelButton),
                ),
                // Edit button
                TextButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isUploading = true;
                            });
                            String uniqueName = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                            Reference refImages =
                                FirebaseStorage.instance.ref();
                            Reference refImagesDir =
                                refImages.child(AppStrings.slipImages);
                            Reference referenceImageToUpload = refImagesDir
                                .child('$uniqueName${AppStrings.jpg}');
                            try {
                              await referenceImageToUpload.putData(image);
                              String downloadUrl =
                                  await referenceImageToUpload.getDownloadURL();
                              depositSlipController.text = downloadUrl;
                            } catch (e) {
                              debugPrint('${AppStrings.erroUploadingImage} $e');
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
                          }
                        },
                  child: const Text(AppStrings.editButton),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
