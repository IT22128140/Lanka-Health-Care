import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lanka_health_care/models/patients.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class EditPatientDetails {
  static void showEditDialog(BuildContext context, data, dataid) {
    // Initialize controllers with existing patient data
    final TextEditingController firstNameController =
        TextEditingController(text: data[AppStrings.patientfirstName]);
    final TextEditingController lastNameController =
        TextEditingController(text: data[AppStrings.patientlastName]);
    final TextEditingController dobController = TextEditingController(
        text: DateFormat('yyyy-MM-dd')
            .format(data[AppStrings.patientdob].toDate()));
    final TextEditingController phoneController =
        TextEditingController(text: data[AppStrings.patientPhone]);
    final TextEditingController genderController =
        TextEditingController(text: data[AppStrings.patientGender]);
    final DatabaseService databaseService = DatabaseService();

    // Show the dialog
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(AppStrings.editPatient),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // First name input field
                    TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                        labelText: AppStrings.patientFirstNameLabel,
                        errorText: firstNameController.text.isEmpty
                            ? AppStrings.firstNameError
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    // Last name input field
                    TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        labelText: AppStrings.patientLastNameLabel,
                        errorText: lastNameController.text.isEmpty
                            ? AppStrings.lastNameError
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    // Date of birth input field
                    TextField(
                      controller: dobController,
                      decoration: InputDecoration(
                        labelText: AppStrings.patientDOBLabel,
                        errorText: dobController.text.isEmpty
                            ? AppStrings.dobError
                            : null,
                      ),
                      readOnly: true,
                      onTap: () => showDatePicker(
                        context: context,
                        initialDate: data[AppStrings.patientdob].toDate(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      ).then((value) {
                        if (value != null) {
                          dobController.text =
                              DateFormat('yyyy-MM-dd').format(value);
                          setState(() {});
                        }
                      }),
                    ),
                    // Phone number input field
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: AppStrings.patientPhoneLabel,
                        errorText: phoneController.text.isEmpty
                            ? AppStrings.phoneError
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    // Gender dropdown field
                    DropdownButtonFormField<String>(
                      value: genderController.text.isNotEmpty
                          ? genderController.text
                          : null,
                      items: [AppStrings.male, AppStrings.female]
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        genderController.text = value ?? '';
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        labelText: AppStrings.patientGenderLabel,
                        errorText: genderController.text.isEmpty
                            ? AppStrings.genderError
                            : null,
                      ),
                    ),
                  ],
                );
              },
            ),
            actions: [
              // Cancel button
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(AppStrings.cancelButton)),
              // Save button
              TextButton(
                  onPressed: () {
                    if (firstNameController.text.isEmpty ||
                        lastNameController.text.isEmpty ||
                        dobController.text.isEmpty ||
                        phoneController.text.isEmpty ||
                        genderController.text.isEmpty) {
                      return;
                    }
                    // Update patient data in the database
                    databaseService.editPatient(
                        dataid,
                        Patients(
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            dob: DateFormat('yyyy-MM-dd')
                                .parse(dobController.text),
                            phone: phoneController.text,
                            gender: genderController.text));
                    Navigator.pop(context);
                  },
                  child: const Text(AppStrings.saveButton))
            ],
          );
        });
  }
}