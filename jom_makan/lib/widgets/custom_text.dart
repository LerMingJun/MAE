import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/theming/custom_themes.dart';

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
              borderSide: BorderSide(color: AppColors.secondary, width: 2.0))),
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
              borderSide: BorderSide(color: Colors.grey, width: 2.0))),
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: size + 5,
          color: color,
        ),
        const SizedBox(width: 3),
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 3),
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
    super.key,
  });

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

class CustomDropdown extends StatefulWidget {
  final List<String> options;
  final List<String> selectedOptions;
  final ValueChanged<List<String>> onChanged;

  const CustomDropdown({
    super.key,
    required this.options,
    required this.selectedOptions,
    required this.onChanged,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final ScrollController _scrollController = ScrollController();
  
  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Options', style: GoogleFonts.poppins()),
          content: SizedBox(
            height: 400, // Fixed height for the dialog
            width: double.maxFinite,
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true, // Always show scrollbar
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Allow the column to expand as needed
                  children: widget.options.map((option) {
                    final isSelected = widget.selectedOptions.contains(option);
                    return CheckboxListTile(
                      title: Text(option, style: GoogleFonts.poppins()),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            widget.selectedOptions.add(option);
                          } else {
                            widget.selectedOptions.remove(option);
                          }
                          widget.onChanged(widget.selectedOptions);
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptionsDialog(context),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          widget.selectedOptions.isNotEmpty
              ? widget.selectedOptions.join(', ') // Join selected options
              : 'Select an option',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }
}

