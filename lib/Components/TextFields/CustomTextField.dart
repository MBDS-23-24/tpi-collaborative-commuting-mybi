import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

enum InputType {
  text,
  email,
  password,
  phone,
}

class CustomTextField extends StatelessWidget {
  final InputType inputType;
  final String labelText;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;

  CustomTextField({
    required this.inputType,
    required this.labelText,
    required this.hintText,
    this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    TextInputType keyboardType;
    switch (inputType) {
      case InputType.email:
        keyboardType = TextInputType.emailAddress;
        break;
      case InputType.password:
        keyboardType = TextInputType.text;
        break;
      case InputType.phone:
        keyboardType = TextInputType.phone;
        break;
      case InputType.text:
      default:
        keyboardType = TextInputType.text;
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.8, 
      height: 50.0, // Hauteur fixe
      child: TextField(
        keyboardType: keyboardType,
        controller: controller,
        obscureText: obscureText && inputType == InputType.password,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}


