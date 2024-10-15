import 'package:flutter/material.dart';
import 'package:lanka_health_care/components/drawers/drawer_custom.dart';
import 'package:lanka_health_care/components/my_button.dart';
import 'package:lanka_health_care/models/patients.dart';
import 'package:lanka_health_care/pages/patients/edit_patient_details.dart';
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
  // Initialize the database service
  final DatabaseService databaseService = DatabaseService();

// Define controllers for the text fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  final EditPatientDetails editPatientDetails = EditPatientDetails();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add the app bar
      appBar: AppBar(
        title: const Text(AppStrings.patientsDetails),
        backgroundColor: Colors.white,
        elevation: 5.0,
        shadowColor: Colors.grey,
      ),
      // Add the drawer
      drawer: widget.drawer,
      body: Center(
        child: Row(
          children: [
            // List of patients
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: databaseService.getPatients(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show loading spinner if the data is loading
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        );
                      } else if (!snapshot.hasData ||
                          (snapshot.data as QuerySnapshot).docs.isEmpty) {
                            // Show message if no patients are found
                        return const Text(AppStrings.noPatientFound,
                            style: TextStyle(color: Colors.blue, fontSize: 30));
                      } else if (snapshot.hasError) {
                        // Show error message if there is an error
                        return Text('${AppStrings.error} ${snapshot.error}',
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 30));
                      } else {
                        {
                          // Show the list of patients
                          final QuerySnapshot patients =
                              snapshot.data as QuerySnapshot;

                          return ListView.builder(
                              itemCount: patients.docs.length,
                              itemBuilder: (context, index) {
                                final patient = patients.docs[index];
                                final patientId = patients.docs[index].id;
                                return ListTile(
                                  // Add patient details to the list
                                  title: Text(
                                      patient[AppStrings.patientfirstName] +
                                          ' ' +
                                          patient[AppStrings.patientlastName]),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${AppStrings.contact}: ${patient[AppStrings.patientPhone]}'),
                                      Text(
                                          '${AppStrings.patientDOBLabel}: ${DateFormat('yyyy-MM-dd').format(patient[AppStrings.patientdob].toDate())}'),
                                      Text(
                                          '${AppStrings.patientAgeLabel}: ${calculateAge(patient[AppStrings.patientdob].toDate())}'),
                                      Text(
                                          '${AppStrings.patientGenderLabel}: ${patient[AppStrings.patientGender]}'),
                                    ],
                                  ),
                                  // Add trailing icons for view, edit, and delete
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
                                          EditPatientDetails.showEditDialog(
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
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Container(
                    color: const Color.fromARGB(255, 229, 246, 255),
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Add the form to add a new patient
                        const Text(
                          AppStrings.addPtient,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Add text form fields for the patient details
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: firstNameController,
                            decoration: InputDecoration(
                              labelText: AppStrings.patientFirstNameLabel,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              errorText: firstNameController.text.isEmpty
                                  ? AppStrings.firstNameError
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Add text form fields for the patient details
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: lastNameController,
                            decoration: InputDecoration(
                              labelText: AppStrings.patientLastNameLabel,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              errorText: lastNameController.text.isEmpty
                                  ? AppStrings.lastNameError
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Add text form fields for the patient details
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: dobController,
                            decoration: InputDecoration(
                              labelText: AppStrings.patientDOBLabel,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              errorText: dobController.text.isEmpty
                                  ? AppStrings.dobError
                                  : null,
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
                        ),
                        const SizedBox(height: 20),
                        // Add text form fields for the patient details
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: phoneController,
                            decoration: InputDecoration(
                              labelText: AppStrings.patientPhoneLabel,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              errorText: phoneController.text.isEmpty
                                  ? AppStrings.phoneError
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Add text form fields for the patient details
                        SizedBox(
                          width: 300,
                          child: DropdownButtonFormField<String>(
                            items: [AppStrings.male, AppStrings.female]
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              genderController.text = value ?? '';
                            },
                            decoration: InputDecoration(
                              labelText: AppStrings.patientGenderLabel,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              errorText: genderController.text.isEmpty
                                  ? AppStrings.genderError
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Add the button to add a new patient
                        MyButton(
                            text: AppStrings.addPatientButton,
                            onTap: () {
                              setState(() {
                                if (firstNameController.text.isEmpty ||
                                    lastNameController.text.isEmpty ||
                                    dobController.text.isEmpty ||
                                    phoneController.text.isEmpty ||
                                    genderController.text.isEmpty) {
                                  return;
                                }
                                databaseService.createPatient(Patients(
                                    firstName: firstNameController.text,
                                    lastName: lastNameController.text,
                                    dob: DateFormat('yyyy-MM-dd')
                                        .parse(dobController.text),
                                    phone: phoneController.text,
                                    gender: genderController.text));
                              });
                            },
                            width: 300),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Calculate the age of the patient
  calculateAge(date) {
    var now = new DateTime.now();
    var dob = date;
    var difference = now.difference(dob);
    var age = difference.inDays ~/ 365;
    return age;
  }
}
