import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lanka_health_care/components/drawers/drawer_doctor.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/shared/constants.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService database = DatabaseService();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(AppStrings.docDashBoard),
        backgroundColor: Colors.white,
        elevation: 5.0, // This adds a shadow to the AppBar
        shadowColor: Colors.grey, // This sets the color of the shadow
      ),
      drawer: const DrawerDoctor(),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  AppStrings.appointmentstoday,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                StreamBuilder(
                    stream: database.getAppointmentsByDoctorUidAndDate(
                        FirebaseAuth.instance.currentUser!.uid,
                        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, AppStrings.zero)}-${DateTime.now().day.toString().padLeft(2, AppStrings.zero)}"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Column(
                        children: [
                          Text(
                              '${AppStrings.totalAppointments} ${snapshot.data!.docs.length}'),
                          const SizedBox(height: 10),
                          ...snapshot.data!.docs
                              .map<Widget>((documentSnapshot) {
                            return Column(
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      StreamBuilder<DocumentSnapshot>(
                                          stream: database.getPatientByUid(
                                              documentSnapshot[
                                                  AppStrings.patientUid]),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Text(
                                                  AppStrings.loading);
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  '${AppStrings.error} ${snapshot.error}');
                                            } else if (!snapshot.hasData ||
                                                !snapshot.data!.exists) {
                                              return const Text(
                                                  AppStrings.patientNotFound);
                                            } else {
                                              final DocumentSnapshot
                                                  querySnapshot =
                                                  snapshot.data!;
                                              return Text(
                                                  '${AppStrings.patientcolon} ${querySnapshot[AppStrings.patientfirstName]} ${querySnapshot[AppStrings.patientlastName]}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold));
                                            }
                                          }),
                                      Text(
                                          '${AppStrings.colondate} ${documentSnapshot[AppStrings.date]} ${AppStrings.colontime} ${documentSnapshot[AppStrings.time]}'),
                                      Text(
                                          '${AppStrings.colonstatus} ${documentSnapshot[AppStrings.status]}'),
                                      Text(
                                          '${AppStrings.colonpaymentStatus} ${documentSnapshot[AppStrings.paymentStatus]}'),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      );
                    }),
              ],
            ),
            const SizedBox(width: 30),
            Container(
              color: const Color.fromARGB(255, 229, 246, 255),
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(AppStrings.availability,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    StreamBuilder(
                        stream: database.getAvailability(
                            FirebaseAuth.instance.currentUser!.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Column(
                            children: [
                              Text(
                                  '${AppStrings.totAvailability} ${snapshot.data!.docs.length}'),
                              const SizedBox(height: 10),
                              const Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                              ...snapshot.data!.docs
                                  .map<Widget>((documentSnapshot) {
                                return Column(
                                  children: [
                                    Text(
                                        '${AppStrings.colonday} ${documentSnapshot[AppStrings.date]}'),
                                    Text(
                                        '${AppStrings.colonfrom} ${documentSnapshot[AppStrings.arrivetime]}'),
                                    Text(
                                        '${AppStrings.colonto} ${documentSnapshot[AppStrings.leavetime]}'),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              }).toList(),
                            ],
                          );
                        }),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
