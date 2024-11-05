import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/providers/favorite_provider.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/constants/placeholderURL.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_cards.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  LatLng? _currentLocation;
  bool _isLoadingLocation = false;
  String? _address;

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(context, listen: false)
          .fetchAllRestaurants();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String? userId = userProvider.firebaseUser?.uid;
      Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites(userId!);
    });
  }

  Future<void> _fetchUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });

        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        Placemark place = placemarks[0];
        String address = '${place.street}, ${place.locality}, ${place.country}';
        _address = address;
      } else {
        throw Exception('Location permission denied');
      }
    } catch (e) {
      print("Error fetching location: $e");
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: restaurantProvider.isLoading
          ? Center(child: CustomLoading(text: 'Loading...'))
          : Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3,
                  color: AppColors.tertiary,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.0),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                        userProvider.userData?.profileImage ??
                                            userPlaceholder),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Hello, ${userProvider.userData?.username ?? 'Unknown User'}!',
                                  style: GoogleFonts.lato(fontSize: 15),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/schedule');
                              },
                              icon: Icon(Icons.calendar_today_rounded),
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        // Text(
                        //   'My Location',
                        //   style: GoogleFonts.lato(fontSize: 20),
                        // ),
                        // Purple Container with Location Details
                        Card(
                          elevation: 7,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: AppColors.secondary, // Purple background
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Location:',
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                _isLoadingLocation
                                    ? SpinKitThreeBounce(
                                        color: AppColors.primary,
                                        size: 20.0,
                                      )
                                    : Text(
                                        _address ?? 'Location not available',
                                        style: GoogleFonts.lato(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                SizedBox(height: 6),
                                Text(
                                  _currentLocation != null
                                      ? 'Lat: ${_currentLocation!.latitude}, Long: ${_currentLocation!.longitude}'
                                      : 'Coordinates not available',
                                  style: GoogleFonts.lato(
                                      fontSize: 14, color: Colors.white70),
                                ),
                                SizedBox(height: 10),
                                // Make the button longer to fill the bottom side
                                SizedBox(
                                  width: double.infinity, // Fill the width
                                  child: ElevatedButton(
                                    onPressed: _fetchUserLocation,
                                    child: Text(
                                      'Refresh Location',
                                      style: TextStyle(
                                          fontSize:
                                              16), // Adjust the font size here
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          vertical:
                                              15), // Adjust vertical padding
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        Text(
                          'Suggested Restaurants Nearby',
                          style: GoogleFonts.lato(fontSize: 20),
                        ),
                        SizedBox(height: 16),
                        restaurantProvider.isLoading
                            ? Center(child: CustomLoading(text: 'Loading...'))
                            : Column(
                                children: restaurantProvider.restaurants
                                    .where((restaurant) =>
                                        _isNearby(restaurant.location) &&
                                        _matchesUserPreferences(
                                            restaurant, userProvider))
                                    .take(5)
                                    .map((restaurant) {
                                  bool isFavourited = favoriteProvider
                                      .isFavorited(restaurant.id);
                                  return CustomRestaurantCard(
                                    imageUrl: restaurant.image,
                                    name: restaurant.name,
                                    location: restaurant.location,
                                    cuisineTypes: restaurant.cuisineType,
                                    rating: restaurant.averageRating,
                                    restaurantID: restaurant.id,
                                    intro: restaurant.intro,
                                    restaurant: restaurant,
                                    isFavourited: isFavourited,
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  bool _isNearby(GeoPoint location) {
    if (_currentLocation == null) return false;
    final distance = Distance().as(
      LengthUnit.Kilometer,
      _currentLocation!,
      LatLng(location.latitude, location.longitude),
    );
    return distance <= 10.0;
  }
}

bool _matchesUserPreferences(Restaurant restaurant, dynamic userProvider) {
  // Assuming restaurant.cuisineType is a List<String> or a single String
  return userProvider.userData?.dietaryPreferences
          .any((preference) => restaurant.cuisineType.contains(preference)) ??
      false;
}
