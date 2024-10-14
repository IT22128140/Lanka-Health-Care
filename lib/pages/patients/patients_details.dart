import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lanka_health_care/components/my_button.dart';
import 'package:lanka_health_care/pages/patients/add_treatment_history_dialog.dart';
import 'package:lanka_health_care/pages/patients/edit_medical_report_dialog.dart';
import 'package:lanka_health_care/pages/patients/edit_treatment_history_dialog.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/pages/patients/add_medical_report_dialog.dart';
import 'package:lanka_health_care/shared/constants.dart';

class PatientsDetails extends StatefulWidget {
  final String patientId;

  const PatientsDetails({super.key, required this.patientId});

  @override
  State<PatientsDetails> createState() => _PatientsDetailsState();
}

class _PatientsDetailsState extends State<PatientsDetails> {
  final DatabaseService databaseService = DatabaseService();
  final AddMedicalReportDialog addMedicalReportDialog =
      AddMedicalReportDialog();
  final EditMedicalReportDialog editMedicalReportDialog =
      EditMedicalReportDialog();
  final AddTreatmentHistoryDialog addTreatmentHistoryDialog =
      AddTreatmentHistoryDialog();
  final EditTreatmentHistoryDialog editTreatmentHistoryDialog =
      EditTreatmentHistoryDialog();

  String? doctorId;

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
        title: const Text(AppStrings.patientsDetails),
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
                    return Text('${AppStrings.error} ${snapshot.error}',
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 30));
                  } else if (!snapshot.hasData ||
                      snapshot.data!.data() == null) {
                    return const Text(AppStrings.noPatientFound,
                        style: TextStyle(color: Colors.blue, fontSize: 30));
                  } else {
                    final patient =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${AppStrings.patientFirstNameLabel}: ${patient[AppStrings.patientfirstName] ?? 'N/A'}'),
                        Text('${AppStrings.patientLastNameLabel}: ${patient[AppStrings.patientlastName] ?? 'N/A'}'),
                        Text(
                            '${AppStrings.patientDOBLabel}: ${patient[AppStrings.patientdob] != null ? DateFormat('yyyy-MM-dd').format((patient[AppStrings.patientdob] as Timestamp).toDate()) : 'N/A'}'),
                        Text(
                            '${AppStrings.patientAgeLabel}: ${patient[AppStrings.patientdob] != null ? calculateAge((patient[AppStrings.patientdob] as Timestamp).toDate()) : 'N/A'}'),
                        Text('${AppStrings.patientPhoneLabel}: ${patient[AppStrings.patientPhone] ?? 'N/A'}'),
                      ],
                    );
                  }
                }),
          ),
          const Text(AppStrings.medicalReport),
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
                    return Text('${AppStrings.error} ${snapshot.error}',
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 30));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Column(
                      children: [
                        const Text(AppStrings.noMedicalHistoryFound,
                            style: TextStyle(color: Colors.blue, fontSize: 30)),
                        MyButton(
                          width: 500,
                          onTap: () {
                            AddMedicalReportDialog.showAddMedicalReportDialog(
                                context, widget.patientId);
                          },
                          text: AppStrings.addMedicalReport,
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
                                  '${AppStrings.allergiescolon} ${medicalHistory[AppStrings.allergies] ?? 'N/A'}'),
                              Text(
                                  '${AppStrings.medicationscolon} ${medicalHistory[AppStrings.medications] ?? 'N/A'}'),
                              Text(
                                  '${AppStrings.surgeriescolon} ${medicalHistory[AppStrings.surgeries] ?? 'N/A'}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  EditMedicalReportDialog
                                      .showEditMedicalReportDialog(
                                          context,
                                          medicalHistoryId,
                                          medicalHistory,
                                          widget.patientId);
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
          const Text(AppStrings.treatmentHistory),
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
                    return Text('${AppStrings.error} ${snapshot.error}',
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 30));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text(AppStrings.noTreatmentHistoryFound,
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
                                  '${AppStrings.treatmentcolon}  ${treatmentHistory[AppStrings.treatment] ?? 'N/A'}'),
                              Text(
                                  '${AppStrings.colondate} ${treatmentHistory[AppStrings.date] ?? 'N/A'}'),
                              Text(
                                  '${AppStrings.doctorcolon} ${treatmentHistory[AppStrings.doctorName] ?? 'N/A'}'),
                              Text(
                                  '${AppStrings.descriptioncolon} ${treatmentHistory[AppStrings.description] ?? 'N/A'}'),
                              Text(
                                  '${AppStrings.prescriptioncolon} ${treatmentHistory[AppStrings.prescription] ?? 'N/A'}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  EditTreatmentHistoryDialog
                                      .showEditTreatmentHistoryDialog(
                                          context,
                                          treatmentHistoryId,
                                          treatmentHistory,
                                          widget.patientId);
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
              AddTreatmentHistoryDialog.showAddTreatmentHistoryDialog(
                  context, widget.patientId);
            },
            text: AppStrings.addTreatmentHistory,
          ),
        ],
      ),
    );
  }
}
