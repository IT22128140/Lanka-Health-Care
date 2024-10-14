import 'package:flutter/material.dart';
import 'package:lanka_health_care/models/availability.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class EditAvailabilityDialog {
  final DatabaseService database = DatabaseService();

  void show(BuildContext context, Map<String, dynamic> data, String dataid, String userId) {
    final TextEditingController editDateController = TextEditingController(text: data[AppStrings.date]);
    final TextEditingController editArrivetimeController = TextEditingController(text: data[AppStrings.arrivetime]);
    final TextEditingController editLeavetimeController = TextEditingController(text: data[AppStrings.leavetime]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.editavailability),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              ),
              TextField(
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
              ),
              TextField(
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
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(AppStrings.cancelButton),
            ),
            TextButton(
              onPressed: () {
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
              },
              child: const Text(AppStrings.saveButton),
            ),
          ],
        );
      },
    );
  }
}