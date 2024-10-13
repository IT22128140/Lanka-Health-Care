import 'package:flutter/material.dart';
import 'package:lanka_health_care/models/medical_reports.dart';
import 'package:lanka_health_care/services/database.dart';

class EditMedicalReportDialog {
  static void showEditMedicalReportDialog(
      BuildContext context, String medicalHistoryId, data, String patientId) {
    DatabaseService databaseService = DatabaseService();
    final TextEditingController allergies =
        TextEditingController(text: data['allergies']);
    final TextEditingController medications =
        TextEditingController(text: data['medications']);
    final TextEditingController surgeries =
        TextEditingController(text: data['surgeries']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Medical Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: allergies,
                decoration: const InputDecoration(labelText: 'Allergies'),
              ),
              TextField(
                controller: medications,
                decoration: const InputDecoration(labelText: 'Medications'),
              ),
              TextField(
                controller: surgeries,
                decoration: const InputDecoration(labelText: 'Surgeries'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }
}