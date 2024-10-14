import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lanka_health_care/models/treatment_history.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class EditTreatmentHistoryDialog {
    static void showEditTreatmentHistoryDialog(
      BuildContext context, String treatmentHistoryId, data, String patientId) {
    final DatabaseService databaseService = DatabaseService();
    final TextEditingController treatment =
        TextEditingController(text: data[AppStrings.treatment]);
    final TextEditingController date =
        TextEditingController(text: data[AppStrings.date]);
    final TextEditingController doctor =
        TextEditingController(text: data[AppStrings.doctorName]);
    final TextEditingController description =
        TextEditingController(text: data[AppStrings.description]);
    final TextEditingController prescription =
        TextEditingController(text: data[AppStrings.prescription]);
    final TextEditingController doctorId =
        TextEditingController(text: data[AppStrings.doctor]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.editTreatmentHistoryTitle),
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
                    return (doctor[AppStrings.doctorFirstNameLabel] ?? '')
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  }).map((doctor) => {
                        AppStrings.docID: doctor[AppStrings.docID] ?? '',
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
                databaseService.editTreatmentHistory(
                    patientId,
                    treatmentHistoryId,
                    TreatmentHistory(
                      treatment: treatment.text,
                      date: date.text,
                      doctor: doctor.text,
                      doctorName: doctorId.text,
                      description: description.text,
                      prescription: prescription.text,
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