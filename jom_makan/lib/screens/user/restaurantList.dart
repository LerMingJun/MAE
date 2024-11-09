import 'package:flutter/material.dart';
import 'package:jom_makan/providers/favorite_provider.dart';
import 'package:jom_makan/screens/user/restaurantDetails.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_cards.dart';
import 'package:jom_makan/widgets/custom_empty.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/screens/user/filterOption.dart'; // Import FilterOptions widget
import 'package:provider/provider.dart';

class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({super.key});

  @override
  State<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  bool nearMe = false;
  bool isSearching = false;
  List<String> selectedFilter = [];
  List<String> selectedTags = [];
  String sortByRatingDesc = '';
  String searchText = '';

  @override
  void initState() {
    super.initState();
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      restaurantProvider.fetchAllRestaurants();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String? userId = userProvider.firebaseUser?.uid;
      if (userId != null) {
        Provider.of<FavoriteProvider>(context, listen: false)
            .fetchFavorites(userId);
      }
    });
  }

  void _searchRestaurants(String text) {
    setState(() {
      searchText = text;
    });
    Provider.of<RestaurantProvider>(context, listen: false)
        .searchRestaurants(text);
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FilterOptions(
          onApplyFilters: (List<String> selectedFilter,
              List<String> selectedTags, String sortByRatingDesc) {
            setState(() {
              this.selectedFilter = selectedFilter;
              this.selectedTags = selectedTags;
              this.sortByRatingDesc = sortByRatingDesc;
            });

            // Apply filters to restaurantProvider and refresh the list
            Provider.of<RestaurantProvider>(context, listen: false)
                .applyFilters(selectedFilter, selectedTags, sortByRatingDesc);
          },
          selectedFilter: selectedFilter,
          selectedTags: selectedTags,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

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
                automaticallyImplyLeading: false,
                backgroundColor: AppColors.background,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Discover Restaurants',
                            style: GoogleFonts.lato(
                              fontSize: 24,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: _showFilterOptions,
                            icon: const Icon(Icons.filter_list),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ConstrainedBox(
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
                      ),
                    ],
                  ),
                ),
                expandedHeight: 80,
              ),
              if (isSearching)
                const SliverFillRemaining(
                  child: CustomLoading(text: 'Searching...'),
                )
              else if (restaurantProvider.isLoading)
                const SliverFillRemaining(
                  child: CustomLoading(text: 'Fetching Restaurants...'),
                )
              else if (restaurantProvider.restaurants.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: EmptyWidget(
                      text: searchText.isNotEmpty
                          ? "No restaurants found for '$searchText'."
                          : "No restaurants found. Please try again.",
                      image: 'assets/projectEmpty.png',
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      Restaurant restaurant =
                          restaurantProvider.restaurants[index];

                      bool isFavorited =
                          favoriteProvider.isFavorited(restaurant.id);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetailsScreen(
                                    restaurant: restaurant),
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
                            isFavourited: isFavorited,
                          ),
                        ),
                      );
                    },
                    childCount: restaurantProvider.restaurants.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
