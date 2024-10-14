import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:lanka_health_care/models/appointment.dart';
import 'package:lanka_health_care/models/payment.dart';
import 'package:lanka_health_care/services/database.dart';

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
        'Sunday': DateTime.sunday,
        'Monday': DateTime.monday,
        'Tuesday': DateTime.tuesday,
        'Wednesday': DateTime.wednesday,
        'Thursday': DateTime.thursday,
        'Friday': DateTime.friday,
        'Saturday': DateTime.saturday,
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
            title: const Text('Add Appointment'),
            content: Column(
              children: [
                Text(availability['date']),
                Text(availability['arrivetime']),
                Autocomplete<Map<String, dynamic>>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Map<String, dynamic>>.empty();
                    }
                    final patientList = await databaseService
                        .getPatientNamesByFirstName(textEditingValue.text);
                    return patientList.where((patient) {
                      return (patient['firstName'] ?? '')
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    }).map((doctor) => {
                          'id': doctor['id'] ?? '',
                          'firstName': doctor['firstName'] ?? '',
                          'lastName': doctor['lastName'] ?? '',
                        });
                  },
                  displayStringForOption: (Map<String, dynamic> option) =>
                      (option['firstName'] ?? '') +
                      ' ' +
                      (option['lastName'] ?? ''),
                  onSelected: (Map<String, dynamic> selection) {
                    patient.text = (selection['firstName'] ?? '') +
                        ' ' +
                        (selection['lastName'] ?? '');
                    patientuidController.text = selection['id'] ?? '';
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: 'Patient'),
                    );
                  },
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(hintText: 'Date'),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());

                    // Handle both string (single day) and list of strings (multiple days)
                    List<int> availableWeekdays =
                        getAvailableWeekdays(availability['date']);

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
                          value: 'Recurring', child: Text('Recurring')),
                      DropdownMenuItem(
                          value: 'Completed', child: Text('Completed')),
                      DropdownMenuItem(
                          value: 'Pending', child: Text('Pending')),
                    ],
                    value: paymentStatusController.text.isEmpty
                        ? 'Recurring'
                        : (['Recurring', 'Completed', 'Pending']
                                .contains(paymentStatusController.text)
                            ? paymentStatusController.text
                            : 'Recurring'),
                    onChanged: (value) {
                      paymentStatusController.text = value.toString();
                    }),
                const Text('Payment',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: bankNameController,
                  decoration: const InputDecoration(hintText: 'Bank Name'),
                ),
                TextField(
                  controller: accountNumberController,
                  decoration: const InputDecoration(hintText: 'Account Number'),
                ),
                TextField(
                  controller: accountNameController,
                  decoration: const InputDecoration(hintText: 'Account Name'),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(hintText: 'Amount'),
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
                    'Upload slip',
                    style: TextStyle(color: Color.fromARGB(255, 250, 230, 35)),
                  ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          isUploading = true;
                          String uniqueName =
                              DateTime.now().millisecondsSinceEpoch.toString();

                          Reference refImages = FirebaseStorage.instance.ref();
                          Reference refImagesDir =
                              refImages.child('slip_images');
                          Reference referenceImageToUpload =
                              refImagesDir.child('$uniqueName.jpg');
                          try {
                            await referenceImageToUpload.putData(image);
                            String downloadUrl =
                                await referenceImageToUpload.getDownloadURL();
                            depositSlipController.text = downloadUrl;
                          } catch (e) {
                            debugPrint('Error uploading image: $e');
                          }
                          if (context.mounted) {
                            await databaseService.createAppointmentAndPayment(
                                Appointment(
                                  doctoruid: doctorId,
                                  patientuid: patientuidController.text,
                                  date: dateController.text,
                                  time: availability['arrivetime'],
                                  status: 'Pending',
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
                  child: const Text('Add'))
            ],
          );
        });
  }
}
