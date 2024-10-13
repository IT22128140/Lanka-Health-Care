import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lanka_health_care/models/treatment_history.dart';
import 'package:lanka_health_care/services/database.dart';

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
          title: const Text('Add Treatment History'),
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
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
