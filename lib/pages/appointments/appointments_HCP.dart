import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:lanka_health_care/components/drawers/drawer_HCP.dart';
import 'package:lanka_health_care/components/my_button.dart';
import 'package:lanka_health_care/models/paymnet.dart';
import 'package:lanka_health_care/pages/appointments/appointments.dart';
import 'package:lanka_health_care/services/database.dart';

class AppointmentsHcp extends Appointments {
  const AppointmentsHcp({super.key});

  @override
  State<Appointments> createState() => _AppointmentsHcpState();
}

class _AppointmentsHcpState extends State<AppointmentsHcp> {
  final DatabaseService database = DatabaseService();
  final User user = FirebaseAuth.instance.currentUser!;
  late Stream<QuerySnapshot<Object?>> filteredData;

  @override
  void initState() {
    filteredData = database.getappointments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Appointments HCP'),
        ),
        drawer: const DrawerHcp(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    // Handle the selected date
                    setState(() {
                      filteredData = database.getAppointmentsByDate(
                          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}");
                    });
                  }
                },
                child: const Text('Select Date'),
              ),
              const SizedBox(height: 50),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: filteredData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        );
                      } else if (!snapshot.hasData ||
                          (snapshot.data as QuerySnapshot).docs.isEmpty) {
                        return const Text('No Appointments found',
                            style: TextStyle(color: Colors.blue, fontSize: 30));
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}',
                            style: const TextStyle(
                                color: Colors.blue, fontSize: 30));
                      } else {
                        final QuerySnapshot querySnapshot =
                            snapshot.data as QuerySnapshot;
                        return ListView.builder(
                          itemCount: querySnapshot.docs.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot documentSnapshot =
                                querySnapshot.docs[index];
                            return ListTile(
                              title: StreamBuilder<DocumentSnapshot>(
                                  stream: database.getPatientByUid(
                                      documentSnapshot['patientuid']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text('Loading...');
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (!snapshot.hasData ||
                                        !snapshot.data!.exists) {
                                      return const Text('Patient not found');
                                    } else {
                                      final DocumentSnapshot querySnapshot =
                                          snapshot.data!;
                                      return Text(
                                          'Patient: ${querySnapshot['firstName']} ${querySnapshot['lastName']}');
                                    }
                                  }),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Date: ${documentSnapshot['date']} Time: ${documentSnapshot['time']}'),
                                  Text('Status: ${documentSnapshot['status']}'),
                                  Text(
                                      'Payment Status: ${documentSnapshot['paymentStatus']}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        // _addPaymentDialog(
                                        //     context, documentSnapshot.id);
                                        _viewPaymentDialog(
                                            context, documentSnapshot.id);
                                      },
                                      icon: const Icon(Icons.payment)),
                                  IconButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/patientDetails',
                                            arguments:
                                                documentSnapshot['patientuid']);
                                      },
                                      icon: const Icon(Icons.visibility)),
                                  IconButton(
                                      onPressed: () {
                                        database.updateAppointmentStatus(
                                            documentSnapshot.id, 'Completed');
                                      },
                                      icon: const Icon(Icons.check)),
                                  IconButton(
                                      onPressed: () {
                                        database.updateAppointmentStatus(
                                            documentSnapshot.id, 'Cancelled');
                                      },
                                      icon: const Icon(Icons.cancel)),
                                  IconButton(
                                      onPressed: () {
                                        database.updateAppointmentStatus(
                                            documentSnapshot.id, 'Pending');
                                      },
                                      icon: const Icon(Icons.pending_actions)),
                                  IconButton(
                                      onPressed: () {
                                        database.deleteAppointment(
                                            documentSnapshot.id);
                                      },
                                      icon: const Icon(Icons.delete)),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    }),
              ),
              MyButton(
                  text: 'Add appointment',
                  onTap: () {
                    Navigator.pushNamed(context, '/add_appointment');
                  },
                  width: 500)
            ],
          ),
        ));
  }
}

class ViewPaymentDialog extends StatefulWidget {
  final String appointmentId;

  const ViewPaymentDialog({super.key, required this.appointmentId});

  @override
  _ViewPaymentDialogState createState() => _ViewPaymentDialogState();
}

class _ViewPaymentDialogState extends State<ViewPaymentDialog> {
  final DatabaseService database = DatabaseService();
  var paymentId;
  var payment;

