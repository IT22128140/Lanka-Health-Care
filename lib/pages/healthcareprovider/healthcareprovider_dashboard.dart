import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lanka_health_care/components/drawers/drawer_HCP.dart';

class HealthcareproviderDashboard extends StatelessWidget {
  const HealthcareproviderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare Provider Dashboard'),
      ),
      drawer: const DrawerHcp(),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
          child: const Text('HCP Sign Out'),
        ),
      ),
    );
  }
}
