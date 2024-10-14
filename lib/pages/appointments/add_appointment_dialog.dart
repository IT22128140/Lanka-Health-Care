import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:lanka_health_care/models/appointment.dart';
import 'package:lanka_health_care/models/payment.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class AddAppointmentDialog {
  // Database service instance to access the database functions
  final DatabaseService databaseService = DatabaseService();

  void showAddAppointmentDialogue(
      // Show the add appointment dialog
      BuildContext context,
      String doctorId,
      dynamic availability) {
    // Text editing controller for the patient name
    final TextEditingController patient = TextEditingController();
    // Patient uid controller to store the patient uid
    final TextEditingController patientuidController = TextEditingController();
    // Date controller to store the selected date
    final TextEditingController dateController = TextEditingController();
    // Bank name controller to store the bank name
    final TextEditingController bankNameController = TextEditingController();
    // Account number controller to store the account number
    final TextEditingController accountNumberController =
        TextEditingController();
    // Account name controller to store the account name
    final TextEditingController accountNameController = TextEditingController();
    // Amount controller to store the amount
    final TextEditingController amountController = TextEditingController();
    // Deposit slip controller to store the deposit slip
    final TextEditingController depositSlipController = TextEditingController();
    // Payment status controller to store the payment status
    final TextEditingController paymentStatusController =
        TextEditingController();

    // Image variable to store the selected image
    dynamic image;
    // Boolean variable to check whether an image is selected
    bool isImageSelected = false;
    // Boolean variable to check whether the image is uploading
    bool isUploading = false;

    final _formKey = GlobalKey<FormState>(); // Form key for validations

    // Convert the available day strings into corresponding weekday numbers
    List<int> getAvailableWeekdays(dynamic availableDays) {
      Map<String, int> daysOfWeek = {
        AppStrings.sunday: DateTime.sunday,
        AppStrings.monday: DateTime.monday,
        AppStrings.tuesday: DateTime.tuesday,
        AppStrings.wednesday: DateTime.wednesday,
        AppStrings.thursday: DateTime.thursday,
        AppStrings.friday: DateTime.friday,
        AppStrings.saturday: DateTime.saturday,
      };

      if (availableDays is String) {
        // Check if the available days are a string or a list
        return [daysOfWeek[availableDays]!]; // Return the weekday number
      } else if (availableDays is List<String>) {
        // If the available days are a list
        return availableDays
            .map((day) => daysOfWeek[day]!)
            .toList(); // Return the weekday numbers
      }
      return []; // Return an empty list if the available days are not a string or a list
    }

    // Find the next available date based on the allowed weekdays
    DateTime _getNextAvailableDate(List<int> availableWeekdays) {
      // Get the current date and time
      DateTime now = DateTime.now();

      // Loop until the current weekday is in the available weekdays list
      while (!availableWeekdays.contains(now.weekday)) {
        now = now.add(const Duration(days: 1));
      }
      return now; // Return the next available date
    }

    // Show the dialog
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            // Show the alert dialog
            title: const Text(
                AppStrings.addAppointment), // Set the title of the dialog
            content: Form(
              // Wrap content with Form widget
              key: _formKey,
              child: SingleChildScrollView(
                // Wrap content with SingleChildScrollView widget
                child: Column(
                  children: [
                    Text(availability[
                        AppStrings.date]), // Show the available date
                    Text(availability[
                        AppStrings.arrivetime]), // Show the available time
                    Autocomplete<Map<String, dynamic>>(
                      // Show the autocomplete widget
                      optionsBuilder:
                          (TextEditingValue textEditingValue) async {
                        // Options builder function
                        if (textEditingValue.text.isEmpty) {
                          // Check if the text is empty
                          return const Iterable<
                              Map<String,
                                  dynamic>>.empty(); // Return an empty iterable
                        }
                        final patientList =
                            await databaseService.getPatientNamesByFirstName(
                                textEditingValue.text); // Get the patient names
                        return patientList.where((patient) {
                          // Filter the patient names
                          return (patient[AppStrings.patientfirstName] ??
                                  '') // Check if the patient name contains the text
                              .toLowerCase() // Convert to lowercase
                              .contains(textEditingValue.text
                                  .toLowerCase()); // Check if the text contains the patient name
                        }).map((doctor) => {
                              // Map the patient names
                              AppStrings.docID: doctor[AppStrings.docID] ??
                                  '', // Get the patient id
                              AppStrings.doctorFirstNameLabel:
                                  doctor[AppStrings.doctorFirstNameLabel] ??
                                      '', // Get the patient first name
                              AppStrings.doctorLastNameLabel:
                                  doctor[AppStrings.doctorLastNameLabel] ??
                                      '', // Get the patient last name
                            });
                      },
                      // Display the patient name
                      displayStringForOption: (Map<String, dynamic> option) =>
                          (option[AppStrings.patientfirstName] ?? '') +
                          ' ' +
                          (option[AppStrings.patientlastName] ??
                              ''), // Get the patient name
                      onSelected: (Map<String, dynamic> selection) {
                        patient.text =
                            (selection[AppStrings.patientfirstName] ?? '') +
                                ' ' +
                                (selection[AppStrings.patientlastName] ??
                                    ''); // Set the patient name
                        patientuidController.text =
                            selection[AppStrings.patientID] ??
                                ''; // Set the patient id
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        // Field view builder function
                        return TextFormField(
                          // Return a text form field
                          controller:
                              textEditingController, // Set the controller
                          focusNode: focusNode, // Set the focus node
                          decoration: const InputDecoration(
                              // Set the decoration
                              labelText:
                                  AppStrings.patient), // Set the label text
                          validator: (value) {
                            // Set the validator
                            return value == null ||
                                    value.isEmpty // Check if the value is empty
                                ? AppStrings
                                    .patientValidation // Return the validation message
                                : null; // Return null if the value is not empty
                          },
                        );
                      },
                    ),
                    TextFormField(
                      // Text form field for the date
                      controller: dateController, // Set the controller
                      decoration: const InputDecoration(
                          hintText: AppStrings.dateLabel), // Set the decoration
                      onTap: () async {
                        // Set the on tap function
                        FocusScope.of(context)
                            .requestFocus(FocusNode()); // Request focus
                        List<int> availableWeekdays = getAvailableWeekdays(
                            availability[
                                AppStrings.date]); // Get the available weekdays

                        DateTime initialDate = _getNextAvailableDate(
                            availableWeekdays); // Get the next available date

                        DateTime? pickedDate = await showDatePicker(
                          // Show the date picker
                          context: context, // Set the context
                          initialDate: initialDate, // Set the initial date
                          firstDate: DateTime.now(), // Set the first date
                          lastDate: DateTime(2101), // Set the last date
                          selectableDayPredicate: (DateTime date) { // Set the selectable day predicate
                            return availableWeekdays.contains(date.weekday); // Check if the date is in the available weekdays
                          },
                        );

                        if (pickedDate != null) { 
                          dateController.text =
                              "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                        }
                      },
                      validator: (value) {
                        return value == null || value.isEmpty
                            ? AppStrings.dateValidation
                            : null;
                      },
                    ),
                    DropdownButtonFormField(
                      items: const [
                        DropdownMenuItem(
                            value: AppStrings.recurring,
                            child: Text(AppStrings.recurring)),
                        DropdownMenuItem(
                            value: AppStrings.completed,
                            child: Text(AppStrings.completed)),
                        DropdownMenuItem(
                            value: AppStrings.pending,
                            child: Text(AppStrings.pending)),
                      ],
                      value: paymentStatusController.text.isEmpty
                          ? AppStrings.recurring
                          : ([
                              AppStrings.recurring,
                              AppStrings.completed,
                              AppStrings.pending
                            ].contains(paymentStatusController.text)
                              ? paymentStatusController.text
                              : AppStrings.recurring),
                      onChanged: (value) {
                        paymentStatusController.text = value.toString();
                      },
                    ),
                    const Text(AppStrings.payment,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: bankNameController,
                      decoration:
                          const InputDecoration(hintText: AppStrings.bankName),
                      validator: (value) {
                        return value == null || value.isEmpty
                            ? AppStrings.banktypeValidation
                            : null;
                      },
                    ),
                    TextFormField(
                      controller: accountNumberController,
                      decoration: const InputDecoration(
                          hintText: AppStrings.accountNumber),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.accountNumberNullError;
                        }
                        final num? accountNumber = num.tryParse(value);
                        if (accountNumber == null || accountNumber <= 0) {
                          return AppStrings.accountNumberValidation;
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: accountNameController,
                      decoration: const InputDecoration(
                          hintText: AppStrings.accountName),
                      validator: (value) {
                        return value == null || value.isEmpty
                            ? AppStrings.accountNameValidation
                            : null;
                      },
                    ),
                    TextFormField(
                      controller: amountController,
                      decoration:
                          const InputDecoration(hintText: AppStrings.amount),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.amountNullError;
                        }
                        final num? amount = num.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return AppStrings.amountValidation;
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        image = await ImagePickerWeb.getImageAsBytes();
                        if (image != null) {
                          isImageSelected = true;
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
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(AppStrings.cancelButton)),
              TextButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate() &&
                              isImageSelected) {
                            isUploading = true;
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
                            if (context.mounted) {
                              await databaseService.createAppointmentAndPayment(
                                  Appointment(
                                    doctoruid: doctorId,
                                    patientuid: patientuidController.text,
                                    date: dateController.text,
                                    time: availability[AppStrings.arrivetime],
                                    status: AppStrings.pending,
                                    paymentStatus: paymentStatusController.text,
                                  ),
                                  Payment(
                                    bankName: bankNameController.text,
                                    accountNumber: accountNumberController.text,
                                    accountName: accountNameController.text,
                                    amount: amountController.text,
                                    date: dateController.text,
                                    depositSlip: depositSlipController.text,
                                  ));

                              Navigator.pop(context);
                            }
                            isUploading = false;
                          } else if (!isImageSelected) {
                            debugPrint(AppStrings.imageValidation);
                          }
                        },
                  child: const Text(AppStrings.addButton)),
            ],
          );
        });
  }
}
