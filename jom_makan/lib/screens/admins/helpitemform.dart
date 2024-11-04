import 'package:flutter/material.dart';
import 'package:jom_makan/models/help_item.dart';
import 'package:jom_makan/providers/helpitem_provider.dart';
import 'package:jom_makan/screens/admins/helpcenter.dart';
import 'package:provider/provider.dart';

class HelpItemFormScreen extends StatefulWidget {
  final String? existingTitle;
  final String? existingSubtitle;
  final String? id;

  const HelpItemFormScreen({super.key,this.id, this.existingTitle, this.existingSubtitle});

  @override
  _HelpItemFormScreenState createState() => _HelpItemFormScreenState();
}

class _HelpItemFormScreenState extends State<HelpItemFormScreen> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _titleWordCount = 0;
  int _subtitleWordCount = 0;
  int _titleCharCount = 0;
  int _subtitleCharCount = 0;

  static const int _maxTitleWords = 13;
  static const int _maxSubtitleWords = 125;
  static const int _maxTitleChars = 75;
  static const int _maxSubtitleChars = 1200;

  @override
  void initState() {
    super.initState();
    if (widget.existingTitle != null) {
      _titleController.text = widget.existingTitle!;
      _updateTitleCounts(widget.existingTitle!);
    }
    if (widget.existingSubtitle != null) {
      _subtitleController.text = widget.existingSubtitle!;
      _updateSubtitleCounts(widget.existingSubtitle!);
    }
    _titleController.addListener(_onTitleChanged);
    _subtitleController.addListener(_onSubtitleChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    setState(() {
      _updateTitleCounts(_titleController.text);
    });
  }

  void _onSubtitleChanged() {
    setState(() {
      _updateSubtitleCounts(_subtitleController.text);
    });
  }

  void _updateTitleCounts(String text) {
    _titleCharCount = text.length;
    _titleWordCount = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  void _updateSubtitleCounts(String text) {
    _subtitleCharCount = text.length;
    _subtitleWordCount = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  bool get _isTitleValid => _titleWordCount <= _maxTitleWords && _titleCharCount <= _maxTitleChars;
  bool get _isSubtitleValid => _subtitleWordCount <= _maxSubtitleWords && _subtitleCharCount <= _maxSubtitleChars;

Future<void> _saveFaq() async {
  // Validate the form
  if (_formKey.currentState!.validate()) {
    final newTitle = _titleController.text;
    final newSubtitle = _subtitleController.text;
    final helpItemProvider = Provider.of<HelpItemProvider>(context, listen: false);

    HelpItem helpItem = HelpItem(
      helpItemId: widget.id ?? '',
      title: newTitle,
      subtitle: newSubtitle,
    );

    // Check if the item already exists
    if (widget.id != null) {
      await helpItemProvider.updateHelpItems(
        widget.id!,
        newTitle,
        newSubtitle,
      );
    } else {
      await helpItemProvider.addHelpItems(helpItem);
    }

    // Navigate back to HelpCenterScreen and remove all previous screens
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HelpCenterScreen()), // Change this to your actual HelpCenterScreen widget
      (route) => false, // Removes all previous routes
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTitle == null ? 'Add FAQ' : 'Modify FAQ'),
        backgroundColor: Colors.green,

      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        } else if (!_isTitleValid) {
                          return 'Title exceeds $_maxTitleWords words or $_maxTitleChars characters limit';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '$_titleWordCount / $_maxTitleWords words, $_titleCharCount / $_maxTitleChars chars',
                        style: TextStyle(
                          color: _isTitleValid ? Colors.grey : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Subtitle',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Subtitle is required';
                        } else if (!_isSubtitleValid) {
                          return 'Subtitle exceeds $_maxSubtitleWords words or $_maxSubtitleChars characters limit';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '$_subtitleWordCount / $_maxSubtitleWords words, $_subtitleCharCount / $_maxSubtitleChars chars',
                        style: TextStyle(
                          color: _isSubtitleValid ? Colors.grey : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isTitleValid && _isSubtitleValid ? _saveFaq : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          widget.existingTitle == null ? 'Add FAQ' : 'Save Changes',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
