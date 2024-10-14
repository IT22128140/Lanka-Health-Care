import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lanka_health_care/auth/auth.dart';
import 'package:lanka_health_care/components/drawers/drawer_HCP.dart';
import 'package:lanka_health_care/components/drawers/drawer_doctor.dart';
import 'package:lanka_health_care/firebase_options.dart';
import 'package:lanka_health_care/pages/appointments/add_appointment.dart';
import 'package:lanka_health_care/pages/appointments/appointments_HCP.dart';
import 'package:lanka_health_care/pages/appointments/appointments_doctor.dart';
import 'package:lanka_health_care/pages/doctor/availability.dart';
import 'package:lanka_health_care/pages/doctor/doctor_dashboard.dart';
import 'package:lanka_health_care/pages/healthcareprovider/healthcareprovider_dashboard.dart';
import 'package:lanka_health_care/pages/heathcaremanager/healthcaremanager_dashboard.dart';
import 'package:lanka_health_care/pages/patients/patients_details.dart';
import 'package:lanka_health_care/pages/patients/patients_page.dart';
import 'package:lanka_health_care/pages/payment/recurring_payment.dart';
import 'package:lanka_health_care/shared/constants.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with default options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the main application
  runApp(const MyApp());
}

// Main application widget
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        // Authentication page
        '/': (context) => const AuthPage(),

        // Patient details page with arguments
        '/patientDetails': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return PatientsDetails(patientId: args);
        },

        // Add appointment page
        '/add_appointment': (context) => const AddAppointment(),

        // Doctor related routes
        '/doctorDashboard': (context) => const DoctorDashboard(),
        '/healthcareManagerDashboard': (context) =>
            const HealthcaremanagerDashboard(),
        '/healthcareProviderDashboard': (context) =>
            const HealthcareproviderDashboard(),
        '/manageAvailability': (context) => const AvailabilityPage(),
        '/appointmentsDoctor': (context) => const AppointmentsDoctor(),
        '/patients': (context) => const PatientsPage(drawer: DrawerDoctor()),

        // Healthcare provider related routes
        '/hcpDashboard': (context) => const HealthcareproviderDashboard(),
        '/patientshcp': (context) => const PatientsPage(drawer: DrawerHcp()),
        '/appointmentshcp': (context) => const AppointmentsHcp(),
        '/recurringPayment': (context) => const RecurringPayment(),

        // Healthcare manager related routes
        '/hcmDashboard': (context) => const HealthcaremanagerDashboard(),
      },
    );
  }
}
