import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lanka_health_care/models/appointment.dart';
import 'package:lanka_health_care/models/availability.dart';
import 'package:lanka_health_care/models/patients.dart';
import 'package:lanka_health_care/models/treatment_history.dart';
import 'package:lanka_health_care/models/medical_reports.dart';
import 'package:lanka_health_care/models/payment.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference appointmentCollection =
      FirebaseFirestore.instance.collection('appointments');

  final CollectionReference patientCollection =
      FirebaseFirestore.instance.collection('patients');

  //create user
  Future<void> createUser(String uid, String type, String email,
      String firstname, String lastname, String specialization) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'type': type,
        'email': email,
        'firstName': firstname,
        'lastName': lastname,
        'specialization': specialization,
      });
    } catch (e) {
      print(e);
    }
  }

  //get user by email
  Future<Map<String, dynamic>> getUser(String email, String type) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('type', isEqualTo: type)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      print(e);
      return {};
    }
  }

  //get user type by the email
  Future<String> getUserType(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return (querySnapshot.docs.first.data()
            as Map<String, dynamic>)['type'];
      } else {
        return '';
      }
    } catch (e) {
      print(e);
      return '';
    }
  }

  //get user by uid
  Future<Map<String, dynamic>> getUserByUid(String uid) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(uid).get();
      if (documentSnapshot.exists) {
        return documentSnapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      print(e);
      return {};
    }
  }

//doctors
  //get doctor names by uid
  Future<Map<String, dynamic>> getDoctorNamesByUid(String uid) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(uid).get();
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        return {
          'firstName': data['firstName'] as String,
          'lastName': data['lastName'] as String,
        };
      } else {
        return {};
      }
    } catch (e) {
      print(e);
      return {};
    }
  }

  //get doctor by firstName
  Future<List<Map<String, dynamic>>> getDoctorNamesByFirstName(
      String firstName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('type', isEqualTo: 'doctor')
          .get();

      return querySnapshot.docs
          .where((doc) => (doc.data() as Map<String, dynamic>)['firstName']
              .toString()
              .toLowerCase()
              .startsWith(firstName.toLowerCase()))
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id, // Fetch the document ID
          'firstName': data['firstName'] as String,
          'lastName': data['lastName'] as String,
        };
      }).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  //get doctors
  Stream<QuerySnapshot> getDoctors() {
    return userCollection.where('type', isEqualTo: 'doctor').snapshots();
  }

