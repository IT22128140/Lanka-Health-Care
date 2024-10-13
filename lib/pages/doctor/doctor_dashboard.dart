import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lanka_health_care/components/drawers/drawer_doctor.dart';
import 'package:lanka_health_care/services/database.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService database = DatabaseService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
      ),
      drawer: const DrawerDoctor(),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text('Appointments Today'),
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
                              'Total Appointments: ${snapshot.data!.docs.length}'),
                          ...snapshot.data!.docs
                              .map<Widget>((documentSnapshot) {
                            return Column(
                              children: [
                                Text(
                                    'Date: ${documentSnapshot['date']} Time: ${documentSnapshot['time']}'),
                                Text('Status: ${documentSnapshot['status']}'),
                                Text(
                                    'Payment Status: ${documentSnapshot['paymentStatus']}'),
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
                const Text('Availability'),
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
                              'Total Availability: ${snapshot.data!.docs.length}'),
                          const SizedBox(height: 10),
                          ...snapshot.data!.docs
                              .map<Widget>((documentSnapshot) {
                            return Column(
                              children: [
                                Text('Day: ${documentSnapshot['date']}'),
                                Text('From: ${documentSnapshot['arrivetime']}'),
                                Text('To: ${documentSnapshot['leavetime']}'),
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
