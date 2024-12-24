import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  const CustomField({
    super.key, 
    required this.hintText,
    this.controller,
    this.isObscure = false,
    this.readOnly = false,
    this.onTap
    });

  final String hintText;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final bool isObscure;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      readOnly: readOnly,
      controller: controller,
      validator:(value) {
        if (value!.trim().isEmpty){
          return "$hintText is missing!";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hintText,
      ),
      obscureText: isObscure,
    );
  }
}