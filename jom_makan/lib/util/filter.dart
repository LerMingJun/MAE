// import 'package:flutter/material.dart';
// import 'package:jom_makan/screens/user/filterOption.dart';

// void showFilterOptions({
//   required BuildContext context,
//   required String selectedFilter,
//   required List<String> selectedTags,
//   required List<String> selectedTagIDs,
//   required String? selectedLocation, // New parameter
//   required bool sortByRatingDesc, // New parameter
//   required Function(String, List<String>, List<String>, String?, bool)
//       onApplyFilters,
// }) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (context) {
//       return FilterOptions(
//         onApplyFilters: onApplyFilters,
//         selectedFilter: selectedFilter,
//         selectedTags: selectedTags,
//         selectedLocation: selectedLocation, // Pass the location
//         sortByRatingDesc: sortByRatingDesc, // Pass the rating sort order
//       );
//     },
//   );
// }