//appointments
  //create appointment
  Future<void> createAppointment(Appointment appointments) {
    return appointmentCollection.add(appointments.toMap());
  }

  //get appointment
  Stream<QuerySnapshot> getappointments() {
    return appointmentCollection.snapshots();
  }

  //get appointment by date
  Stream<QuerySnapshot> getAppointmentsByDate(String date) {
    return appointmentCollection.where('date', isEqualTo: date).snapshots();
  }

  //get appointments by doctor uid
  Stream<QuerySnapshot> getAppointmentsByDoctorUid(String doctorUid) {
    return appointmentCollection
        .where('doctoruid', isEqualTo: doctorUid)
        .snapshots();
  }

  //get appointments by doctor uid and date
  Stream<QuerySnapshot> getAppointmentsByDoctorUidAndDate(
      String doctorUid, String date) {
    return appointmentCollection
        .where('doctoruid', isEqualTo: doctorUid)
        .where('date', isEqualTo: date)
        .snapshots();
  }

  //get appointments by user uid
  Stream<QuerySnapshot> getAppointmentsByUserUid(String userUid) {
    return appointmentCollection
        .where('patientuid', isEqualTo: userUid)
        .snapshots();
  }

  //delete appointment
  Future<void> deleteAppointment(String uid) async {
    try {
      await appointmentCollection.doc(uid).delete();
    } catch (e) {
      print(e);
    }
  }

  //update appointment
  Future<void> updateAppointment(String uid, String date, String time) async {
    try {
      await appointmentCollection.doc(uid).update({
        'date': date,
        'time': time,
      });
    } catch (e) {
      print(e);
    }
  }

  //update appointment status
  Future<void> updateAppointmentStatus(String uid, String status) async {
    try {
      await appointmentCollection.doc(uid).update({
        'status': status,
      });
    } catch (e) {
      print(e);
    }
  }

  //update appointment payment status
  Future<void> updateAppointmentPaymentStatus(
      String uid, String paymentStatus) async {
    try {
      await appointmentCollection.doc(uid).update({
        'paymentStatus': paymentStatus,
      });
    } catch (e) {
      print(e);
    }
  }

  //get appointment count by month
  Future<double> getAppointmentCountByMonth(String month) async {
    try {
      QuerySnapshot querySnapshot = await appointmentCollection
          .where('date', isGreaterThanOrEqualTo: '$month-01')
          .where('date', isLessThanOrEqualTo: '$month-31')
          .get();
      return querySnapshot.docs.length.toDouble();
    } catch (e) {
      print(e);
      return 0;
    }
  }

  //get appoint count by week
  Future<double> getAppointmentCountByWeek(
      String startDate, String endDate) async {
    try {
      QuerySnapshot querySnapshot = await appointmentCollection
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .get();
      return querySnapshot.docs.length.toDouble();
    } catch (e) {
      print(e);
      return 0;
    }
  }

  //get appointment count by daily
  Future<double> getAppointmentCountByDay(String date, int dayOfWeek) async {
    try {
      QuerySnapshot querySnapshot = await appointmentCollection
          .where('date', isEqualTo: date)
          .where('dayOfWeek', isEqualTo: dayOfWeek)
          .get();
      return querySnapshot.docs.length.toDouble();
    } catch (e) {
      print(e);
      return 0;
    }
  }

  //create appointment and payment
  Future<void> createAppointmentAndPayment(
      Appointment appointments, Payment payment) async {
    try {
      DocumentReference documentReference =
          await appointmentCollection.add(appointments.toMap());
      await documentReference.collection('payments').add(payment.toMap());
    } catch (e) {
      print(e);
    }
  }

  //get appointments with reccuring payment
  Stream<QuerySnapshot> getAppointmentsWithRecurringPayment() {
    return appointmentCollection
        .where('paymentStatus', isEqualTo: 'Recurring')
        .snapshots();
  }

  //get appointment payment status
  Future<String> getAppointmentPaymentStatus(String uid) async {
    try {
      DocumentSnapshot documentSnapshot =
          await appointmentCollection.doc(uid).get();
      if (documentSnapshot.exists) {
        return (documentSnapshot.data()
            as Map<String, dynamic>)['paymentStatus'] as String;
      } else {
        return '';
      }
    } catch (e) {
      print(e);
      return '';
    }
  }

//payment
  //create payment
  Future<void> createPayment(Payment paymnet, String appointmentId) {
    return appointmentCollection
        .doc(appointmentId)
        .collection('payments')
        .add(paymnet.toMap());
  }

  //get payment by appointment id
  Stream<QuerySnapshot> getPaymentByAppointmentId(String appointmentId) {
    return appointmentCollection
        .doc(appointmentId)
        .collection('payments')
        .snapshots();
  }

  //edit payment
  Future<void> editPayment(
      String appointmentId, String paymentId, Payment paymnet) async {
    try {
      await appointmentCollection
          .doc(appointmentId)
          .collection('payments')
          .doc(paymentId)
          .update(paymnet.toMap());
    } catch (e) {
      print(e);
    }
  }

  //delete payment
  Future<void> deletePayment(String appointmentId, String paymentId) async {
    try {
      await appointmentCollection
          .doc(appointmentId)
          .collection('payments')
          .doc(paymentId)
          .delete();
    } catch (e) {
      print(e);
    }
  }

