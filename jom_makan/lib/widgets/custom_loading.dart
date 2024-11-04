import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/theming/custom_themes.dart';

class CustomLoading extends StatelessWidget {
  final String text;

  const CustomLoading({
    required this.text,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitWanderingCubes(
          color: AppColors.primary,
          size: 60.0,
        ),
        SizedBox(height: 20),
        Text(text,
            style: GoogleFonts.lato(color: AppColors.primary, fontSize: 20))
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height!=null ? height : null,
      child: Column(
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
