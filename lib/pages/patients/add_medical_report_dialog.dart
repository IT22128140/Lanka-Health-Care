import 'package:flutter/material.dart';
import 'package:lanka_health_care/models/medical_reports.dart';
import 'package:lanka_health_care/services/database.dart';

class AddMedicalReportDialog {
    static void showAddMedicalReportDialog(BuildContext context, String patientId) {
    DatabaseService databaseService = DatabaseService();
    final TextEditingController allergies = TextEditingController();
    final TextEditingController medications = TextEditingController();
    final TextEditingController surgeries = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Medical Info'),
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
                databaseService.addMedicalReport(
                    patientId,
                    MedicalReports(
                      allergies: allergies.text,
                      medications: medications.text,
                      surgeries: surgeries.text,
                    ));
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}