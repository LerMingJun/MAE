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
import 'package:jom_makan/screens/user/restaurantDetails.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  LatLng? _currentLocation;
  bool _isLoadingLocation = false;
  String? _address;
  final bool _showManualLocationEntry = false;
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserLocation();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserData();
      final String? userId = userProvider.userData?.userID;
      if (userId != null) {
        Provider.of<FavoriteProvider>(context, listen: false)
            .fetchFavorites(userId);
      }
      Provider.of<RestaurantProvider>(context, listen: false)
          .fetchAllRestaurants();
    });
  }

  @override
  void dispose() {
    print("Disposing page controller...");
    _pageController.dispose();
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

        // Collect data first
        LatLng newLocation = LatLng(position.latitude, position.longitude);
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        Placemark place = placemarks[0];
        String address = '${place.street}, ${place.locality}, ${place.country}';

        // Only call setState if mounted
        if (mounted) {
          setState(() {
            _currentLocation = newLocation;
            _address = address;
            _isLoadingLocation = false;
          });

          // Fetch restaurants based on the updated location
          Provider.of<RestaurantProvider>(context, listen: false)
              .fetchAllRestaurants();
        }
      } else {
        throw Exception('Location permission denied');
      }
    } catch (e) {
      print("Error fetching location: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    if (userProvider.userData == null) {
      return const Center(
          child: CircularProgressIndicator()); // or any loading widget
    }

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
                            padding: const EdgeInsets.all(2.0),
                            decoration: const BoxDecoration(
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
                          const SizedBox(width: 8),
                          Text(
                            'Hello, ${userProvider.userData?.username ?? 'Unknown User'}!',
                            style: GoogleFonts.lato(fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
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
                  const SizedBox(height: 16),
                  Text(
                    'Suggested Restaurants Nearby',
                    style: GoogleFonts.lato(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  restaurantProvider.isLoading
                      ? const Center(child: CustomLoading(text: 'Loading...'))
                      : Column(
                          children: restaurantProvider.restaurants
                              .where((restaurant) =>
                                  _isNearby(restaurant.location) &&
                                  _matchesUserPreferences(
                                      restaurant, userProvider))
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
            const SizedBox(height: 20),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text(
                    'Suggest Random Restaurant',
                    style: TextStyle(fontSize: 14),
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
        child: SingleChildScrollView(
          // Wrap the Column in a SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Location:',
                style: GoogleFonts.lato(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _isLoadingLocation
                  ? const SpinKitThreeBounce(
                      color: AppColors.primary, size: 20.0)
                  : Text(
                      _address ?? 'Location not available',
                      style:
                          GoogleFonts.lato(fontSize: 15, color: Colors.white),
                    ),
              const SizedBox(height: 10),
              // First button centered in its own Row
              Center(
                child: SizedBox(
                  width: double.infinity, // Fill the width
                  child: ElevatedButton(
                    onPressed: () => _showAddressDialog(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      'Enter Address Manually',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10), // Spacing between buttons
              // Second button centered in its own Row
              Center(
                child: SizedBox(
                  width: double.infinity, // Fill the width
                  child: ElevatedButton(
                    onPressed: _fetchUserLocation,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      'Refresh Location',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Address'),
          content: TextField(
            controller:
                latitudeController, // Use the latitudeController for the address input
            decoration: const InputDecoration(labelText: 'Address'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _setManualLocation(); // Set location and close the dialog
                Navigator.of(context).pop();
              },
              child: const Text('Set Location'),
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          const SnackBar(
              content: Text('Could not find the address. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid address.')),
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
            const SizedBox(height: 10),
            Image.network(restaurant.image),
            const SizedBox(height: 10),
            Text('Rating: ${restaurant.averageRating}'),
          ],
        ),
        actions: [
          // New button to navigate to the restaurant details page
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RestaurantDetailsScreen(restaurant: restaurant),
                ),
              );
            },
            child: const Text('View Details'),
          ),
          // Close button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  bool _isNearby(GeoPoint location) {
    if (_currentLocation == null) return false;
    final distance = const Distance().as(
      LengthUnit.Kilometer,
      _currentLocation!,
      LatLng(location.latitude, location.longitude),
    );
    return distance <= 50.0;
  }

  bool _matchesUserPreferences(Restaurant restaurant, dynamic userProvider) {
    return userProvider.userData?.dietaryPreferences
            .any((preference) => restaurant.cuisineType.contains(preference)) ??
        false;
  }
}
