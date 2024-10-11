import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lanka_health_care/components/drawers/drawer_custom.dart';

class DrawerHcm extends DrawerCustom {
  const DrawerHcm({super.key});

  @override
  String get title => 'Healthcare Manager Dashboard';

  @override
  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(
              child: Text('Doctor Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  )),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  title: const Text('Health Care Dashboard'),
                  onTap: () {
                    Navigator.pushNamed(context, '/hcmDashboard');
                  },
                ),
                ListTile(
                  title: const Text('Manage availability'),
                  onTap: () {
                    Navigator.pushNamed(context, '/manageAvailability');
                  },
                ),
                ListTile(
                  title: const Text('Patients'),
                  onTap: () {
                    Navigator.pushNamed(context, '/patients');
                  },
                ),
                ListTile(
                  title: const Text('Appointments'),
                  onTap: () {
                    Navigator.pushNamed(context, '/appointmentsDoctor');
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(30),
            child: ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sign Out'),
              onTap: () async {
                await signOut(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
