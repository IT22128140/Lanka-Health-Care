import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lanka_health_care/models/appointment.dart';
import 'package:lanka_health_care/services/database.dart';

class AddAppointment extends StatefulWidget {
  const AddAppointment({super.key});

  @override
  State<AddAppointment> createState() => _AddAppointmentsState();
}

class _AddAppointmentsState extends State<AddAppointment> {
  final DatabaseService database = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Appointments'),
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
                        child: Text('No Doctors Found'),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final doctor = snapshot.data!.docs[index];
                          final doctorId = snapshot.data!.docs[index].id;
                          return ListTile(
                            title: Text(
                                doctor['firstName'] + ' ' + doctor['lastName']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doctor['specialization']),
                                const SizedBox(
                                  height: 20,
                                ),
                                StreamBuilder<QuerySnapshot>(
                                    stream: database.getAvailability(doctorId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.blue),
                                          ),
                                        );
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.docs.isEmpty) {
                                        return const Text(
                                            'No Availability Found');
                                      } else {
                                        return Column(
                                          children: snapshot.data!.docs
                                              .map((availability) {
                                            return ListTile(
                                              title: Text(availability['date']),
                                              subtitle: Text(
                                                  'Arrive Time: ${availability['arrivetime']} Leave Time: ${availability['leavetime']}'),
                                              onTap: () => {
                                                _showAddApointmentDialogue(
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
                          );
                        },
                      );
                    }
                  })),
        ],
      ),
    );
  }

  void _showAddApointmentDialogue(
      BuildContext context, doctorid, availability) {
    final DatabaseService databaseService = DatabaseService();
    final TextEditingController patient = TextEditingController();
    final TextEditingController patientuidController = TextEditingController();
    final TextEditingController dateController = TextEditingController();

    DateTime _getInitialDate() {
      DateTime now = DateTime.now();
      // If today is not Monday, find the next Monday
      while (now.weekday != DateTime.monday) {
        now = now.add(const Duration(days: 1));
      }
      return now;
    }

    // Convert the available day strings into corresponding weekday numbers
    List<int> _getAvailableWeekdays(dynamic availableDays) {
      Map<String, int> daysOfWeek = {
        'Sunday': DateTime.sunday,
        'Monday': DateTime.monday,
        'Tuesday': DateTime.tuesday,
        'Wednesday': DateTime.wednesday,
        'Thursday': DateTime.thursday,
        'Friday': DateTime.friday,
        'Saturday': DateTime.saturday,
      };

      if (availableDays is String) {
        // If a single string (e.g., "Sunday"), return a list with one weekday number
        return [daysOfWeek[availableDays]!];
      } else if (availableDays is List<String>) {
        // If a list of strings (e.g., ["Sunday", "Monday"]), map to weekday numbers
        return availableDays.map((day) => daysOfWeek[day]!).toList();
      }
      return [];
    }

// Find the next available date based on the allowed weekdays
    DateTime _getNextAvailableDate(List<int> availableWeekdays) {
      DateTime now = DateTime.now();

      // Loop through the next days to find the first available one
      while (!availableWeekdays.contains(now.weekday)) {
        now = now.add(const Duration(days: 1));
      }
      return now;
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Appointment'),
            content: Column(
              children: [
                Text(availability['date']),
                Text(availability['arrivetime']),
                Autocomplete<Map<String, dynamic>>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Map<String, dynamic>>.empty();
                    }
                    final patientList = await databaseService
                        .getPatientNamesByFirstName(textEditingValue.text);
                    return patientList.where((patient) {
                      return (patient['firstName'] ?? '')
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    }).map((doctor) => {
                          'id': doctor['id'] ?? '',
                          'firstName': doctor['firstName'] ?? '',
                          'lastName': doctor['lastName'] ?? '',
                        });
                  },
                  displayStringForOption: (Map<String, dynamic> option) =>
                      (option['firstName'] ?? '') +
                      ' ' +
                      (option['lastName'] ?? ''),
                  onSelected: (Map<String, dynamic> selection) {
                    patient.text = (selection['firstName'] ?? '') +
                        ' ' +
                        (selection['lastName'] ?? '');
                    patientuidController.text = selection['id'] ?? '';
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: 'Patient'),
                    );
                  },
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(hintText: 'Date'),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());

                    // Handle both string (single day) and list of strings (multiple days)
                    List<int> availableWeekdays =
                        _getAvailableWeekdays(availability['date']);

                    // Get the next available date based on available weekdays
                    DateTime initialDate =
                        _getNextAvailableDate(availableWeekdays);

                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate:
                          initialDate, // Ensure initialDate is one of the available days
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                      selectableDayPredicate: (DateTime date) {
                        // Allow only the available weekdays to be selected
                        return availableWeekdays.contains(date.weekday);
                      },
                    );

                    if (pickedDate != null) {
                      setState(() {
                        dateController.text =
                            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    database.createAppointment(Appointment(
                        doctoruid: doctorid,
                        patientuid: patientuidController.text,
                        date: dateController.text,
                        time: availability['arrivetime'],
                        status: 'Pending',
                        paymentStatus: 'Pending'));

                    Navigator.pop(context);
                  },
                  child: const Text('Add'))
            ],
          );
        });
  }
}
