import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:lanka_health_care/models/payment.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class AddPaymentDialog {
  final DatabaseService database = DatabaseService();

  void show(BuildContext context, String appointmentId) {
    // Define controllers for the text fields
    final TextEditingController bankNameController = TextEditingController();
    final TextEditingController accountNumberController = TextEditingController();
    final TextEditingController accountNameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController depositSlipController = TextEditingController();

    // Define variables for the image and state
    dynamic image;
    bool isImageSelected = false;
    bool isUploading = false;
    final _formKey = GlobalKey<FormState>();

// Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Return the dialog with the form
            return AlertDialog(
              title: const Text(AppStrings.addPayment),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Add text form fields for the payment details
                    TextFormField(
                      controller: bankNameController,
                      decoration: const InputDecoration(labelText: AppStrings.bankName),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.pleaseEnterBankDetails;
                        }
                        return null;
                      },
                    ),
                    // Add text form fields for the payment details
                    TextFormField(
                      controller: accountNumberController,
                      decoration: const InputDecoration(labelText: AppStrings.accountNumber),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.pleaseEnterAccountNumber;
                        }
                        return null;
                      },
                    ),
                    // Add text form fields for the payment details
                    TextFormField(
                      controller: accountNameController,
                      decoration: const InputDecoration(labelText: AppStrings.accountName),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.pleaseEnterAccountName;
                        }
                        return null;
                      },
                    ),
                    // Add text form fields for the payment details
                    TextFormField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: AppStrings.amount),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.pleaseEnterAmount;
                        }
                        if (double.tryParse(value) == null) {
                          return AppStrings.pleaseEnterValidAmount;
                        }
                        return null;
                      },
                    ),
                    // Add the image picker
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
                        style: TextStyle(color: Color.fromARGB(255, 250, 230, 35)),
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
                // Add button
                TextButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isUploading = true;
                            });
                            String uniqueName = DateTime.now().millisecondsSinceEpoch.toString();
                            Reference refImages = FirebaseStorage.instance.ref();
                            Reference refImagesDir = refImages.child(AppStrings.slipImages);
                            Reference referenceImageToUpload = refImagesDir.child('$uniqueName${AppStrings.jpg}');
                            try {
                              await referenceImageToUpload.putData(image);
                              String downloadUrl = await referenceImageToUpload.getDownloadURL();
                              depositSlipController.text = downloadUrl;
                            } catch (e) {
                              debugPrint('${AppStrings.erroUploadingImage} $e');
                            }
                            if (Navigator.of(context).canPop()) {
                              await database.createPayment(
                                Payment(
                                  bankName: bankNameController.text,
                                  accountNumber: accountNumberController.text,
                                  accountName: accountNameController.text,
                                  amount: amountController.text,
                                  date: DateTime.now().toString(),
                                  depositSlip: depositSlipController.text,
                                ),
                                appointmentId,
                              );
                              Navigator.of(context).pop();
                            }
                            setState(() {
                              isUploading = false;
                            });
                          }
                        },
                  child: const Text(AppStrings.addButton),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
