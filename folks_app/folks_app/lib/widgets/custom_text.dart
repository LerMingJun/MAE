import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:folks_app/theming/custom_themes.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholderText;
  final IconData? icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.placeholderText,
    this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.black,
      controller: controller,
      decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon) : null,
          labelText: placeholderText,
          labelStyle: const TextStyle(color: Colors.black),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
              borderSide:
                  BorderSide(color: AppColors.secondary, width: 2.0))),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholderText;
  final IconData? icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.placeholderText,
    this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.black,
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon) : null,
          labelText: placeholderText,
          labelStyle: const TextStyle(color: Colors.black),
          border: const UnderlineInputBorder(),
          focusedBorder: const UnderlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.grey, width: 2.0))),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
    );
  }
}

class CustomIconText extends StatelessWidget {
  final String text;
  final IconData icon;
  final double size;
  final Color? color;

  const CustomIconText({
    required this.text,
    required this.icon,
    required this.size,
    this.color = AppColors.secondary,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: size + 5,
          color: color,
        ),
        SizedBox(width: 3),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: size,
              color: AppColors.placeholder,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class CustomLargeIconText extends StatelessWidget {
  final String text;
  final IconData icon;

  const CustomLargeIconText({
    required this.text,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        SizedBox(width: 3),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomNumberText extends StatelessWidget {
  final String number;
  final String text;

  const CustomNumberText({
    required this.number,
    required this.text,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: GoogleFonts.poppins(
            fontSize: 22,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