//availability
  //add availability
  Future<void> addAvailability(Availability availability, String uid) {
    return userCollection
        .doc(uid)
        .collection('availability')
        .add(availability.toMap());
  }

  //get availability for a doctor
  Stream<QuerySnapshot> getAvailability(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('availability')
        .snapshots();
  }

  //edit availability
  Future<void> editAvailability(
      String uid, String availabilityId, Availability availability) async {
    try {
      await userCollection
          .doc(uid)
          .collection('availability')
          .doc(availabilityId)
          .update(availability.toMap());
    } catch (e) {
      print(e);
    }
  }

  //delete availability
  Future<void> deleteAvailability(String uid, String availabilityId) async {
    try {
      await userCollection
          .doc(uid)
          .collection('availability')
          .doc(availabilityId)
          .delete();
    } catch (e) {
      print(e);
    }
  }

//patients
  //create patient
  Future<void> createPatient(Patients patients) {
    return patientCollection.add(patients.toMap());
  }

  //get patients
  Stream<QuerySnapshot> getPatients() {
    return patientCollection.snapshots();
  }

  //get patient by uid
  Stream<DocumentSnapshot> getPatientByUid(String uid) {
    return patientCollection.doc(uid).snapshots();
  }

  //edit patient
  Future<void> editPatient(String uid, Patients patients) async {
    try {
      await patientCollection.doc(uid).update(patients.toMap());
    } catch (e) {
      print(e);
    }
  }

  //delete patient
  Future<void> deletePatient(String uid) async {
    try {
      await patientCollection.doc(uid).delete();
    } catch (e) {
      print(e);
    }
  }

  //get patient by firstName
  Future<List<Map<String, dynamic>>> getPatientNamesByFirstName(
      String firstName) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('patients').get();

      return querySnapshot.docs
          .where((doc) => (doc.data() as Map<String, dynamic>)['firstName']
              .toString()
              .toLowerCase()
              .startsWith(firstName.toLowerCase()))
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id, // Fetch the document ID
          'firstName': data['firstName'] as String,
          'lastName': data['lastName'] as String,
        };
      }).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

//medical history
  //get patient medical report
  Stream<QuerySnapshot> getPatientMedicalReport(String uid) {
    return patientCollection.doc(uid).collection('medicalHistory').snapshots();
  }

  //add medical report
  Future<void> addMedicalReport(String uid, MedicalReports data) {
    return patientCollection
        .doc(uid)
        .collection('medicalHistory')
        .add(data.toMap());
  }

  //edit medical report
  Future<void> editMedicalReport(
      String uid, String medicalHistoryId, MedicalReports data) async {
    try {
      await patientCollection
          .doc(uid)
          .collection('medicalHistory')
          .doc(medicalHistoryId)
          .update(data.toMap());
    } catch (e) {
      print(e);
    }
  }

  //delete medical report
  Future<void> deleteMedicalReport(String uid, String medicalHistoryId) async {
    try {
      await patientCollection
          .doc(uid)
          .collection('medicalHistory')
          .doc(medicalHistoryId)
          .delete();
    } catch (e) {
      print(e);
    }
  }

//treating history
  //add treatment history
  Future<void> addTreatmentHistory(String uid, TreatmentHistory data) {
    return patientCollection
        .doc(uid)
        .collection('treatmentHistory')
        .add(data.toMap());
  }

  //get treatment history
  Stream<QuerySnapshot> getTreatmentHistory(String uid) {
    return patientCollection
        .doc(uid)
        .collection('treatmentHistory')
        .snapshots();
  }

  //edit treatment history
  Future<void> editTreatmentHistory(
      String uid, String treatmentHistoryId, TreatmentHistory data) async {
    try {
      await patientCollection
          .doc(uid)
          .collection('treatmentHistory')
          .doc(treatmentHistoryId)
          .update(data.toMap());
    } catch (e) {
      print(e);
    }
  }

  //delete treatment history
  Future<void> deleteTreatmentHistory(
      String uid, String treatmentHistoryId) async {
    try {
      await patientCollection
          .doc(uid)
          .collection('treatmentHistory')
          .doc(treatmentHistoryId)
          .delete();
    } catch (e) {
      print(e);
    }
  }
}
