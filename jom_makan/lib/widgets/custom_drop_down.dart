import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final List<String> options;
  final List<String> selectedOptions;
  final Function(List<String>) onChanged;

  CustomDropdown({
    required this.options,
    required this.selectedOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Select Cuisine',
        border: OutlineInputBorder(),
      ),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: (String? value) {
        if (value != null && !selectedOptions.contains(value)) {
          List<String> updated = List.from(selectedOptions)..add(value);
          onChanged(updated);
        }
      },
      value: null,
      isExpanded: true,
      // To allow multiple selections, you might need a custom implementation or use a different package
    );
  }
}
