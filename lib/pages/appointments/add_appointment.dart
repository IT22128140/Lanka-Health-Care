import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/pages/appointments/add_appointment_dialog.dart'; // Import the new file
import 'package:lanka_health_care/shared/constants.dart';

class AddAppointment extends StatefulWidget {
  const AddAppointment({super.key});

  @override
  State<AddAppointment> createState() => _AddAppointmentsState();
}

class _AddAppointmentsState extends State<AddAppointment> {
  final DatabaseService database = DatabaseService();
  final AddAppointmentDialog appointmentDialogue =
      AddAppointmentDialog(); // Create an instance of the new class

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addAppointment),
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: database.getDoctors(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(AppStrings.noDoctorsFound),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final doctor = snapshot.data!.docs[index];
                          final doctorId = snapshot.data!.docs[index].id;
                          return Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: ListTile(
                                title: Text(
                                    doctor[AppStrings.doctorFirstNameLabel] +
                                        ' ' +
                                        doctor[AppStrings.doctorLastNameLabel]),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(doctor[AppStrings.specialization]),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    StreamBuilder<QuerySnapshot>(
                                        stream:
                                            database.getAvailability(doctorId),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.blue),
                                              ),
                                            );
                                          } else if (!snapshot.hasData ||
                                              snapshot.data!.docs.isEmpty) {
                                            return const Text(
                                                AppStrings.notavailable);
                                          } else {
                                            return Column(
                                              children: snapshot.data!.docs
                                                  .map((availability) {
                                                return ListTile(
                                                  title: Text(availability[
                                                      AppStrings.date]),
                                                  subtitle: Text(
                                                      '${AppStrings.arriveTimeLabelcolon}  ${availability[AppStrings.arrivetime]} ${AppStrings.leaveTimeLabelcolon}  ${availability[AppStrings.leavetime]}'),
                                                  onTap: () => {
                                                    appointmentDialogue
                                                        .showAddAppointmentDialogue(
                                                            context,
                                                            doctorId,
                                                            availability)
                                                  },
                                                );
                                              }).toList(),
                                            );
                                          }
                                        }),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  })),
        ],
      ),
    );
  }
}
