import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/constants/options.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_buttons.dart';

class FilterOptions extends StatefulWidget {
  final Function(List<String>, List<String>, String) onApplyFilters;
  final List<String> selectedFilter;
  final List<String> selectedTags;
  final String sortByRatingDesc;

  FilterOptions({
    required this.onApplyFilters,
    required this.selectedFilter,
    required this.selectedTags,
    this.sortByRatingDesc = 'High to Low',
  });

  @override
  _FilterOptionsState createState() => _FilterOptionsState();
}

class _FilterOptionsState extends State<FilterOptions> {
  List<String> _selectedFilter = [];
  List<String> _selectedTags = [];
  String _sortByRatingDesc = 'High to Low'; // Update to String
  bool _isCuisineExpanded = false;
  bool _isTagsExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedFilter = List.from(widget.selectedFilter);
    _selectedTags = List.from(widget.selectedTags);
    _sortByRatingDesc = widget.sortByRatingDesc;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter by Type',
              style:
                  GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Cuisine Type Toggle Section
            GestureDetector(
              onTap: () {
                setState(() {
                  _isCuisineExpanded = !_isCuisineExpanded;
                });
              },
              child: Column(
                children: [
                  SizedBox(height: 10), // Add SizedBox before the options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cuisine Type',
                        style: GoogleFonts.lato(fontSize: 16),
                      ),
                      Icon(_isCuisineExpanded
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down)
                    ],
                  ),
                  if (_isCuisineExpanded)
                    SizedBox(height: 10), // Add some space after the drop-down
                  if (_isCuisineExpanded)
                    Wrap(
                      spacing: 8.0,
                      children: cuisineOptions.map((cuisine) {
                        final bool isSelected =
                            _selectedFilter.contains(cuisine);
                        return ChoiceChip(
                          label: Text(cuisine,
                              style: GoogleFonts.poppins(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary)),
                          side: BorderSide(width: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (isSelected) {
                                _selectedFilter.remove(cuisine);
                              } else {
                                _selectedFilter.add(cuisine);
                              }
                            });
                          },
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            Divider(),
            // Tags Toggle Section
            GestureDetector(
              onTap: () {
                setState(() {
                  _isTagsExpanded = !_isTagsExpanded;
                });
              },
              child: Column(
                children: [
                  SizedBox(height: 10), // Add SizedBox before the options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tags',
                        style: GoogleFonts.lato(fontSize: 16),
                      ),
                      Icon(_isTagsExpanded
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down)
                    ],
                  ),
                  if (_isTagsExpanded)
                    SizedBox(height: 10), // Add some space after the drop-down
                  if (_isTagsExpanded)
                    Wrap(
                      spacing: 8.0,
                      children: tagOptions.map((tag) {
                        final bool isSelected = _selectedTags.contains(tag);
                        return ChoiceChip(
                          label: Text(tag,
                              style: GoogleFonts.poppins(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary)),
                          side: BorderSide(width: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (isSelected) {
                                _selectedTags.remove(tag);
                              } else {
                                _selectedTags.add(tag);
                              }
                            });
                          },
                          selectedColor: AppColors.primary,
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            Divider(),
            // Sort by Rating Section
            Text(
              'Sort by Rating',
              style:
                  GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'High to Low',
                  groupValue: _sortByRatingDesc,
                  onChanged: (String? value) {
                    setState(() {
                      _sortByRatingDesc = value!;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                Text('High to Low'),
                Radio<String>(
                  value: 'Low to High',
                  groupValue: _sortByRatingDesc,
                  onChanged: (String? value) {
                    setState(() {
                      _sortByRatingDesc = value!;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                Text('Low to High'),
              ],
            ),
            SizedBox(height: 20),
            // Button to clear all filters
            CustomPrimaryButton(
              text: 'Clear All Filters',
              onPressed: () {
                widget.onApplyFilters(
                  [],
                  [],
                  'High to Low', // Default value
                );
                Navigator.of(context).pop();
              },
            ),
            SizedBox(height: 40),
            // Button to apply selected filters
            CustomPrimaryButton(
              text: 'Apply Filters',
              onPressed: () {
                widget.onApplyFilters(
                  _selectedFilter,
                  _selectedTags,
                  _sortByRatingDesc,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
