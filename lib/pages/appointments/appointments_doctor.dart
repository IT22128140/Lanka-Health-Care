import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lanka_health_care/components/drawers/drawer_doctor.dart';
import 'package:lanka_health_care/pages/appointments/appointments.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class AppointmentsDoctor extends Appointments {
  const AppointmentsDoctor({super.key});

  @override
  State<Appointments> createState() => _AppointmentsDoctorState();
}

class _AppointmentsDoctorState extends State<AppointmentsDoctor> {
  // Initialize the database service and the current user
  final DatabaseService database = DatabaseService();
  final User user = FirebaseAuth.instance.currentUser!;
  late Stream<QuerySnapshot<Object?>> filteredData;

  // Get the appointments for the doctor for the current date
  @override
  void initState() {
    // Get the appointments for the doctor for the current date
    filteredData = database.getAppointmentsByDoctorUidAndDate(user.uid,
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, AppStrings.zero)}-${DateTime.now().day.toString().padLeft(2, AppStrings.zero)}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Add the app bar
          title: const Text(AppStrings.appointmentsDoctor),
          backgroundColor: Colors.white,
          elevation: 5.0,
          shadowColor: Colors.grey,
        ),
        drawer: const DrawerDoctor(), // Add the doctor drawer
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 30,
              ),
              // Add a button to select a date
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: const BorderSide(
                        color: Colors.blue), // Added blue border
                  ),
                ),
                onPressed: () async {
                  // Show the date picker dialog
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      filteredData = database.getAppointmentsByDoctorUidAndDate(
                          user.uid,
                          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, AppStrings.zero)}-${selectedDate.day.toString().padLeft(2, AppStrings.zero)}");
                    });
                  }
                },
                child: const Text(AppStrings.selectDate,
                    style: TextStyle(color: Colors.blue)),
              ),
              const SizedBox(height: 50),
              // StreamBuilder to fetch and display the appointments
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: filteredData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show a loading indicator
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        );
                      } else if (!snapshot.hasData ||
                          (snapshot.data as QuerySnapshot).docs.isEmpty) {
                        // Show a message if no appointments are found
                        return const Text(AppStrings.noAppointmentsFound,
                            style: TextStyle(color: Colors.blue, fontSize: 30));
                      } else if (snapshot.hasError) {
                        // Show an error message if an error occurs
                        return Text('Error: ${snapshot.error}',
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 30));
                      } else {
                        // Display the appointments
                        final QuerySnapshot querySnapshot =
                            snapshot.data as QuerySnapshot;
                        return ListView.builder(
                          itemCount: querySnapshot.docs.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot documentSnapshot =
                                querySnapshot.docs[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              // Display the appointment details
                              child: ListTile(
                                title: StreamBuilder<DocumentSnapshot>(
                                    stream: database.getPatientByUid(
                                        documentSnapshot[
                                            AppStrings.patientUid]),
                                    builder: (context, snapshot) {
                                      // Display the patient name
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Text(AppStrings.loading);
                                      } else if (snapshot.hasError) {
                                        return Text(
                                            '${AppStrings.error} ${snapshot.error}');
                                      } else if (!snapshot.hasData ||
                                          !snapshot.data!.exists) {
                                        return const Text(
                                            AppStrings.patientNotFound);
                                      } else {
                                        final DocumentSnapshot querySnapshot =
                                            snapshot.data!;
                                        return Text(
                                            '${AppStrings.patientcolon} ${querySnapshot[AppStrings.patientfirstName]} ${querySnapshot[AppStrings.patientlastName]}'); // Display the patient name
                                      }
                                    }),
                                // Display the appointment details
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${AppStrings.colondate} ${documentSnapshot[AppStrings.date]} ${AppStrings.colontime} ${documentSnapshot[AppStrings.time]}'), // Display the date and time of the appointment
                                    Text(
                                        '${AppStrings.colonstatus} ${documentSnapshot[AppStrings.status]}'), // Display the status of the appointment
                                    Text(
                                        '${AppStrings.colonpaymentStatus} ${documentSnapshot[AppStrings.paymentStatus]}'), // Display the payment status of the appointment
                                  ],
                                ),
                                // Add buttons to view, complete, or cancel the appointment
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        // Add a button to view the patient details
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/patientDetails',
                                              arguments: documentSnapshot[
                                                  AppStrings.patientUid]);
                                        },
                                        icon: const Icon(Icons.visibility)),
                                    IconButton(
                                        // Add a button to complete the appointment
                                        onPressed: () {
                                          database.updateAppointmentStatus(
                                              documentSnapshot.id,
                                              AppStrings.completed);
                                        },
                                        icon: const Icon(Icons.check)),
                                    IconButton(
                                      // Add a button to cancel the appointment
                                      onPressed: () {
                                        database.updateAppointmentStatus(
                                            documentSnapshot.id,
                                            AppStrings.pending);
                                      },
                                      icon: const Icon(Icons.pending_actions),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    }),
              )
            ],
          ),
        ));
  }
}
