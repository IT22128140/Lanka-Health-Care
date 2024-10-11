import 'package:flutter/material.dart ';

class PatientsHCM extends StatefulWidget {
  const PatientsHCM({Key? key}) : super(key: key);

  @override
  State<PatientsHCM> createState() => _PatientsHCMState();
}

class _PatientsHCMState extends State<PatientsHCM> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
      ),
      body: const Center(
        child: Text('Patients Page'),
      ),
    );
  }
}