import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/screens/admins/mainpage.dart';
import 'package:jom_makan/screens/admins/restaurant_details.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/admins/custom_restaurant_card.dart';
import 'package:jom_makan/widgets/custom_empty.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:provider/provider.dart';

class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({super.key});

  @override
  State<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage>
    with SingleTickerProviderStateMixin {
  bool nearMe = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
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
    Provider.of<RestaurantProvider>(context, listen: false)
        .searchRestaurants(text);
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    final activeRestaurants = restaurantProvider.restaurants
        .where((restaurant) => restaurant.status == 'active')
        .toList();

    final inactiveRestaurants = restaurantProvider.restaurants
        .where((restaurant) => restaurant.status != 'active')
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
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MainPage()));
                            },
                          ),
                          Text(
                            'Manage Restaurants',
                            style: GoogleFonts.lato(
                              fontSize: 24,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Optional: Add filter functionality
                            },
                            icon: const Icon(Icons.filter_list),
                            color: AppColors.primary,
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
                            hintText: 'Search Restaurants',
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
                              borderSide:
                                  const BorderSide(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                expandedHeight: 130,
                pinned: true,
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'Inactive'),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRestaurantList(
                        activeRestaurants, restaurantProvider.isLoading),
                    _buildRestaurantList(
                        inactiveRestaurants, restaurantProvider.isLoading),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantList(List<Restaurant> restaurants, bool isLoading) {
    if (isLoading) {
      return const Center(
          child: CustomLoading(text: 'Fetching Restaurants...'));
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
                    builder: (context) => RestaurantDetailsScreenAdmin(
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
