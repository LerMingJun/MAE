import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/screens/admins/unapproved_restauranr_detail.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_empty.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:provider/provider.dart';

class UnapprovedRestaurantList extends StatefulWidget {
  const UnapprovedRestaurantList({super.key});

  @override
  State<UnapprovedRestaurantList> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<UnapprovedRestaurantList> with SingleTickerProviderStateMixin {
  bool nearMe = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      restaurantProvider.fetchAllRestaurants();
    });
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String searchText = '';

  void _searchRestaurants(String text) {
    setState(() {
      searchText = text;
    });
    Provider.of<RestaurantProvider>(context, listen: false).searchRestaurants(text);
  }

// @override
Widget build(BuildContext context) {
  final restaurantProvider = Provider.of<RestaurantProvider>(context);

  // Filter to get only pending restaurants
  final pendingRestaurants = restaurantProvider.restaurants
      .where((restaurant) => restaurant.status == 'pending')
      .toList();

  return Scaffold(
    backgroundColor: AppColors.background,
    body: Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: RefreshIndicator(
        onRefresh: () async {
          await restaurantProvider.fetchAllRestaurants();
        },
        edgeOffset: 100,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Text(
                          'Pending Restaurants',
                          style: GoogleFonts.lato(
                            fontSize: 24,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 40),
                      child: TextField(
                        onChanged: (text) {
                          _searchRestaurants(text);
                        },
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          hintText: 'Search Pending Restaurants',
                          hintStyle: GoogleFonts.poppins(fontSize: 12),
                          suffixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          isDense: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 8.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pinned: true,
            ),
            SliverFillRemaining(
              child: _buildRestaurantList(pendingRestaurants, restaurantProvider.isLoading),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildRestaurantList(List<Restaurant> restaurants, bool isLoading) {
    if (isLoading) {
      return const Center(child: CustomLoading(text: 'Fetching Restaurants...'));
    } else if (restaurants.isEmpty) {
      return const Center(
        child: EmptyWidget(
          text: "No Restaurants Found.\nPlease try again.",
          image: 'assets/projectEmpty.png',
        ),
      );
    } else {
      return ListView.builder(
        itemCount: restaurants.length,
        itemBuilder: (BuildContext context, int index) {
          Restaurant restaurant = restaurants[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UnapprovedRestauranrDetail(
                      restaurant: restaurant,
                    ),
                  ),
                );
              },
              child: CustomRestaurantCard(
                imageUrl: restaurant.image,
                name: restaurant.name,
                location: restaurant.location,
                cuisineTypes: restaurant.cuisineType,
                rating: restaurant.averageRating,
                restaurantID: restaurant.id,
                intro: restaurant.intro,
                restaurant: restaurant,
              ),
            ),
          );
        },
      );
    }
  }
}

class CustomRestaurantCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final GeoPoint location;
  final List<String> cuisineTypes;
  final String restaurantID;
  final String intro;
  final double rating; // Rating field
  final Restaurant restaurant;

  const CustomRestaurantCard({
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.cuisineTypes,
    required this.restaurantID,
    required this.intro,
    required this.rating, // Include rating in constructor
    required this.restaurant, // Include restaurant in constructor
    super.key,
  });

  @override
  _CustomRestaurantCardState createState() => _CustomRestaurantCardState();
}

class _CustomRestaurantCardState extends State<CustomRestaurantCard> {
  String? address;

  @override
  void initState() {
    super.initState();
    _getAddressFromCoordinates();
  }

  Future<void> _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.location.latitude,
        widget.location.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          address = "${placemark.street}, ${placemark.locality}, ${placemark.country}";
        });
      }
    } catch (e) {
      setState(() {
        address = "Address not available";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UnapprovedRestauranrDetail(
              restaurant: widget.restaurant,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        child: Row(
          children: [
            // Restaurant image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Image.network(
                widget.imageUrl,
                height: 120,
                width: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return const CustomImageLoading(
                      width: 100,
                      height: 100,
                    );
                  }
                },
              ),
            ),
            // Restaurant details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address ?? 'Fetching address...', // Display the address
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.cuisineTypes.join(', '),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.intro,
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        color: Colors.black45,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}