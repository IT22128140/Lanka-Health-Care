import 'package:flutter/material.dart';
import 'package:lanka_health_care/components/drawers/drawer_HCP.dart';
import 'package:flutter_web_qrcode_scanner/flutter_web_qrcode_scanner.dart';

import '../../shared/constants.dart';

class HealthcareproviderDashboard extends StatefulWidget {
  const HealthcareproviderDashboard({Key? key}) : super(key: key);

  @override
  State<HealthcareproviderDashboard> createState() =>
      _HealthcareproviderDashboardState();
}

class _HealthcareproviderDashboardState
    extends State<HealthcareproviderDashboard> {
      // Initialize variables
  String? _data;
  bool _restartScanner = true;
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // App bar
      appBar: AppBar(
        title: const Text(AppStrings.healthCareProDashBoard),
        backgroundColor: Colors.white,
        elevation: 5.0,
        shadowColor: Colors.grey,
      ),
      // Drawer
      drawer: const DrawerHcp(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Display the scanned data
          _data == null
              ? Container()
              : Center(
                  child: Text(
                    _data!,
                    style: const TextStyle(fontSize: 18, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Display the QR code scanner
          if (_restartScanner)
            FlutterWebQrcodeScanner(
              cameraDirection: CameraDirection.back,
              onGetResult: (patientId) {
                if (patientId.isNotEmpty && !_isNavigating) {
                  setState(() {
                    _isNavigating = true; // Ensure no further navigation
                    _restartScanner = false; // Stop the scanner temporarily
                  });

                  // Add a small delay to debounce any duplicate scans
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    Navigator.pushNamed(context, '/patientDetails',
                            arguments: patientId)
                        .then((_) {
                      // Reset the state when the user returns
                      setState(() {
                        _isNavigating = false;
                        _restartScanner = true; // Restart scanner for next scan
                      });
                    });
                  });
                }
              },
              stopOnFirstResult: true,
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              // Handle errors
              onError: (error) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text(AppStrings.error2),
                      content: Text('${AppStrings.error3} $error'),
                      actions: [
                        TextButton(
                          onPressed: Navigator.of(context).pop,
                          child: const Text(AppStrings.ok),
                        ),
                      ],
                    );
                  },
                );
              },
              // Handle permission denied error
              onPermissionDeniedError: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text(AppStrings.permissionDenied),
                    content: const Text(
                        AppStrings.cameraPermission),
                    actions: [
                      TextButton(
                        onPressed: Navigator.of(context).pop,
                        child: const Text(AppStrings.ok),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
