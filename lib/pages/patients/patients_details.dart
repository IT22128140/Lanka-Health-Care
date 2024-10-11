import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lanka_health_care/components/my_button.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/models/medical_reports.dart';
import 'package:lanka_health_care/models/treatment_history.dart';

class PatientsDetails extends StatefulWidget {
  final String patientId;

  const PatientsDetails({super.key, required this.patientId});

  @override
  State<PatientsDetails> createState() => _PatientsDetailsState();
}

class _PatientsDetailsState extends State<PatientsDetails> {
  final DatabaseService databaseService = DatabaseService();
  String? doctorId; // Define the doctorId variable

  calculateAge(DateTime date) {
    var now = DateTime.now();
    var difference = now.difference(date);
    var age = difference.inDays ~/ 365;
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients Details'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: StreamBuilder<DocumentSnapshot>(
                stream: databaseService.getPatientByUid(widget.patientId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 30));
                  } else if (!snapshot.hasData ||
                      snapshot.data!.data() == null) {
                    return const Text('No patients found',
                        style: TextStyle(color: Colors.blue, fontSize: 30));
                  } else {
                    final patient =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('First Name: ${patient['firstName'] ?? 'N/A'}'),
                        Text('Last Name: ${patient['lastName'] ?? 'N/A'}'),
                        Text(
                            'Date of Birth: ${patient['dob'] != null ? DateFormat('yyyy-MM-dd').format((patient['dob'] as Timestamp).toDate()) : 'N/A'}'),
                        Text(
                            'Age: ${patient['dob'] != null ? calculateAge((patient['dob'] as Timestamp).toDate()) : 'N/A'}'),
                        Text('Phone: ${patient['phone'] ?? 'N/A'}'),
                      ],
                    );
                  }
                }),
          ),
          const Text('Medical Report'),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream:
                    databaseService.getPatientMedicalReport(widget.patientId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 30));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Column(
                      children: [
                        const Text('No medical history found',
                            style: TextStyle(color: Colors.blue, fontSize: 30)),
                        MyButton(
                          width: 500,
                          onTap: () {
                            _showAddMedicalReportDialog(context);
                          },
                          text: 'Add Medical Report',
                        ),
                      ],
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final medicalHistory = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                        final medicalHistoryId = snapshot.data!.docs[index].id;
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Allergies: ${medicalHistory['allergies'] ?? 'N/A'}'),
                              Text(
                                  'Medications: ${medicalHistory['medications'] ?? 'N/A'}'),
                              Text(
                                  'Surgeries: ${medicalHistory['surgeries'] ?? 'N/A'}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditMedicalReportDialog(context,
                                      medicalHistoryId, medicalHistory);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  databaseService.deleteMedicalReport(
                                      widget.patientId, medicalHistoryId);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                }),
          ),
          const Text('Treatment History'),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: databaseService.getTreatmentHistory(widget.patientId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 30));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No treatment history found',
                        style: TextStyle(color: Colors.blue, fontSize: 30));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final treatmentHistory = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                        final treatmentHistoryId =
                            snapshot.data!.docs[index].id;
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Treatment: ${treatmentHistory['treatment'] ?? 'N/A'}'),
                              Text(
                                  'Date: ${treatmentHistory['date'] ?? 'N/A'}'),
                              Text(
                                  'Doctor: ${treatmentHistory['doctorName'] ?? 'N/A'}'),
                              Text(
                                  'Description: ${treatmentHistory['description'] ?? 'N/A'}'),
                              Text(
                                  'Prescription: ${treatmentHistory['prescription'] ?? 'N/A'}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditTreatmentHistoryDialog(context,
                                      treatmentHistoryId, treatmentHistory);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  databaseService.deleteTreatmentHistory(
                                      widget.patientId, treatmentHistoryId);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                }),
          ),
          MyButton(
            width: 500,
            onTap: () {
              _showAddTreatmentHistoryDialog(context);
            },
            text: 'Add Treatment History',
          ),
        ],
      ),
    );
  }

  void _showAddMedicalReportDialog(BuildContext context) {
    final TextEditingController allergies = TextEditingController();
    final TextEditingController medications = TextEditingController();
    final TextEditingController surgeries = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Medical Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: allergies,
                decoration: const InputDecoration(labelText: 'Allergies'),
              ),
              TextField(
                controller: medications,
                decoration: const InputDecoration(labelText: 'Medications'),
              ),
              TextField(
                controller: surgeries,
                decoration: const InputDecoration(labelText: 'Surgeries'),
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
                databaseService.addMedicalReport(
                    widget.patientId,
                    MedicalReports(
                      allergies: allergies.text,
                      medications: medications.text,
                      surgeries: surgeries.text,
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

  void _showEditMedicalReportDialog(
      BuildContext context, String medicalHistoryId, data) {
    final TextEditingController allergies =
        TextEditingController(text: data['allergies']);
    final TextEditingController medications =
        TextEditingController(text: data['medications']);
    final TextEditingController surgeries =
        TextEditingController(text: data['surgeries']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Medical Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: allergies,
                decoration: const InputDecoration(labelText: 'Allergies'),
              ),
              TextField(
                controller: medications,
                decoration: const InputDecoration(labelText: 'Medications'),
              ),
              TextField(
                controller: surgeries,
                decoration: const InputDecoration(labelText: 'Surgeries'),
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
                databaseService.editMedicalReport(
                    widget.patientId,
                    medicalHistoryId,
                    MedicalReports(
                      allergies: allergies.text,
                      medications: medications.text,
                      surgeries: surgeries.text,
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

  void _showAddTreatmentHistoryDialog(BuildContext context) {
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
                    widget.patientId,
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

  void _showEditTreatmentHistoryDialog(
      BuildContext context, String treatmentHistoryId, data) {
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
                    widget.patientId,
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
