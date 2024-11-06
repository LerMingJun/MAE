import 'dart:math';
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
  bool _showManualLocationEntry = false;
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(context, listen: false)
          .fetchAllRestaurants();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String? userId = userProvider.firebaseUser?.uid;
      Provider.of<FavoriteProvider>(context, listen: false)
          .fetchFavorites(userId!);
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose the controller when no longer needed
    super.dispose();
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

        // Fetch restaurants based on the updated location
        Provider.of<RestaurantProvider>(context, listen: false)
            .fetchAllRestaurants(); // Add this line
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
      body: Stack(
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
                  SizedBox(
                    height: 220,
                    child: Stack(
                      alignment: Alignment
                          .bottomCenter, // Align dots to the bottom center
                      children: [
                        PageView(
                          controller: _pageController,
                          onPageChanged: (int page) {
                            setState(() {
                              _currentPage =
                                  page; // Update the current page index
                            });
                          },
                          children: [
                            _buildLocationPage(),
                            _buildRandomRestaurantPage(restaurantProvider),
                          ],
                        ),
                        // Dot indicator positioned inside the PageView
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(2, (index) {
                            return Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              width: 8.0,
                              height: 8.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index
                                    ? AppColors.primary
                                    : Colors
                                        .grey, // Change color based on current page
                              ),
                            );
                          }),
                        ),
                      ],
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
                            bool isFavourited =
                                favoriteProvider.isFavorited(restaurant.id);
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

  Widget _buildRandomRestaurantPage(RestaurantProvider restaurantProvider) {
    final List<Restaurant> nearbyRestaurants = restaurantProvider.restaurants
        .where((restaurant) => _isNearby(restaurant.location))
        .toList();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: AppColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Random Restaurant Suggestion',
              style: GoogleFonts.lato(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity, // Fill the width
                child: ElevatedButton(
                  onPressed: nearbyRestaurants.isEmpty
                      ? null
                      : () {
                          final randomRestaurant = nearbyRestaurants[
                              Random().nextInt(nearbyRestaurants.length)];
                          _showRestaurantDetails(randomRestaurant);
                        },
                  child: Text('Suggest Random Restaurant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPage() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: AppColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Location:',
              style: GoogleFonts.lato(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 8),
            _isLoadingLocation
                ? SpinKitThreeBounce(color: AppColors.primary, size: 20.0)
                : Text(
                    _address ?? 'Location not available',
                    style: GoogleFonts.lato(fontSize: 15, color: Colors.white),
                  ),
            SizedBox(height: 10),
            // First button centered in its own Row
            Center(
              child: SizedBox(
                width: double.infinity, // Fill the width
                child: ElevatedButton(
                  onPressed: () => _showAddressDialog(),
                  child: Text(
                    'Enter Address Manually',
                    style: TextStyle(fontSize: 16), // Adjust the font size here
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: 10), // Adjust vertical padding
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10), // Spacing between buttons
            // Second button centered in its own Row
            Center(
              child: SizedBox(
                width: double.infinity, // Fill the width
                child: ElevatedButton(
                  onPressed: _fetchUserLocation,
                  child: Text(
                    'Refresh Location',
                    style: TextStyle(fontSize: 16), // Adjust the font size here
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: 10), // Adjust vertical padding
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Address'),
          content: TextField(
            controller:
                latitudeController, // Use the latitudeController for the address input
            decoration: InputDecoration(labelText: 'Address'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _setManualLocation(); // Set location and close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Set Location'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationTextField(
      TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
    );
  }

  void _setManualLocation() async {
    final address = latitudeController
        .text; // Use the address input from the latitudeController
    if (address.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          final LatLng manualLocation =
              LatLng(locations[0].latitude, locations[0].longitude);
          setState(() {
            _currentLocation = manualLocation;
            _address = address;
          });
          // Call the fetchAllRestaurants() again to ensure the suggestions are refreshed
          Provider.of<RestaurantProvider>(context, listen: false)
              .fetchAllRestaurants();
        } else {
          throw Exception('Address not found');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not find the address. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid address.')),
      );
    }
  }

  void _showRestaurantDetails(Restaurant restaurant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(restaurant.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(restaurant.image),
            SizedBox(height: 10),
            Text(restaurant.intro),
            Text('Rating: ${restaurant.averageRating}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
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

  bool _matchesUserPreferences(Restaurant restaurant, dynamic userProvider) {
    return userProvider.userData?.dietaryPreferences
            .any((preference) => restaurant.cuisineType.contains(preference)) ??
        false;
  }
}
