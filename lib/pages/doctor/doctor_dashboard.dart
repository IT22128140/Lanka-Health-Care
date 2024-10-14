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
      appBar: AppBar(
        title: const Text(AppStrings.docDashBoard),
      ),
      drawer: const DrawerDoctor(),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text(AppStrings.appointmentstoday),
                StreamBuilder(
                    stream: database.getAppointmentsByDoctorUidAndDate(
                        FirebaseAuth.instance.currentUser!.uid,
                        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}"),
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
                          ...snapshot.data!.docs
                              .map<Widget>((documentSnapshot) {
                            return Column(
                              children: [
                                Text(
                                    '${AppStrings.colondate} ${documentSnapshot[AppStrings.date]} ${AppStrings.colontime} ${documentSnapshot[AppStrings.time]}'),
                                Text('${AppStrings.colonstatus} ${documentSnapshot[AppStrings.status]}'),
                                Text(
                                    '${AppStrings.colonpaymentStatus} ${documentSnapshot[AppStrings.paymentStatus]}'),
                              ],
                            );
                          }).toList(),
                        ],
                      );
                    }),
              ],
            ),
            Column(
              children: [
                const Text(AppStrings.availability),
                const SizedBox(height: 10),
                StreamBuilder(
                    stream: database.getAvailability(
                        FirebaseAuth.instance.currentUser!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Column(
                        children: [
                          Text(
                              '${AppStrings.totAvailability} ${snapshot.data!.docs.length}'),
                          const SizedBox(height: 10),
                          ...snapshot.data!.docs
                              .map<Widget>((documentSnapshot) {
                            return Column(
                              children: [
                                Text('${AppStrings.colonday} ${documentSnapshot[AppStrings.date]}'),
                                Text('${AppStrings.colonfrom} ${documentSnapshot[AppStrings.arrivetime]}'),
                                Text('${AppStrings.colonto} ${documentSnapshot[AppStrings.leavetime]}'),
                                const SizedBox(height: 10),
                              ],
                            );
                          }).toList(),
                        ],
                      );
                    }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
