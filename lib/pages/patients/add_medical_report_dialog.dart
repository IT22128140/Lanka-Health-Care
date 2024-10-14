import 'package:flutter/material.dart';
import 'package:lanka_health_care/models/medical_reports.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class AddMedicalReportDialog {
  // Show the dialog to add medical report
  static void showAddMedicalReportDialog(
      BuildContext context, String patientId) {
    // Initialize controllers for medical report data
    DatabaseService databaseService = DatabaseService();
    final TextEditingController allergies = TextEditingController();
    final TextEditingController medications = TextEditingController();
    final TextEditingController surgeries = TextEditingController();
    // Form key
    final _formKey = GlobalKey<FormState>();

// Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Return the dialog
        return AlertDialog(
          title: const Text(AppStrings.addMedicalInfoTitle),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Allergies input field
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
                // Medications input field
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
                // Surgeries input field
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
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(AppStrings.cancelButton),
            ),
            // Add button
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  databaseService.addMedicalReport(
                      patientId,
                      MedicalReports(
                        allergies: allergies.text,
                        medications: medications.text,
                        surgeries: surgeries.text,
                      ));
                  Navigator.of(context).pop();
                }
              },
              child: const Text(AppStrings.addButton),
            ),
          ],
        );
      },
    );
  }
}
