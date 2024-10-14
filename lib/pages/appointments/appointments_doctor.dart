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
  final DatabaseService database = DatabaseService();
  final User user = FirebaseAuth.instance.currentUser!;
  late Stream<QuerySnapshot<Object?>> filteredData;
  @override
  void initState() {
    filteredData = database.getAppointmentsByDoctorUidAndDate(user.uid,
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, AppStrings.zero)}-${DateTime.now().day.toString().padLeft(2, AppStrings.zero)}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.appointmentsDoctor),
        ),
        drawer: const DrawerDoctor(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
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
                child: const Text(AppStrings.selectDate),
              ),
              const SizedBox(height: 50),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: filteredData,
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
                        return const Text(AppStrings.noAppointmentsFound,
                            style: TextStyle(color: Colors.blue, fontSize: 30));
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}',
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 30));
                      } else {
                        final QuerySnapshot querySnapshot =
                            snapshot.data as QuerySnapshot;
                        return ListView.builder(
                          itemCount: querySnapshot.docs.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot documentSnapshot =
                                querySnapshot.docs[index];
                            return ListTile(
                              title: StreamBuilder<DocumentSnapshot>(
                                  stream: database.getPatientByUid(
                                      documentSnapshot[AppStrings.patientUid]),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text(AppStrings.loading);
                                    } else if (snapshot.hasError) {
                                      return Text('${AppStrings.error} ${snapshot.error}');
                                    } else if (!snapshot.hasData ||
                                        !snapshot.data!.exists) {
                                      return const Text(AppStrings.patientNotFound);
                                    } else {
                                      final DocumentSnapshot querySnapshot =
                                          snapshot.data!;
                                      return Text(
                                          '${AppStrings.patientcolon} ${querySnapshot[AppStrings.patientfirstName]} ${querySnapshot[AppStrings.patientlastName]}');
                                    }
                                  }),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${AppStrings.colondate} ${documentSnapshot[AppStrings.date]} ${AppStrings.colontime} ${documentSnapshot[AppStrings.time]}'),
                                  Text('${AppStrings.colonstatus} ${documentSnapshot[AppStrings.status]}'), 
                                  Text(
                                      '${AppStrings.colonpaymentStatus} ${documentSnapshot[AppStrings.paymentStatus]}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/patientDetails',
                                            arguments:
                                                documentSnapshot[AppStrings.patientUid]);
                                      },
                                      icon: const Icon(Icons.visibility)),
                                  IconButton(
                                      onPressed: () {
                                        database.updateAppointmentStatus(
                                            documentSnapshot.id, AppStrings.completed);
                                      },
                                      icon: const Icon(Icons.check)),
                                  IconButton(
                                    onPressed: () {
                                      database.updateAppointmentStatus(
                                          documentSnapshot.id, AppStrings.pending);
                                    },
                                    icon: const Icon(Icons.pending_actions),
                                  ),
                                ],
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
