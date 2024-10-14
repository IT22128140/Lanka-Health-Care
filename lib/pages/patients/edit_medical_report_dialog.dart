import 'package:flutter/material.dart';
import 'package:lanka_health_care/models/medical_reports.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class EditMedicalReportDialog {
  static void showEditMedicalReportDialog(
      BuildContext context, String medicalHistoryId, data, String patientId) {
    DatabaseService databaseService = DatabaseService();
    final TextEditingController allergies =
        TextEditingController(text: data[AppStrings.allergies]);
    final TextEditingController medications =
        TextEditingController(text: data[AppStrings.medications]);
    final TextEditingController surgeries =
        TextEditingController(text: data[AppStrings.surgeries]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.editMedicalInfoTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: allergies,
                decoration: const InputDecoration(labelText: AppStrings.allergiesLabel),
              ),
              TextField(
                controller: medications,
                decoration: const InputDecoration(labelText: AppStrings.medicationsLabel),
              ),
              TextField(
                controller: surgeries,
                decoration: const InputDecoration(labelText: AppStrings.surgeriesLabel),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(AppStrings.cancelButton),
            ),
            TextButton(
              onPressed: () {
                databaseService.editMedicalReport(
                    patientId,
                    medicalHistoryId,
                    MedicalReports(
                      allergies: allergies.text,
                      medications: medications.text,
                      surgeries: surgeries.text,
                    ));
                Navigator.of(context).pop();
              },
              child: const Text(AppStrings.editButton),
            ),
          ],
        );
      },
    );
  }
}