import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lanka_health_care/models/treatment_history.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class AddTreatmentHistoryDialog {
  static void showAddTreatmentHistoryDialog(
      BuildContext context, String patientId) {
    // Define controllers for the text fields
    final DatabaseService databaseService = DatabaseService();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController treatment = TextEditingController();
    final TextEditingController date = TextEditingController();
    final TextEditingController doctor = TextEditingController();
    final TextEditingController doctorId = TextEditingController();
    final TextEditingController description = TextEditingController();
    final TextEditingController prescription = TextEditingController();

// Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Return the dialog with the form
        return AlertDialog(
          title: const Text(AppStrings.addTreatmentHistoryTitle),
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
            // Add buttons to cancel or save the treatment history
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(AppStrings.cancelButton),
            ),
            // Add buttons to cancel or save the treatment history
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
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
