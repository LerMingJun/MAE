import 'package:flutter/material.dart';
import 'package:jom_makan/models/help_item.dart';
import 'package:jom_makan/repositories/helpitem_repository.dart';
 
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
 
Future<void> updateHelpItems(String helpItemsID, String title, String subtitle) async {
  _isLoading = true;
  notifyListeners();
 
  try {
    await _helpItemRepository.editHelpItems(helpItemsID, title, subtitle);
 
    // Fetch updated helpItems details to ensure local data is up-to-date
    await fetchAllHelpItems();
 
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    notifyListeners();
    print('Error in helpItemsProvider: $e');
    throw Exception('Error updating helpItems');
  }
}
 
  // Add a new helpItems
  Future<void> addHelpItems(HelpItem helpItem) async {
    await _helpItemRepository.addReview(helpItem);
    await fetchAllHelpItems(); // Refresh the reviews after adding
  }
 
  Future<void> deleteHelpItem(String helpItemID) async {
   
    try {
      await _helpItemRepository.deleteHelpItem(helpItemID);
      await fetchAllHelpItems();
    } catch (e) {
      print('Error in PostProvider: $e');
    }
 
  }
 
}
 