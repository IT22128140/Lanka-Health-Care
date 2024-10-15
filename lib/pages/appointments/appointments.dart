// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:lanka_health_care/shared/constants.dart';

class Appointments extends StatefulWidget {
  // Define the key
  const Appointments({super.key});

  @override
  State<Appointments> createState() => _AppointmentsState();
  
}

class _AppointmentsState extends State<Appointments> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Define the app bar
      appBar: AppBar(
        title: Text(AppStrings.appointments),
      ),
      // Define the body
      body: const Center(
        child: Text(AppStrings.appointmentsPage),
      ),
    );
  }
}
