import 'package:flutter/material.dart';
import 'package:folks_app/models/help_item.dart';
import 'package:folks_app/repositories/helpitem_repository.dart';

class HelpItemProvider with ChangeNotifier {
  final HelpItemRepository _helpItemRepository = HelpItemRepository();

  List<HelpItem> _helpItems = [];
  HelpItem? _helpItem;
  bool _isLoading = false;

  List<HelpItem> get helpItems => _helpItems;
  HelpItem? get helpItem => _helpItem;
  bool get isLoading => _isLoading;

  Future<void> fetchAllHelpItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _helpItems = await _helpItemRepository.fetchAllHelpItems();
    } catch (e) {
      _helpItems = [];
      print('Error in HelpItemProvider: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchHelpItemById(String helpItemId) async {
    try {
      _helpItem = await _helpItemRepository.getHelpItemById(helpItemId);
    } catch (e) {
      print('Error in HelpItemProvider: $e');
      throw Exception('Error fetching help item');
    }
  }

  void searchHelpItems(String searchText) {
    if (searchText.isEmpty) {
      _helpItems = _helpItems;
    } else {
      _helpItems = _helpItems.where((helpItem) {
        return helpItem.title.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}