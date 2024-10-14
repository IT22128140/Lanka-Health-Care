import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lanka_health_care/components/drawers/drawer_doctor.dart';
import 'package:lanka_health_care/components/my_button.dart';
import 'package:lanka_health_care/models/availability.dart';
import 'package:lanka_health_care/services/database.dart';
import 'edit_availability_dialog.dart';
import 'package:lanka_health_care/shared/constants.dart';

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
        title: const Text(AppStrings.availability),
        backgroundColor: Colors.white,
        elevation: 5.0, // This adds a shadow to the AppBar
        shadowColor: Colors.grey,
      ),
      drawer: const DrawerDoctor(),
      body: Center(
        child: Row(
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
                    return const Text(AppStrings.notavailable,
                        style: TextStyle(color: Colors.blue, fontSize: 30));
                  } else if (snapshot.hasError) {
                    return Text('${AppStrings.error}: ${snapshot.error}',
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
                          title: Text(data[AppStrings.date]),
                          subtitle: Text(
                              '${data[AppStrings.arrivetime]} - ${data[AppStrings.leavetime]}'),
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
              padding: const EdgeInsets.all(30.0),
              child: Container(
                width: 300,
                color: const Color.fromARGB(255, 229, 246, 255),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        AppStrings.addavailability,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 300, // Set a specific width
                        child: DropdownButtonFormField<String>(
                          value: dateController.text.isEmpty
                              ? null
                              : dateController.text,
                          decoration: InputDecoration(
                            labelText: AppStrings.dateLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          items: <String>[
                            AppStrings.sunday,
                            AppStrings.monday,
                            AppStrings.tuesday,
                            AppStrings.wednesday,
                            AppStrings.thursday,
                            AppStrings.friday,
                            AppStrings.saturday,
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
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 300, // Set a specific width
                        child: TextField(
                          controller: arrivetimeController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            labelText: AppStrings.arrivallabeltext,
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
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 300, // Set a specific width
                        child: TextField(
                          controller: leavetimeController,
                          decoration: InputDecoration(
                            labelText: AppStrings.leavelabeltext,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fillColor: Colors.white,
                            filled: true,
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
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: MyButton(
                          text: AppStrings.addavailability,
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
                          width: 300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
