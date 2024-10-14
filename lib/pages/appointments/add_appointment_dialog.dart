import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:lanka_health_care/models/appointment.dart';
import 'package:lanka_health_care/models/payment.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class AddAppointmentDialog {
  final DatabaseService databaseService = DatabaseService();

  void showAddAppointmentDialogue(
      BuildContext context, String doctorId, dynamic availability) {
    final TextEditingController patient = TextEditingController();
    final TextEditingController patientuidController = TextEditingController();
    final TextEditingController dateController = TextEditingController();

    final TextEditingController bankNameController = TextEditingController();
    final TextEditingController accountNumberController =
        TextEditingController();
    final TextEditingController accountNameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController depositSlipController = TextEditingController();
    final TextEditingController paymentStatusController =
        TextEditingController();

    dynamic image;
    bool isImageSelected = false;
    bool isUploading = false;

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
        // If a single string (e.g., "Sunday"), return a list with one weekday number
        return [daysOfWeek[availableDays]!];
      } else if (availableDays is List<String>) {
        // If a list of strings (e.g., ["Sunday", "Monday"]), map to weekday numbers
        return availableDays.map((day) => daysOfWeek[day]!).toList();
      }
      return [];
    }

    // Find the next available date based on the allowed weekdays
    DateTime _getNextAvailableDate(List<int> availableWeekdays) {
      DateTime now = DateTime.now();

      // Loop through the next days to find the first available one
      while (!availableWeekdays.contains(now.weekday)) {
        now = now.add(const Duration(days: 1));
      }
      return now;
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(AppStrings.addAppointment),
            content: Column(
              children: [
                Text(availability[AppStrings.date]),
                Text(availability[AppStrings.arrivetime]),
                Autocomplete<Map<String, dynamic>>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Map<String, dynamic>>.empty();
                    }
                    final patientList = await databaseService
                        .getPatientNamesByFirstName(textEditingValue.text);
                    return patientList.where((patient) {
                      return (patient[AppStrings.patientfirstName] ?? '')
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    }).map((doctor) => {
                          AppStrings.docID: doctor[AppStrings.docID] ?? '',
                          AppStrings.doctorFirstNameLabel: doctor[AppStrings.doctorFirstNameLabel] ?? '',
                          AppStrings.doctorLastNameLabel: doctor[AppStrings.doctorLastNameLabel] ?? '',
                        });
                  },
                  displayStringForOption: (Map<String, dynamic> option) =>
                      (option[AppStrings.patientfirstName] ?? '') +
                      ' ' +
                      (option[AppStrings.patientlastName] ?? ''),
                  onSelected: (Map<String, dynamic> selection) {
                    patient.text = (selection[AppStrings.patientfirstName] ?? '') +
                        ' ' +
                        (selection[AppStrings.patientlastName] ?? '');
                    patientuidController.text = selection[AppStrings.patientID] ?? '';
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: AppStrings.patient),
                    );
                  },
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(hintText: AppStrings.dateLabel),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());

                    // Handle both string (single day) and list of strings (multiple days)
                    List<int> availableWeekdays =
                        getAvailableWeekdays(availability[AppStrings.date]);

                    // Get the next available date based on available weekdays
                    DateTime initialDate =
                        _getNextAvailableDate(availableWeekdays);

                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          initialDate, // Ensure initialDate is one of the available days
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                      selectableDayPredicate: (DateTime date) {
                        // Allow only the available weekdays to be selected
                        return availableWeekdays.contains(date.weekday);
                      },
                    );

                    if (pickedDate != null) {
                      dateController.text =
                          "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                    }
                  },
                ),
                DropdownButtonFormField(
                    items: const [
                      DropdownMenuItem(
                          value: AppStrings.recurring, child: Text(AppStrings.recurring)),
                      DropdownMenuItem(
                          value: AppStrings.completed, child: Text(AppStrings.completed)),
                      DropdownMenuItem(
                          value: AppStrings.pending, child: Text(AppStrings.pending)),
                    ],
                    value: paymentStatusController.text.isEmpty
                        ? AppStrings.recurring
                        : ([AppStrings.recurring, AppStrings.completed, AppStrings.pending]
                                .contains(paymentStatusController.text)
                            ? paymentStatusController.text
                            : AppStrings.recurring),
                    onChanged: (value) {
                      paymentStatusController.text = value.toString();
                    }),
                const Text(AppStrings.payment,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: bankNameController,
                  decoration: const InputDecoration(hintText: AppStrings.bankName),
                ),
                TextField(
                  controller: accountNumberController,
                  decoration: const InputDecoration(hintText: AppStrings.accountNumber),
                ),
                TextField(
                  controller: accountNameController,
                  decoration: const InputDecoration(hintText: AppStrings.accountName),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(hintText: AppStrings.amount),
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
                    style: TextStyle(color: Color.fromARGB(255, 250, 230, 35)),
                  ),
              ],
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
                          isUploading = true;
                          String uniqueName =
                              DateTime.now().millisecondsSinceEpoch.toString();

                          Reference refImages = FirebaseStorage.instance.ref();
                          Reference refImagesDir =
                              refImages.child(AppStrings.slipImages);
                          Reference referenceImageToUpload =
                              refImagesDir.child('$uniqueName${AppStrings.jpg}');
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
                        },
                  child: const Text(AppStrings.addButton)),
            ],
          );
        });
  }
}