  void _addPaymentDialog(BuildContext context, String appointmentId) {
    final TextEditingController bankNameController = TextEditingController();
    final TextEditingController accountNumberController =
        TextEditingController();
    final TextEditingController accountNameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController depositSlipController = TextEditingController();

    dynamic image;
    bool isImageSelected = false;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Payment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: bankNameController,
                    decoration: const InputDecoration(labelText: 'Bank Name'),
                  ),
                  TextField(
                    controller: accountNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Account Number'),
                  ),
                  TextField(
                    controller: accountNameController,
                    decoration:
                        const InputDecoration(labelText: 'Account Name'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      image = await ImagePickerWeb.getImageAsBytes();
                      if (image != null) {
                        setState(() {
                          isImageSelected = true;
                        });
                      }
                    },
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                  if (!isImageSelected)
                    const Text(
                      'Upload slip',
                      style:
                          TextStyle(color: Color.fromARGB(255, 250, 230, 35)),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          setState(() {
                            isUploading = true;
                          });
                          String uniqueName =
                              DateTime.now().millisecondsSinceEpoch.toString();

                          Reference refImages = FirebaseStorage.instance.ref();
                          Reference refImagesDir =
                              refImages.child('slip_images');
                          Reference referenceImageToUpload =
                              refImagesDir.child('$uniqueName.jpg');
                          try {
                            await referenceImageToUpload.putData(image);
                            String downloadUrl =
                                await referenceImageToUpload.getDownloadURL();
                            depositSlipController.text = downloadUrl;
                          } catch (e) {
                            debugPrint('Error uploading image: $e');
                          }
                          if (mounted) {
                            await database.createPayment(
                              Paymnet(
                                bankName: bankNameController.text,
                                accountNumber: accountNumberController.text,
                                accountName: accountNameController.text,
                                amount: amountController.text,
                                date: DateTime.now().toString(),
                                depositSlip: depositSlipController.text,
                              ),
                              appointmentId,
                            );
                            await database.updateAppointmentPaymentStatus(
                                appointmentId, 'Paid');
                            Navigator.of(context).pop();
                          }
                          setState(() {
                            isUploading = false;
                          });
                        },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editPaymentDialog(BuildContext context, String appointmentId) {
    final TextEditingController bankNameController = TextEditingController();
    final TextEditingController accountNumberController =
        TextEditingController();
    final TextEditingController accountNameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController depositSlipController = TextEditingController();

    dynamic image;
    bool isImageSelected = false;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Payment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: bankNameController,
                    decoration: const InputDecoration(labelText: 'Bank Name'),
                  ),
                  TextField(
                    controller: accountNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Account Number'),
                  ),
                  TextField(
                    controller: accountNameController,
                    decoration:
                        const InputDecoration(labelText: 'Account Name'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      image = await ImagePickerWeb.getImageAsBytes();
                      if (image != null) {
                        setState(() {
                          isImageSelected = true;
                        });
                      }
                    },
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                      size: 40,
                    ),
                  ),
                  if (!isImageSelected)
                    const Text(
                      'Upload slip',
                      style:
                          TextStyle(color: Color.fromARGB(255, 250, 230, 35)),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isUploading
                      ? null
                      : () async {
                          setState(() {
                            isUploading = true;
                          });
                          String uniqueName =
                              DateTime.now().millisecondsSinceEpoch.toString();

                          Reference refImages = FirebaseStorage.instance.ref();
                          Reference refImagesDir =
                              refImages.child('slip_images');
                          Reference referenceImageToUpload =
                              refImagesDir.child('$uniqueName.jpg');
                          try {
                            await referenceImageToUpload.putData(image);
                            String downloadUrl =
                                await referenceImageToUpload.getDownloadURL();
                            depositSlipController.text = downloadUrl;
                          } catch (e) {
                            debugPrint('Error uploading image: $e');
                          }
                          if (mounted) {
                            await database.editPayment(
                              appointmentId,
                              paymentId,
                              Paymnet(
                                bankName: bankNameController.text,
                                accountNumber: accountNumberController.text,
                                accountName: accountNameController.text,
                                amount: amountController.text,
                                date: DateTime.now().toString(),
                                depositSlip: depositSlipController.text,
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                          setState(() {
                            isUploading = false;
                          });
                        },
                  child: const Text('Edit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('View Payment'),
      content: SizedBox(
        height: 400, // Adjust the height as needed
        width: 300, // Adjust the width as needed
        child: StreamBuilder<QuerySnapshot>(
          stream: database.getPaymentByAppointmentId(widget.appointmentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No Payment found');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final documentSnapshot = snapshot.data!.docs[index];
                  paymentId = documentSnapshot.id;
                  payment = Paymnet.fromSnapshot(documentSnapshot);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bank Name: ${payment.bankName}'),
                      Text('Account Number: ${payment.accountNumber}'),
                      Text('Account Name: ${payment.accountName}'),
                      Text('Amount: ${payment.amount}'),
                      Text('Date: ${payment.date}'),
                      Image.network(
                        payment.depositSlip,
                        width: 100,
                        height: 100,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            );
                          }
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          debugPrint('Error loading image: $error');
                          debugPrint('Stack trace: $stackTrace');
                          return const Column(
                            children: [
                              Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 100,
                              ),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          );
                        },
                      )
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            database.deletePayment(widget.appointmentId, paymentId);
            database.updateAppointmentPaymentStatus(
                widget.appointmentId, 'Pending');
          },
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () {
            _addPaymentDialog(context, widget.appointmentId);
          },
          child: const Text('Add Payment'),
        ),
        TextButton(
          onPressed: () {
            _editPaymentDialog(context, widget.appointmentId);
          },
          child: const Text('Edit Payment'),
        ),
        TextButton(
          onPressed: () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}

void _viewPaymentDialog(BuildContext context, String appointmentId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ViewPaymentDialog(appointmentId: appointmentId);
    },
  );
}
