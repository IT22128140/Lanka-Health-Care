import 'package:flutter/material.dart';

abstract class DrawerCustom extends StatelessWidget {
  const DrawerCustom({super.key});

  String get title;
  @override
  Widget build(BuildContext context);

  Future<void> signOut(BuildContext context) async {}
}
