import 'package:flutter/material.dart';

class MyDeleteButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const MyDeleteButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(15),
        child: Center(
            child: Text(text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ))),
      ),
    );
  }
}
 