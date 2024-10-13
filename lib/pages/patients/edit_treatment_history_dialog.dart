import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lanka_health_care/models/treatment_history.dart';
import 'package:lanka_health_care/services/database.dart';

class EditTreatmentHistoryDialog {
    static void showEditTreatmentHistoryDialog(
      BuildContext context, String treatmentHistoryId, data, String patientId) {
    final DatabaseService databaseService = DatabaseService();
    final TextEditingController treatment =
        TextEditingController(text: data['treatment']);
    final TextEditingController date =
        TextEditingController(text: data['date']);
    final TextEditingController doctor =
        TextEditingController(text: data['doctorName']);
    final TextEditingController description =
        TextEditingController(text: data['description']);
    final TextEditingController prescription =
        TextEditingController(text: data['prescription']);
    final TextEditingController doctorId =
        TextEditingController(text: data['doctor']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Treatment History'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: treatment,
                decoration: const InputDecoration(labelText: 'Treatment'),
              ),
              TextField(
                controller: date,
                decoration: const InputDecoration(labelText: 'Date'),
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
                  doctor.text = (selection['firstName'] ?? '') +
                      ' ' +
                      (selection['lastName'] ?? '');
                  doctorId.text = selection['id'] ?? '';
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(labelText: 'Doctor'),
                  );
                },
              ),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: prescription,
                decoration: const InputDecoration(labelText: 'Prescription'),
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
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }
}