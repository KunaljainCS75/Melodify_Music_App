import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AuthGradientButton extends StatelessWidget {
  const AuthGradientButton({
    super.key, 
    required this.buttontext, 
    required this.onPressed
  });

  final String buttontext;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Pallete.gradient1,
            Pallete.gradient2,
          ],
        ),
      ),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: Size(MediaQuery.of(context).size.width, 55),
            backgroundColor: Pallete.transparentColor,
            shadowColor: Pallete.transparentColor
          ),
          onPressed: onPressed,
          child: Text(
            buttontext,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          )),
    );
  }
}
