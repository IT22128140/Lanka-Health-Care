import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lanka_health_care/components/drawers/drawer_doctor.dart';
import 'package:lanka_health_care/components/my_button.dart';
import 'package:lanka_health_care/models/availability.dart';
import 'package:lanka_health_care/services/database.dart';
import 'edit_availability_dialog.dart';

class AvailabilityPage extends StatefulWidget {
  const AvailabilityPage({super.key});

  @override
  State<StatefulWidget> createState() => _AvailabilityState();
}

class _AvailabilityState extends State<AvailabilityPage> {
  final DatabaseService database = DatabaseService();
  final User user = FirebaseAuth.instance.currentUser!;

  final TextEditingController dateController = TextEditingController();
  final TextEditingController arrivetimeController = TextEditingController();
  final TextEditingController leavetimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability'),
      ),
      drawer: const DrawerDoctor(),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: database.getAvailability(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    );
                  } else if (!snapshot.hasData ||
                      (snapshot.data as QuerySnapshot).docs.isEmpty) {
                    return const Text('No availability found',
                        style: TextStyle(color: Colors.blue, fontSize: 30));
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 30));
                  } else {
                    final QuerySnapshot availability =
                        snapshot.data as QuerySnapshot;
                    return ListView.builder(
                      itemCount: availability.docs.length,
                      itemBuilder: (context, index) {
                        final data = availability.docs[index].data()
                            as Map<String, dynamic>;
                        final dataid = availability.docs[index].id;
                        return ListTile(
                          title: Text(data['date']),
                          subtitle: Text(
                              '${data['arrivetime']} - ${data['leavetime']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  EditAvailabilityDialog()
                                      .show(context, data, dataid, user.uid);
                                },
                              ),
                              const SizedBox(width: 30),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  database.deleteAvailability(user.uid, dataid);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            // Add availability
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: dateController.text.isEmpty
                        ? null
                        : dateController.text,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                    ),
                    items: <String>[
                      'Sunday',
                      'Monday',
                      'Tuesday',
                      'Wednesday',
                      'Thursday',
                      'Friday',
                      'Saturday',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        dateController.text = newValue!;
                      });
                    },
                  ),
                  TextField(
                    controller: arrivetimeController,
                    decoration: const InputDecoration(
                      labelText: 'Arrival Time',
                    ),
                    onTap: () => showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    ).then((value) {
                      if (value != null) {
                        arrivetimeController.text = value.format(context);
                      }
                    }),
                  ),
                  TextField(
                    controller: leavetimeController,
                    decoration: const InputDecoration(
                      labelText: 'Leave Time',
                    ),
                    onTap: () => showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    ).then((value) {
                      if (value != null) {
                        leavetimeController.text = value.format(context);
                      }
                    }),
                  ),
                  MyButton(
                    text: 'Add Availability',
                    onTap: () {
                      database.addAvailability(
                        Availability(
                          date: dateController.text,
                          arrivetime: arrivetimeController.text,
                          leavetime: leavetimeController.text,
                        ),
                        user.uid,
                      );
                    },
                    width: 500,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
