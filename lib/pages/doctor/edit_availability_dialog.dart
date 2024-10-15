import 'package:flutter/material.dart';
import 'package:lanka_health_care/models/availability.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class EditAvailabilityDialog {
  final DatabaseService database = DatabaseService();

  void show(BuildContext context, Map<String, dynamic> data, String dataid,
      String userId) {
    // Define controllers for the text fields
    final TextEditingController editDateController =
        TextEditingController(text: data[AppStrings.date]);
    final TextEditingController editArrivetimeController =
        TextEditingController(text: data[AppStrings.arrivetime]);
    final TextEditingController editLeavetimeController =
        TextEditingController(text: data[AppStrings.leavetime]);

    final _formKey = GlobalKey<FormState>();

// Show the dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.editavailability),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Add text form fields for the availability details
                DropdownButtonFormField<String>(
                  value: editDateController.text,
                  decoration: const InputDecoration(
                    labelText: AppStrings.dateLabel,
                  ),
                  items: <String>[
                    AppStrings.sunday,
                    AppStrings.monday,
                    AppStrings.tuesday,
                    AppStrings.wednesday,
                    AppStrings.thursday,
                    AppStrings.friday,
                    AppStrings.saturday,
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    editDateController.text = newValue!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.dateValidation;
                    }
                    return null;
                  },
                ),
                // Add text form fields for the availability details
                TextFormField(
                  controller: editArrivetimeController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.arrivallabeltext,
                  ),
                  onTap: () => showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  ).then((value) {
                    if (value != null) {
                      editArrivetimeController.text = value.format(context);
                    }
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.arrivalTimeValidation;
                    }
                    return null;
                  },
                ),
                // Add text form fields for the availability details
                TextFormField(
                  controller: editLeavetimeController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.leavelabeltext,
                  ),
                  onTap: () => showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  ).then((value) {
                    if (value != null) {
                      editLeavetimeController.text = value.format(context);
                    }
                  }),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.leaveTimeValidation;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            // Add buttons to the dialog
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(AppStrings.cancelButton),
            ),
            // Add buttons to the dialog
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  database.editAvailability(
                    userId,
                    dataid,
                    Availability(
                      date: editDateController.text,
                      arrivetime: editArrivetimeController.text,
                      leavetime: editLeavetimeController.text,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text(AppStrings.saveButton),
            ),
          ],
        );
      },
    );
  }
}
