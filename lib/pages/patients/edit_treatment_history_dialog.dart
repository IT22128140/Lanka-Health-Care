import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lanka_health_care/models/treatment_history.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class EditTreatmentHistoryDialog {
  static void showEditTreatmentHistoryDialog(
      BuildContext context, String treatmentHistoryId, data, String patientId) {
        // Define controllers for the text fields
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

    final _formKey = GlobalKey<FormState>();

// Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.editTreatmentHistoryTitle),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Add text form fields for the treatment history details
                TextFormField(
                  controller: treatment,
                  decoration: const InputDecoration(
                      labelText: AppStrings.treatmentLabel),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.pleaseEnterTreatments;
                    }
                    return null;
                  },
                ),
                // Add text form fields for the treatment history details
                TextFormField(
                  controller: date,
                  decoration:
                      const InputDecoration(labelText: AppStrings.dateLabel),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.dateValidation;
                    }
                    return null;
                  },
                ),
                // Add text form fields for the treatment history details
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
                          AppStrings.doctorFirstNameLabel:
                              doctor[AppStrings.doctorFirstNameLabel] ?? '',
                          AppStrings.doctorLastNameLabel:
                              doctor[AppStrings.doctorLastNameLabel] ?? '',
                        });
                  },
                  displayStringForOption: (Map<String, dynamic> option) =>
                      (option[AppStrings.doctorFirstNameLabel] ?? '') +
                      ' ' +
                      (option[AppStrings.doctorLastNameLabel] ?? ''),
                  onSelected: (Map<String, dynamic> selection) {
                    doctor.text =
                        (selection[AppStrings.doctorFirstNameLabel] ?? '') +
                            ' ' +
                            (selection[AppStrings.doctorLastNameLabel] ?? '');
                    doctorId.text = selection[AppStrings.docID] ?? '';
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                          labelText: AppStrings.doctorLabel),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.pleaseSelectDoctor;
                        }
                        return null;
                      },
                    );
                  },
                ),
                // Add text form fields for the treatment history details
                TextFormField(
                  controller: description,
                  decoration: const InputDecoration(
                      labelText: AppStrings.descriptionLabel),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.pleaseEnterDescription;
                    }
                    return null;
                  },
                ),
                // Add text form fields for the treatment history details
                TextFormField(
                  controller: prescription,
                  decoration: const InputDecoration(
                      labelText: AppStrings.prescriptionLabel),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.pleaseEnterPrescription;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // Add buttons to the dialog
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(AppStrings.cancelButton),
            ),
            // Add buttons to the dialog
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
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
