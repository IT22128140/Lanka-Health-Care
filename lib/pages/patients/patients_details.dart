import 'dart:ui';
import 'dart:html' as html;

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
import 'package:qr_flutter/qr_flutter.dart';

class PatientsDetails extends StatefulWidget {
  final String patientId;

  const PatientsDetails({super.key, required this.patientId});

  @override
  State<PatientsDetails> createState() => _PatientsDetailsState();
}

class _PatientsDetailsState extends State<PatientsDetails> {
  // Initialize the required services and dialogs
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

// Calculate the age of the patient
  calculateAge(DateTime date) {
    var now = DateTime.now();
    var difference = now.difference(date);
    var age = difference.inDays ~/ 365;
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the app bar with the title
      appBar: AppBar(
        title: const Text(AppStrings.patientDetails),
        backgroundColor: Colors.white,
        elevation: 5.0,
        shadowColor: Colors.grey,
      ),
      // Display the patient details, medical history, and treatment history
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(AppStrings.patientDetails,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  // Display the patient details
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: StreamBuilder<DocumentSnapshot>(
                        stream:
                            databaseService.getPatientByUid(widget.patientId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                                // Display a loading indicator while the data is being fetched
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            // Display an error message if there is an error
                            return Text('${AppStrings.error} ${snapshot.error}',
                                style: const TextStyle(
                                    color: Colors.blue, fontSize: 30));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.data() == null) {
                                // Display a message if no patient is found
                            return const Text(AppStrings.noPatientFound,
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 30));
                          } else {
                            // Display the patient details
                            final patient =
                                snapshot.data!.data() as Map<String, dynamic>;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${AppStrings.patientFirstNameLabel}: ${patient[AppStrings.patientfirstName] ?? AppStrings.notAvailable}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                Text(
                                    '${AppStrings.patientLastNameLabel}: ${patient[AppStrings.patientlastName] ?? AppStrings.notAvailable}',
                                    style: const TextStyle(fontSize: 20)),
                                Text(
                                    '${AppStrings.patientDOBLabel}: ${patient[AppStrings.patientdob] != null ? DateFormat('yyyy-MM-dd').format((patient[AppStrings.patientdob] as Timestamp).toDate()) : AppStrings.notAvailable}',
                                    style: const TextStyle(fontSize: 20)),
                                Text(
                                    '${AppStrings.patientAgeLabel}: ${patient[AppStrings.patientdob] != null ? calculateAge((patient[AppStrings.patientdob] as Timestamp).toDate()) : AppStrings.notAvailable}',
                                    style: const TextStyle(fontSize: 20)),
                                Text(
                                    '${AppStrings.patientPhoneLabel}: ${patient[AppStrings.patientPhone] ?? AppStrings.notAvailable}',
                                    style: const TextStyle(fontSize: 20)),
                              ],
                            );
                          }
                        }),
                  ),
                ],
              ),
              // Display the QR code and download button
              Column(
                children: [
                  QrImageView(
                    data: widget.patientId,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  // Display the download button
                  MyButton(
                    onTap: () async {
                      final qrValidationResult = QrValidator.validate(
                        data: widget.patientId,
                        version: QrVersions.auto,
                        errorCorrectionLevel: QrErrorCorrectLevel.L,
                      );
                      if (qrValidationResult.status ==
                          QrValidationStatus.valid) {
                        final qrCode = qrValidationResult.qrCode!;
                        final painter = QrPainter.withQr(
                          qr: qrCode,
                          color: const Color(0xFF000000),
                          emptyColor: const Color(0xFFFFFFFF),
                          gapless: true,
                        );
                        final picData = await painter.toImageData(2048,
                            format: ImageByteFormat.png);
                        if (picData != null) {
                          final buffer = picData.buffer.asUint8List();
                          final blob = html.Blob([buffer]);
                          final url = html.Url.createObjectUrlFromBlob(blob);
                          final anchor = html.AnchorElement(href: url)
                            ..setAttribute(AppStrings.download, AppStrings.qrCodePng)
                            ..style.display = AppStrings.none;
                          html.document.body!.append(anchor);
                          anchor.click();
                          anchor.remove();
                          html.Url.revokeObjectUrl(url);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(AppStrings.downloadedQR)),
                          );
                        }
                      }
                    },
                    text: AppStrings.downloadQRCode,
                    width: 300,
                  ),
                ],
              ),
              // Display the medical history and treatment history
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(AppStrings.medicalReport,
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  StreamBuilder<QuerySnapshot>(
                      stream: databaseService
                          .getPatientMedicalReport(widget.patientId),
                      builder: (context, snapshot) {
                        // Display a loading indicator while the data is being fetched
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          // Display an error message if there is an error
                          return Text('${AppStrings.error} ${snapshot.error}',
                              style: const TextStyle(
                                  color: Colors.blue, fontSize: 30));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          // Display a message if no medical history is found
                          return Column(
                            children: [
                              // Display a message if no medical history is found
                              const Text(AppStrings.noMedicalHistoryFound,
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 30)),
                              // Display the add medical report button
                              MyButton(
                                width: 500,
                                onTap: () {
                                  AddMedicalReportDialog
                                      .showAddMedicalReportDialog(
                                          context, widget.patientId);
                                },
                                text: AppStrings.addMedicalReport,
                              ),
                            ],
                          );
                        } else {
                          // Display the medical history
                          return SizedBox(
                            width: 800,
                            height: 300,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final medicalHistory =
                                    snapshot.data!.docs[index].data()
                                        as Map<String, dynamic>;
                                final medicalHistoryId =
                                    snapshot.data!.docs[index].id;
                                return ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${AppStrings.allergiescolon} ${medicalHistory[AppStrings.allergies] ?? AppStrings.notAvailable}'),
                                      Text(
                                          '${AppStrings.medicationscolon} ${medicalHistory[AppStrings.medications] ?? AppStrings.notAvailable}'),
                                      Text(
                                          '${AppStrings.surgeriescolon} ${medicalHistory[AppStrings.surgeries] ?? AppStrings.notAvailable}'),
                                    ],
                                  ),
                                  // Display the edit and delete buttons
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
                                              widget.patientId,
                                              medicalHistoryId);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      }),
                ],
              )
            ],
          ),
          // Display the treatment history
          const Text(AppStrings.treatmentHistory,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          Expanded(
            child: SizedBox(
              width: 800,
              child: StreamBuilder<QuerySnapshot>(
                  stream: databaseService.getTreatmentHistory(widget.patientId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Display a loading indicator while the data is being fetched
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      // Display an error message if there is an error
                      return Text('${AppStrings.error} ${snapshot.error}',
                          style: const TextStyle(
                              color: Colors.blue, fontSize: 30));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                          // Display a message if no treatment history is found
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
                                    '${AppStrings.treatmentcolon}  ${treatmentHistory[AppStrings.treatment] ?? AppStrings.notAvailable}'),
                                Text(
                                    '${AppStrings.colondate} ${treatmentHistory[AppStrings.date] ?? AppStrings.notAvailable}'),
                                Text(
                                    '${AppStrings.doctorcolon} ${treatmentHistory[AppStrings.doctorName] ?? AppStrings.notAvailable}'),
                                Text(
                                    '${AppStrings.descriptioncolon} ${treatmentHistory[AppStrings.description] ?? AppStrings.notAvailable}'),
                                Text(
                                    '${AppStrings.prescriptioncolon} ${treatmentHistory[AppStrings.prescription] ?? AppStrings.notAvailable}'),
                              ],
                            ),
                            // Display the edit and delete buttons
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
          ),
          // Display the add treatment history button
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
            child: MyButton(
              width: 500,
              onTap: () {
                AddTreatmentHistoryDialog.showAddTreatmentHistoryDialog(
                    context, widget.patientId);
              },
              text: AppStrings.addTreatmentHistory,
            ),
          ),
        ],
      ),
    );
  }
}
