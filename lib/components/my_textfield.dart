import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final double width;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // Set the desired width here
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          hintText: hintText,
          fillColor: Colors.white,
          filled: true,
        ),
        obscureText: obscureText,
      ),
    );
  }
}
