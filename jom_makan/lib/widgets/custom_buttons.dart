import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theming/custom_themes.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary, // Text color
        textStyle: GoogleFonts.poppins(fontSize: 16),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Border radius
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class CustomOptOutButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomOptOutButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary, // Text color
        textStyle: GoogleFonts.poppins(fontSize: 16),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.placeholder),
          borderRadius: BorderRadius.circular(5), // Border radius
        ),
      ),
      onPressed: onPressed,

      
      child: Text(text),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String imagePath;
  final String text;

  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.imagePath,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          side: const BorderSide(color: AppColors.placeholder)),
      onPressed: onPressed,
      child: Row(
        children: [
          Image.asset(
            imagePath,
            height: 25.0,
          ),
          SizedBox(width: 10),
          Text(text, style: GoogleFonts.lato(color: Colors.black))
        ],
      ),
    );
  }
}
