import 'package:flutter/material.dart';
import 'package:lanka_health_care/components/drawers/drawer_custom.dart';
import 'package:lanka_health_care/components/my_button.dart';
import 'package:lanka_health_care/models/patients.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
        title: const Text('Patients'),
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
                        return const Text('No patients found',
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
                                  title: Text(patient['firstName'] +
                                      ' ' +
                                      patient['lastName']),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Contact: ${patient['phone']}'),
                                      Text(
                                          'Date of birth: ${DateFormat('yyyy-MM-dd').format(patient['dob'].toDate())}'),
                                      Text(
                                          'Age: ${calculateAge(patient['dob'].toDate())}'),
                                      Text('Gender: ${patient['gender']}'),
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
                        labelText: 'First Name',
                      ),
                    ),
                    TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                      ),
                    ),
                    TextField(
                      controller: dobController,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
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
                        labelText: 'Phone',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      items: ['Male', 'Female'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        genderController.text = value ?? '';
                      },
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                      ),
                    ),
                    MyButton(
                        text: 'Add Patient',
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
        TextEditingController(text: data['firstName']);
    final TextEditingController lastNameController =
        TextEditingController(text: data['lastName']);
    final TextEditingController dobController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(data['dob'].toDate()));
    final TextEditingController phoneController =
        TextEditingController(text: data['phone']);
    final TextEditingController genderController =
        TextEditingController(text: data['gender']);

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Patient'),
            content: Column(
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                  ),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                  ),
                ),
                TextField(
                  controller: dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                  ),
                  readOnly: true,
                  onTap: () => showDatePicker(
                    context: context,
                    initialDate: data['dob'].toDate(),
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
                    labelText: 'Phone',
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: genderController.text.isNotEmpty ? genderController.text : null,
                  items: ['Male', 'Female'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                  }).toList(),
                  onChanged: (String? value) {
                  genderController.text = value ?? '';
                  },
                  decoration: const InputDecoration(
                  labelText: 'Gender',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
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
                  child: const Text('Save'))
            ],
          );
        });
  }
}
