import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HealthcaremanagerDashboard extends StatelessWidget {
  const HealthcaremanagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare Manager Dashboard'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
          child: const Text('HCM Sign Out'),
        ),
      ),
    );
  }
}
