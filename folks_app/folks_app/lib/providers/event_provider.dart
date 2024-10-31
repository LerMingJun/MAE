import 'package:flutter/material.dart';
import 'package:folks_app/models/activity.dart';
import 'package:folks_app/models/participation.dart';
import 'package:folks_app/models/project.dart';
import 'package:folks_app/models/projectSpeeches.dart';
import 'package:folks_app/models/speech.dart';
import 'package:folks_app/models/tag.dart';
import 'package:folks_app/repositories/auth_repository.dart';
import 'package:folks_app/repositories/event_repository.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class EventProvider with ChangeNotifier {
  final EventRepository _eventRepository = EventRepository();
  final AuthRepository _authRepository = AuthRepository();

  List<Event> _events = [];
  Event? _event;
  List<Activity>? _activities = [];
  List<Activity>? _allActivities = [];
  List<Tag> _tags = [];
  bool _isLoading = false;
  LatLng? _center;
  Marker? _marker;
  List<ProjectSpeeches> _relatedSpeeches = [];

  List<Event> get events => _events;
  List<Tag> get tags => _tags;
  Event? get event => _event;
  List<Activity>? get activities => _activities;
  bool get isLoading => _isLoading;
  LatLng? get center => _center;
  Marker? get marker => _marker;
  List<ProjectSpeeches> get relatedSpeeches => _relatedSpeeches;

  Future<void> fetchAllTags() async {
    notifyListeners();
    try {
      _tags = await _eventRepository.fetchAllTags();
    } catch (e) {
      _tags = [];
      print('Error in EventProvider: $e');
    }
    notifyListeners();
  }

  Future<void> fetchAllActivities() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allActivities = await _eventRepository.fetchAllActivities();
      _activities = _allActivities;
    } catch (e) {
      _activities = [];
      print('Error in EventProvider: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFilteredActivities(String filter, List<String> tagName,
      DateTime? startDate, DateTime? endDate) async {
    _isLoading = true;
    notifyListeners();

    try {
      _activities = await _eventRepository.fetchFilteredActivities(
          filter, tagName, startDate, endDate);
    } catch (e) {
      _activities = [];
      print('Error in EventProvider: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Event> fetchEventByID(String eventID) async {
    try {
      Map<String, dynamic> result =
          await _eventRepository.getEventById(eventID);
      _event = result['event'];
      _relatedSpeeches = result['speeches'];

      if (_event!.location.isEmpty) {
        throw Exception('Location is empty');
      }

      print('Fetching location for: ${_event!.location}');

      List<Location> locations;
      try {
        locations = await locationFromAddress(_event!.location);
      } catch (e) {
        print('Error finding location: $e');
        throw Exception('Could not find location for provided address');
      }

      if (locations.isNotEmpty) {
        _center = LatLng(locations.first.latitude, locations.first.longitude);
        _marker = Marker(
          markerId: MarkerId(_event!.location),
          position: _center!,
          infoWindow: InfoWindow(
            title: _event!.location,
          ),
        );
      } else {
        throw Exception('No locations found for the provided address.');
      }

      return _event!;
    } catch (e) {
      print('Error in EventProvider: $e');
      throw Exception('Error fetching event');
    }
  }

  void searchActivities(String searchText) {
    if (searchText.isEmpty || searchText == "") {
      _activities = _allActivities;
    } else {
      _activities = _allActivities!.where((activity) {
        return activity.title
                .toLowerCase()
                .contains(searchText.toLowerCase()) ||
            activity.location.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  // Future<void> fetchSpeechesByEventID(String eventID) async {
  //   _relatedSpeeches = await _eventRepository.fetchSpeechesByProjectID(eventID);
  //   notifyListeners();
  // }

  Future<bool> isActivityJoined(String activityID) async {
    return await _eventRepository.isActivityJoined(
        _authRepository.currentUser!.uid, activityID);
  }
}
