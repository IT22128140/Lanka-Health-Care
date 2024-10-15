import 'package:flutter/material.dart';
import 'package:lanka_health_care/models/medical_reports.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class EditMedicalReportDialog {
  static void showEditMedicalReportDialog(
      BuildContext context, String medicalHistoryId, data, String patientId) {
    // Define controllers for the text fields
    DatabaseService databaseService = DatabaseService();
    final TextEditingController allergies =
        TextEditingController(text: data[AppStrings.allergies]);
    final TextEditingController medications =
        TextEditingController(text: data[AppStrings.medications]);
    final TextEditingController surgeries =
        TextEditingController(text: data[AppStrings.surgeries]);
    final _formKey = GlobalKey<FormState>();

// Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Return the dialog with the form
        return AlertDialog(
          title: const Text(AppStrings.editMedicalInfoTitle),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Add text form fields for the medical report details
                TextFormField(
                  controller: allergies,
                  decoration: const InputDecoration(
                      labelText: AppStrings.allergiesLabel),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.pleaseEnterAllergy;
                    }
                    return null;
                  },
                ),
                // Add text form fields for the medical report details
                TextFormField(
                  controller: medications,
                  decoration: const InputDecoration(
                      labelText: AppStrings.medicationsLabel),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.pleaseEnterMedications;
                    }
                    return null;
                  },
                ),
                // Add text form fields for the medical report details
                TextFormField(
                  controller: surgeries,
                  decoration: const InputDecoration(
                      labelText: AppStrings.surgeriesLabel),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.pleaseEnterSurgeries;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // Add cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(AppStrings.cancelButton),
            ),
            // Add edit button
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  databaseService.editMedicalReport(
                      patientId,
                      medicalHistoryId,
                      MedicalReports(
                        allergies: allergies.text,
                        medications: medications.text,
                        surgeries: surgeries.text,
                      ));
                  Navigator.of(context).pop();
                }
              },
              child: const Text(AppStrings.editButton),
            ),
          ],
        );
      },
    );
  }
}
