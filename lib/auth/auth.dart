import "package:lanka_health_care/auth/login_or_register.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:lanka_health_care/pages/doctor/doctor_dashboard.dart";
import "package:lanka_health_care/pages/healthcareprovider/healthcareprovider_dashboard.dart";
import "package:lanka_health_care/pages/heathcaremanager/healthcaremanager_dashboard.dart";
import "package:lanka_health_care/services/database.dart";

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  Future<String?> getUserType(User user) async {
    String? userType = await DatabaseService().getUserType(user.email!);
    return userType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            User? user = snapshot.data;
            return FutureBuilder<String?>(
              future: getUserType(user!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  String? userType = snapshot.data;
                  if (userType == 'doctor') {
                    return const DoctorDashboard();
                  } else if (userType == 'healthcaremanager') {
                    return const HealthcaremanagerDashboard();
                  }else if (userType == 'healthcareprovider') {
                    return const HealthcareproviderDashboard();
                  } else
                  {
                    return const LoginOrRegister();
                  }
                } else {
                  return const LoginOrRegister();
                }
              },
            );
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}