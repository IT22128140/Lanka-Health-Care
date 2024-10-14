import 'package:flutter/material.dart';
import 'package:lanka_health_care/components/drawers/drawer_custom.dart';
import 'package:lanka_health_care/components/my_button.dart';
import 'package:lanka_health_care/models/patients.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lanka_health_care/shared/constants.dart';

class PatientsPage extends StatefulWidget {
  final DrawerCustom drawer;
  const PatientsPage({super.key, required this.drawer});

  @override
  State<PatientsPage> createState() => _PatientsState();
}

class _PatientsState extends State<PatientsPage> {
  final DatabaseService databaseService = DatabaseService();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.patientsDetails),
      ),
      drawer: widget.drawer,
      body: Center(
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: databaseService.getPatients(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        );
                      } else if (!snapshot.hasData ||
                          (snapshot.data as QuerySnapshot).docs.isEmpty) {
                        return const Text(AppStrings.noPatientFound,
                            style: TextStyle(color: Colors.blue, fontSize: 30));
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}',
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 30));
                      } else {
                        {
                          final QuerySnapshot patients =
                              snapshot.data as QuerySnapshot;

                          return ListView.builder(
                              itemCount: patients.docs.length,
                              itemBuilder: (context, index) {
                                final patient = patients.docs[index];
                                final patientId = patients.docs[index].id;
                                return ListTile(
                                  title: Text(patient[AppStrings.patientfirstName] +
                                      ' ' +
                                      patient[AppStrings.patientlastName]),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${AppStrings.contact}: ${patient[AppStrings.patientPhone]}'),
                                      Text(
                                          '${AppStrings.patientDOBLabel}: ${DateFormat('yyyy-MM-dd').format(patient[AppStrings.patientdob].toDate())}'),
                                      Text(
                                          '${AppStrings.patientAgeLabel}: ${calculateAge(patient[AppStrings.patientdob].toDate())}'),
                                      Text('${AppStrings.patientGenderLabel}: ${patient[AppStrings.patientGender]}'),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/patientDetails',
                                              arguments: patientId);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          _showEditDialog(
                                              context, patient, patientId);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          databaseService
                                              .deletePatient(patient.id);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              });
                        }
                      }
                    })),
            //add patient form
            Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.patientFirstNameLabel,
                      ),
                    ),
                    TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.patientLastNameLabel,
                      ),
                    ),
                    TextField(
                      controller: dobController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.patientDOBLabel,
                      ),
                      readOnly: true,
                      onTap: () => showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      ).then((value) {
                        if (value != null) {
                          dobController.text =
                              DateFormat('yyyy-MM-dd').format(value);
                        }
                      }),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: AppStrings.patientPhoneLabel,
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      items: [AppStrings.male, AppStrings.female].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        genderController.text = value ?? '';
                      },
                      decoration: const InputDecoration(
                        labelText: AppStrings.patientGenderLabel,
                      ),
                    ),
                    MyButton(
                        text: AppStrings.addPatientButton,
                        onTap: () => {
                              databaseService.createPatient(Patients(
                                  firstName: firstNameController.text,
                                  lastName: lastNameController.text,
                                  dob: DateFormat('yyyy-MM-dd')
                                      .parse(dobController.text),
                                  phone: phoneController.text,
                                  gender: genderController.text))
                            },
                        width: 500)
                  ],
                )),
          ],
        ),
      ),
    );
  }

  calculateAge(date) {
    var now = new DateTime.now();
    var dob = date;
    var difference = now.difference(dob);
    var age = difference.inDays ~/ 365;
    return age;
  }

  void _showEditDialog(BuildContext context, data, dataid) {
    final TextEditingController firstNameController =
        TextEditingController(text: data[AppStrings.patientfirstName]);
    final TextEditingController lastNameController =
        TextEditingController(text: data[AppStrings.patientlastName]);
    final TextEditingController dobController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(data[AppStrings.patientdob].toDate()));
    final TextEditingController phoneController =
        TextEditingController(text: data[AppStrings.patientPhone]);
    final TextEditingController genderController =
        TextEditingController(text: data[AppStrings.patientGender]);

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(AppStrings.editPatient),
            content: Column(
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.patientFirstNameLabel,
                  ),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.patientLastNameLabel,
                  ),
                ),
                TextField(
                  controller: dobController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.patientDOBLabel,
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
                    }
                  }),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: AppStrings.patientPhone,
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: genderController.text.isNotEmpty ? genderController.text : null,
                  items: [AppStrings.male, AppStrings.female].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                  }).toList(),
                  onChanged: (String? value) {
                  genderController.text = value ?? '';
                  },
                  decoration: const InputDecoration(
                  labelText: AppStrings.patientGenderLabel,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(AppStrings.cancelButton)),
              TextButton(
                  onPressed: () {
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
