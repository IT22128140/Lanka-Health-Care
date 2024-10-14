import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lanka_health_care/components/drawers/drawer_custom.dart';
import 'package:lanka_health_care/shared/constants.dart';

class DrawerDoctor extends DrawerCustom {
  const DrawerDoctor({Key? key}) : super(key: key);

  @override
  String get title => AppStrings.docDashBoard;

  @override
  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(
              child: Text(AppStrings.docDashBoard,
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
                  title: const Text(AppStrings.docDashBoard),
                  onTap: () {
                    Navigator.pushNamed(context, '/doctorDashboard');
                  },
                ),
                ListTile(
                  title: const Text(AppStrings.manageavailability),
                  onTap: () {
                    Navigator.pushNamed(context, '/manageAvailability');
                  },
                ),
                ListTile(
                  title: const Text(AppStrings.patients),
                  onTap: () {
                    Navigator.pushNamed(context, '/patients');
                  },
                ),
                ListTile(
                  title: const Text(AppStrings.appointments),
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
              title: const Text(AppStrings.signout),
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
