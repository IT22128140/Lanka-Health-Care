import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/pages/appointments/add_appointment_dialog.dart';
import 'package:lanka_health_care/shared/constants.dart';

// StatefulWidget for adding an appointment
class AddAppointment extends StatefulWidget {
  // Key for AddAppointment
  const AddAppointment({super.key});

  @override
  // Create state for AddAppointment
  State<AddAppointment> createState() => _AddAppointmentsState();
}

class _AddAppointmentsState extends State<AddAppointment> {
  final DatabaseService database = DatabaseService(); // Database service instance
  final AddAppointmentDialog appointmentDialogue = AddAppointmentDialog(); // Create an instance of AddAppointmentDialog

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addAppointment), // App bar title
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: database.getDoctors(), // Stream to get doctors from Firestore
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show loading indicator while waiting for data
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // Show message if no doctors are found
                  return const Center(
                    child: Text(AppStrings.noDoctorsFound),
                  );
                } else {
                  // Display list of doctors
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doctor = snapshot.data!.docs[index]; // Get doctor data
                      final doctorId = snapshot.data!.docs[index].id; // Get doctor ID
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
                                  doctor[AppStrings.doctorLastNameLabel],
                            ), // Display doctor's name
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doctor[AppStrings.specialization]),
                                const SizedBox(
                                  height: 20,
                                ), // Display doctor's name and specialization
                                StreamBuilder<QuerySnapshot>(
                                  stream: database.getAvailability(doctorId), // Stream to get doctor's availability
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      // Show loading indicator while waiting for data
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                        ),
                                      );
                                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                      // Show message if no availability is found
                                      return const Text(AppStrings.notavailable);
                                    } else {
                                      // Display list of available times
                                      return Column(
                                        children: snapshot.data!.docs.map((availability) {
                                          return ListTile(
                                            title: Text(availability[AppStrings.date]),
                                            subtitle: Text(
                                              '${AppStrings.arriveTimeLabelcolon}  ${availability[AppStrings.arrivetime]} ${AppStrings.leaveTimeLabelcolon}  ${availability[AppStrings.leavetime]}',
                                            ), // Display available times
                                            onTap: () => {
                                              appointmentDialogue.showAddAppointmentDialogue( // Show add appointment dialogue
                                                context,
                                                doctorId,
                                                availability,
                                              ),
                                            },
                                          );
                                        }).toList(),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
