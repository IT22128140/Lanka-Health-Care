import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final double width;

  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ,
      child : Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Text(
            text,
            style:const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            )
          )
        ),
      ),
    );
  }
}