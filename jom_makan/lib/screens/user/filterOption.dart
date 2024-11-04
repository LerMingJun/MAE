import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/models/tag.dart';
import 'package:jom_makan/providers/event_provider.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_buttons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class FilterOptions extends StatefulWidget {
  final Function(String, List<String>, List<String>, DateTime?, DateTime?)
      onApplyFilters;
  final String selectedFilter;
  final List<String> selectedTags;
  final List<String> selectedTagIDs;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;

  FilterOptions({
    required this.onApplyFilters,
    required this.selectedFilter,
    required this.selectedTags,
    required this.selectedTagIDs,
    this.selectedStartDate,
    this.selectedEndDate,
  });

  @override
  _FilterOptionsState createState() => _FilterOptionsState();
}

class _FilterOptionsState extends State<FilterOptions> {
  String _selectedFilter = 'All';
  List<String> _selectedTags = [];
  List<String> _selectedTagIDs = [];
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
    _selectedTags = List.from(widget.selectedTags);
    _selectedTagIDs = List.from(widget.selectedTagIDs);
    _selectedStartDate = widget.selectedStartDate;
    _selectedEndDate = widget.selectedEndDate;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).fetchAllTags();
    });
  }

  void _clearDate() {
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final List<Tag> tags = eventProvider.tags;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter by Type',
                style: GoogleFonts.lato(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Column(
              children: ['All', 'Project', 'Speech'].map((String filter) {
                return RadioListTile(
                  title: Text(filter),
                  value: filter,
                  activeColor: AppColors.primary,
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value.toString();
                    });
                  },
                );
              }).toList(),
            ),
            Divider(),
            Text('Filter by Tags',
                style: GoogleFonts.lato(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              children: tags.map((tag) {
                final bool isSelected = _selectedTags.contains(tag.name);
                return ChoiceChip(
                  label: Text(tag.name,
                      style: GoogleFonts.poppins(
                          color:
                              isSelected ? Colors.white : AppColors.primary)),
                  side: BorderSide(width: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (isSelected) {
                        _selectedTags.remove(tag.name);
                        _selectedTagIDs.remove(tag.tagID);
                      } else {
                        _selectedTagIDs.add(tag.tagID);
                        _selectedTags.add(tag.name);
                      }
                    });
                  },
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                );
              }).toList(),
            ),
            Divider(),
            Text('Filter by Date Range',
                style: GoogleFonts.lato(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Start Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedStartDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedStartDate = pickedDate;
                        });
                      }
                    },
                    controller: TextEditingController(
                      text: _selectedStartDate != null
                          ? DateFormat('yyyy-MM-dd').format(_selectedStartDate!)
                          : '',
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'End Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedEndDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedEndDate = pickedDate;
                        });
                      }
                    },
                    controller: TextEditingController(
                      text: _selectedEndDate != null
                          ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!)
                          : '',
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _clearDate,
              child: Text(
                'Clear Dates',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            SizedBox(height: 40),
            CustomPrimaryButton(
              text: 'Apply Filters',
              onPressed: () {
                widget.onApplyFilters(_selectedFilter, _selectedTags,
                    _selectedTagIDs, _selectedStartDate, _selectedEndDate);

                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
