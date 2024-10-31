import 'package:flutter/material.dart';
import 'package:folks_app/screens/user/filterOption.dart';


void showFilterOptions({
  required BuildContext context,
  required String selectedFilter,
  required List<String> selectedTags,
  required List<String> selectedTagIDs,
  required DateTime? selectedStartDate,
  required DateTime? selectedEndDate,
  required Function(String, List<String>, List<String>, DateTime?, DateTime?) onApplyFilters,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return FilterOptions(
        onApplyFilters: onApplyFilters,
        selectedFilter: selectedFilter,
        selectedTags: selectedTags,
        selectedTagIDs: selectedTagIDs,
        selectedStartDate: selectedStartDate,
        selectedEndDate: selectedEndDate,
      );
    },
  );
}
