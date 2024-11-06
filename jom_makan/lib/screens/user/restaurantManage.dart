import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/models/booking.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/providers/booking_provider.dart';
import 'package:jom_makan/providers/favorite_provider.dart';
import 'package:jom_makan/providers/restaurant_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/screens/user/bookingDetails.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_cards.dart';
import 'package:provider/provider.dart';

class RestaurantManagementPage extends StatefulWidget {
  const RestaurantManagementPage({Key? key}) : super(key: key);

  @override
  State<RestaurantManagementPage> createState() =>
      _RestaurantManagementPageState();
}

class _RestaurantManagementPageState extends State<RestaurantManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Three tabs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String? userId = userProvider.firebaseUser?.uid;
      Provider.of<FavoriteProvider>(context, listen: false)
          .fetchFavorites(userId!);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text(
              "Restaurant Management",
              style: GoogleFonts.lato(
                fontSize: 24,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            pinned: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorPadding:
                    EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: [
                  Tab(text: 'Booking'),
                  Tab(text: 'History'),
                  Tab(text: 'Favorite'),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: MediaQuery.of(context).size.height - 120,
              child: TabBarView(
                controller: _tabController,
                children: [
                  BookedRestaurantContent(),
                  BookingHistoryContent(),
                  FavoriteRestaurantTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookedRestaurantContent extends StatefulWidget {
  @override
  _BookedRestaurantContentState createState() =>
      _BookedRestaurantContentState();
}

class _BookedRestaurantContentState extends State<BookedRestaurantContent> {
  List<Restaurant?> _restaurants = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      final userId = userProvider.firebaseUser?.uid;

      if (userId != null) {
        bookingProvider.fetchBookings(userId).then((_) {
          _fetchRestaurantDetails(bookingProvider.bookings);
        });
      }
    });
  }

  Future<void> _fetchRestaurantDetails(List<Booking> bookings) async {
    final oneHourLater = DateTime.now().add(Duration(hours: 1));
    List<Booking> upcomingBookings = bookings
        .where((booking) => booking.timeSlot.toDate().isAfter(oneHourLater))
        .toList();

    for (var booking in upcomingBookings) {
      var restaurant =
          await Provider.of<RestaurantProvider>(context, listen: false)
              .fetchRestaurantByID(booking.restaurantId);
      _restaurants.add(restaurant);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final oneHourLater = DateTime.now().add(Duration(hours: 1));
    List<Booking> upcomingBookings = bookingProvider.bookings
        .where((booking) => booking.timeSlot.toDate().isAfter(oneHourLater))
        .toList();

    return bookingProvider.isLoading
        ? Center(child: CircularProgressIndicator())
        : upcomingBookings.isEmpty
            ? Center(child: Text('No upcoming bookings found.'))
            : ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: upcomingBookings.length,
                itemBuilder: (context, index) {
                  final booking = upcomingBookings[index];
                  final restaurant =
                      _restaurants.isNotEmpty ? _restaurants[index] : null;
                  return CustomBookingCard(
                    restaurantName:
                        restaurant?.name ?? 'Fetching Restaurant...',
                    location: restaurant?.location ?? const GeoPoint(0, 0),
                    bookingDate: booking.timeSlot.toDate(),
                    imageUrl: restaurant?.image ??
                        'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                    status: booking.status,
                    numberOfPeople: booking.numberOfPeople,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailsPage(
                            restaurant: restaurant!,
                            booking: booking,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
  }
}

class BookingHistoryContent extends StatefulWidget {
  @override
  _BookingHistoryContentState createState() => _BookingHistoryContentState();
}

class _BookingHistoryContentState extends State<BookingHistoryContent> {
  List<Restaurant?> _restaurants = [];

  @override
  void initState() {
    super.initState();
    // Fetch past bookings for the user after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      final userId = userProvider.firebaseUser?.uid;

      if (userId != null) {
        bookingProvider.fetchBookings(userId).then((_) {
          // After fetching bookings, get restaurant names for history
          _fetchRestaurantDetailsForHistory(bookingProvider.bookings);
        });
      }
    });
  }

  Future<void> _fetchRestaurantDetailsForHistory(List<Booking> bookings) async {
    final oneHourLater = DateTime.now().add(Duration(hours: 1));
    List<Booking> pastBookings = bookings
        .where((booking) => booking.timeSlot.toDate().isBefore(oneHourLater))
        .toList();

    for (var booking in pastBookings) {
      var restaurant =
          await Provider.of<RestaurantProvider>(context, listen: false)
              .fetchRestaurantByID(booking.restaurantId);
      _restaurants.add(restaurant);
    }
    setState(() {}); // Update the UI after fetching restaurant details
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final oneHourLater = DateTime.now().add(Duration(hours: 1));
    List<Booking> pastBookings = bookingProvider.bookings
        .where((booking) => booking.timeSlot.toDate().isBefore(oneHourLater))
        .toList();

    return bookingProvider.isLoading
        ? Center(child: CircularProgressIndicator())
        : pastBookings.isEmpty
            ? Center(child: Text('No booking history found.'))
            : ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: pastBookings.length,
                itemBuilder: (context, index) {
                  final booking = pastBookings[index];
                  final restaurant = _restaurants.isNotEmpty
                      ? _restaurants[index]
                      : null; // Get the corresponding restaurant
                  return CustomBookingCard(
                    restaurantName: restaurant?.name ??
                        'Fetching Restaurant...', // Use restaurant name
                    location: restaurant?.location ??
                        const GeoPoint(0, 0), // Adjust to fetch actual location
                    bookingDate: booking.timeSlot.toDate(),
                    imageUrl: restaurant?.image ??
                        'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y', // Provide a real image URL
                    status: booking.status,
                    numberOfPeople: booking.numberOfPeople,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailsPage(
                            restaurant: restaurant!,
                            booking: booking,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
  }
}

class FavoriteRestaurantTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    return favoriteProvider.isLoading
        ? Center(child: CircularProgressIndicator())
        : favoriteProvider.favoriteRestaurants.isEmpty
            ? Center(child: Text('No favorite restaurants added yet.'))
            : ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: favoriteProvider.favoriteRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant =
                      favoriteProvider.favoriteRestaurants[index];
                  bool isFavorited =
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
                    isFavourited: isFavorited,
                  );
                },
              );
  }
}
