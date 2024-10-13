import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lanka_health_care/components/drawers/drawer_HCP.dart';
import 'package:lanka_health_care/pages/appointments/appointments.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:lanka_health_care/pages/payment/show_payment.dart';

class RecurringPayment extends Appointments {
  const RecurringPayment({super.key});

  @override
  State<Appointments> createState() => _RecurrinfPaymentState();
}

class _RecurrinfPaymentState extends State<RecurringPayment> {
  final DatabaseService database = DatabaseService();
  final User user = FirebaseAuth.instance.currentUser!;
  late Stream<QuerySnapshot<Object?>> filteredData;

  @override
  void initState() {
    filteredData = database.getAppointmentsWithRecurringPayment();
    super.initState();
  }

late String paymentStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Appointments HCP'),
        ),
        drawer: const DrawerHcp(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                        return const Text('No Appointments found',
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
                            paymentStatus = documentSnapshot['paymentStatus'];
                            return ListTile(
                              title: StreamBuilder<DocumentSnapshot>(

                                  stream: database.getPatientByUid(
                                      documentSnapshot['patientuid']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text('Loading...');
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (!snapshot.hasData ||
                                        !snapshot.data!.exists) {
                                      return const Text('Patient not found');
                                    } else {
                                      final DocumentSnapshot querySnapshot =
                                          snapshot.data!;
                                      return Text(
                                          'Patient: ${querySnapshot['firstName']} ${querySnapshot['lastName']}');
                                    }
                                  }),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Date: ${documentSnapshot['date']} Time: ${documentSnapshot['time']}'),
                                  Text('Status: ${documentSnapshot['status']}'),
                                  Text(
                                      'Payment Status: ${documentSnapshot['paymentStatus']}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        _viewPaymentDialog(
                                            context, documentSnapshot.id, paymentStatus);
                                      },
                                      icon: const Icon(Icons.payment)),
                                  IconButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/patientDetails',
                                            arguments:
                                                documentSnapshot['patientuid']);
                                      },
                                      icon: const Icon(Icons.visibility)),
                                  IconButton(
                                      onPressed: () {
                                        database.updateAppointmentStatus(
                                            documentSnapshot.id, 'Completed');
                                      },
                                      icon: const Icon(Icons.check)),
                                  IconButton(
                                      onPressed: () {
                                        database.updateAppointmentStatus(
                                            documentSnapshot.id, 'Cancelled');
                                      },
                                      icon: const Icon(Icons.cancel)),
                                  IconButton(
                                      onPressed: () {
                                        database.updateAppointmentStatus(
                                            documentSnapshot.id, 'Pending');
                                      },
                                      icon: const Icon(Icons.pending_actions)),
                                  IconButton(
                                      onPressed: () {
                                        database.deleteAppointment(
                                            documentSnapshot.id);
                                      },
                                      icon: const Icon(Icons.delete)),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    }),
              ),
            ],
          ),
        ));
  }
}

void _viewPaymentDialog(BuildContext context, String appointmentId, String paymentStatus) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ViewPaymentDialog(appointmentId: appointmentId, paymentStatus: paymentStatus);
    },
  );
}
