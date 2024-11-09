import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/theming/custom_themes.dart';

class CustomLoading extends StatelessWidget {
  final String text;

  const CustomLoading({
    required this.text,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SpinKitWanderingCubes(
          color: AppColors.primary,
          size: 60.0,
        ),
        const SizedBox(height: 20),
        Text(text,
            style: GoogleFonts.lato(color: AppColors.primary, fontSize: 20,decoration: TextDecoration.none))
      ],
    );
  }
}

class CustomImageLoading extends StatelessWidget {
  final double? width;
  final double? height;

  const CustomImageLoading({
    required this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            //size: 25.0,
          ),
        ],
      ),
    );
  }
}
