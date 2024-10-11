import "package:flutter/material.dart";

//display error message to the user
void displayMessageToUser(String message, BuildContext context) {
  showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      title: Text(message),
    ),
  );
}