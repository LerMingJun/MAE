import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/theming/custom_themes.dart';

class EmptyWidget extends StatelessWidget {
  final String text;
  final String image;

  const EmptyWidget({
    required this.text,
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image,
                width: 200, fit: BoxFit.cover),
                const SizedBox(height:20),
            Text(
              text,
              style: GoogleFonts.poppins(
                  color: AppColors.primary, fontSize: 20),
                  textAlign: TextAlign.center,
            ),
          ],
        ),
      );
  }
}