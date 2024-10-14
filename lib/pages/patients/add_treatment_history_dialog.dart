import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lanka_health_care/models/treatment_history.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class AddTreatmentHistoryDialog {
  static void showAddTreatmentHistoryDialog(BuildContext context, String patientId) {
    final DatabaseService databaseService = DatabaseService();
    final TextEditingController treatment = TextEditingController();
    final TextEditingController date = TextEditingController();
    final TextEditingController doctor = TextEditingController();
    final TextEditingController doctorId = TextEditingController();
    final TextEditingController description = TextEditingController();
    final TextEditingController prescription = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.addTreatmentHistoryTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: treatment,
                decoration: const InputDecoration(labelText: AppStrings.treatmentLabel),
              ),
              TextField(
                controller: date,
                decoration: const InputDecoration(labelText: AppStrings.dateLabel),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    date.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
              ),
              Autocomplete<Map<String, dynamic>>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                  final doctorsList = await databaseService
                      .getDoctorNamesByFirstName(textEditingValue.text);
                  return doctorsList.where((doctor) {
                    return (doctor['firstName'] ?? '')
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  }).map((doctor) => {
                        AppStrings.docID : doctor[AppStrings.docID] ?? '',
                        AppStrings.doctorFirstNameLabel: doctor[AppStrings.doctorFirstNameLabel] ?? '',
                        AppStrings.doctorLastNameLabel: doctor[AppStrings.doctorLastNameLabel] ?? '',
                      });
                },
                displayStringForOption: (Map<String, dynamic> option) =>
                    (option[AppStrings.doctorFirstNameLabel] ?? '') +
                    ' ' +
                    (option[AppStrings.doctorLastNameLabel] ?? ''),
                onSelected: (Map<String, dynamic> selection) {
                  doctor.text = (selection[AppStrings.doctorFirstNameLabel] ?? '') +
                      ' ' +
                      (selection[AppStrings.doctorLastNameLabel] ?? '');
                  doctorId.text = selection[AppStrings.docID] ?? '';
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(labelText: AppStrings.doctorLabel),
                  );
                },
              ),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: AppStrings.descriptionLabel),
              ),
              TextField(
                controller: prescription,
                decoration: const InputDecoration(labelText: AppStrings.prescriptionLabel),
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
                databaseService.addTreatmentHistory(
                    patientId,
                    TreatmentHistory(
                      treatment: treatment.text,
                      date: date.text,
                      doctor: doctorId.text,
                      doctorName: doctor.text,
                      description: description.text,
                      prescription: prescription.text,
                    ));
                Navigator.of(context).pop();
              },
              child: const Text(AppStrings.addButton),
            ),
          ],
        );
      },
    );
  }
}
