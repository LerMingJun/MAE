import 'package:flutter/material.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/models/user.dart';
import 'package:jom_makan/providers/review_provider.dart';
import 'package:jom_makan/providers/favorite_provider.dart';
import 'package:jom_makan/screens/user/addBooking.dart';
import 'package:jom_makan/screens/user/addReview.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/screens/user/allReviews.dart';
import 'package:jom_makan/screens/user/fullImgae.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailsScreen({super.key, required this.restaurant});

  @override
  _RestaurantDetailsScreenState createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  bool _reviewsFetched = false;
  bool _favoritesFetched = false;

  @override
  void initState() {
    super.initState();

    // Fetch user data
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.userData == null) {
      userProvider.fetchUserData();
    }
    // userProvider.fetchUserData();
    final String? userId = userProvider.userData?.userID;

    // Fetch favorites if userId is available
    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_favoritesFetched) {
          Provider.of<FavoriteProvider>(context, listen: false)
              .fetchFavorites(userId)
              .then((_) {
            if (mounted) {
              setState(() {
                _favoritesFetched = true;
              });
            }
          });
        }
      });
    }

    // Fetch reviews only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_reviewsFetched) {
        Provider.of<ReviewProvider>(context, listen: false)
            .fetchReviews(widget.restaurant.id)
            .then((_) {
          if (mounted) {
            setState(() {
              _reviewsFetched = true;
            });
          }
        });
      }
    });
  }

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];
    return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    bool isFavorited = _favoritesFetched
        ? favoriteProvider.isFavorited(widget.restaurant.id)
        : false;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
        actions: [
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red : null,
            ),
            onPressed: () {
              final userId = Provider.of<UserProvider>(context, listen: false)
                  .firebaseUser
                  ?.uid;
              if (userId != null) {
                if (isFavorited) {
                  favoriteProvider.removeFavorite(userId, widget.restaurant.id);
                } else {
                  favoriteProvider.addFavorite(userId, widget.restaurant.id);
                }
                setState(() {
                  isFavorited = !isFavorited;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRestaurantImage(),
              const SizedBox(height: 16),
              _buildRestaurantIntro(),
              const SizedBox(height: 16),
              _buildCuisineType(),
              const SizedBox(height: 16),
              _buildLocation(),
              const SizedBox(height: 16),
              _buildOperatingHours(),
              const SizedBox(height: 16),
              _buildTags(),
              const Divider(),
              const Text("Menu Images",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              widget.restaurant.menu.isNotEmpty
                  ? SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.restaurant.menu.length,
                        itemBuilder: (context, index) {
                          final imageUrl = widget.restaurant.menu[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImageViewer(
                                    imageUrls: widget
                                        .restaurant.menu, // All menu images
                                    initialIndex:
                                        index, // Start at the tapped image
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 150,
                              margin: const EdgeInsets.only(right: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                          child: Text("Image Not Available")),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const Text("No menu images available",
                      style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Divider(),
              _buildReviewsSection(reviewProvider),
              const Divider(),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantImage() {
    return widget.restaurant.image.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              widget.restaurant.image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        : Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Text('No Image Available')),
          );
  }

  Widget _buildRestaurantIntro() {
    return Text(
      widget.restaurant.intro,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildCuisineType() {
    return Text(
      "Cuisine: ${widget.restaurant.cuisineType.join(', ')}",
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildLocation() {
    return FutureBuilder<String>(
      future: getAddressFromCoordinates(
        widget.restaurant.location.latitude,
        widget.restaurant.location.longitude,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else {
          return Text(
            "Location: ${snapshot.data}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }
      },
    );
  }

  Widget _buildOperatingHours() {
    // Define the correct order for the days of the week
    final orderedDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    // Sort the operating hours based on the defined order
    final sortedOperatingHours = widget.restaurant.operatingHours.entries
        .toList()
      ..sort((a, b) =>
          orderedDays.indexOf(a.key).compareTo(orderedDays.indexOf(b.key)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Operating Hours:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // Display each day in the sorted order
        ...sortedOperatingHours.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(
                left: 10, top: 4), // Add padding above each entry
            child: Text(
                "${entry.key}: ${entry.value.open} - ${entry.value.close}"),
          );
        }),
      ],
    );
  }

  Widget _buildTags() {
    return widget.restaurant.tags.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tags:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0,
                children: widget.restaurant.tags.map((tag) {
                  return Chip(label: Text(tag));
                }).toList(),
              ),
            ],
          )
        : Container();
  }

  Widget _buildReviewsSection(ReviewProvider reviewProvider) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final User? user = userProvider.userData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Reviews:', style: TextStyle(fontSize: 20)),
            if (reviewProvider.reviews.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllReviewsScreen(
                        restaurantId: widget.restaurant.id,
                        restaurantName: widget.restaurant.name,
                        user: user,
                      ),
                    ),
                  );
                },
                child: const Text('View All Reviews'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Consumer<ReviewProvider>(
          builder: (context, reviewProvider, _) {
            return reviewProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : reviewProvider.reviews.isEmpty
                    ? const Text(
                        'No reviews yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      )
                    : SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: reviewProvider.reviews.length,
                          itemBuilder: (context, index) {
                            final review = reviewProvider.reviews[index];
                            return _buildReviewCard(
                                review.feedback, review.rating);
                          },
                        ),
                      );
          },
        ),
      ],
    );
  }

  Widget _buildReviewCard(String feedback, double rating) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 10),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feedback,
                style: const TextStyle(fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(
                  5,
                  (starIndex) => Icon(
                    starIndex < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final userId =
        Provider.of<UserProvider>(context, listen: false).firebaseUser?.uid;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3,
      children: [
        _buildActionButton(
          "Make a Reservation",
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddBookingScreen(
                  restaurant: widget.restaurant,
                  userId: userId ?? '',
                ),
              ),
            );
          },
        ),
        _buildActionButton(
          "Leave a Review",
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LeaveReviewScreen(
                  restaurantId: widget.restaurant.id,
                  userId: userId ?? '',
                  restaurant: widget.restaurant,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
