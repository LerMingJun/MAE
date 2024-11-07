import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jom_makan/models/restaurant.dart';
import 'package:jom_makan/providers/favorite_provider.dart';
import 'package:jom_makan/providers/user_provider.dart';
import 'package:jom_makan/screens/user/restaurantDetails.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_loading.dart';
import 'package:jom_makan/widgets/custom_text.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CustomVerticalCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String date;
  final String circleImageUrl;

  const CustomVerticalCard({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.date,
    required this.circleImageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: SizedBox(
        height: 100,
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return const CustomImageLoading(width: 100);
                  }
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    CustomIconText(
                        text: location, icon: Icons.location_on, size: 12),
                    CustomIconText(
                        text: date, icon: Icons.calendar_month, size: 12),
                    const Spacer(),
                    CircleAvatar(
                      radius: 11,
                      backgroundImage: NetworkImage(circleImageUrl),
                    ),
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

class CustomHorizontalCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final Timestamp date1;
  final VoidCallback onTap;

  const CustomHorizontalCard({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.date1,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    DateTime date = date1.toDate();
    String formattedDate = DateFormat('MMMM dd').format(date).toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 10, right: 16),
      width: 200,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Card(
          semanticContainer: true,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 160,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return const CustomImageLoading(width: 160);
                          }
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8), // Better padding
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        formattedDate,
                        style: GoogleFonts.lato(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lato(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis, // Ensure text wraps
                      maxLines: 2,
                    ),
                    Text(
                      location,
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: AppColors.placeholder),
                      overflow: TextOverflow.ellipsis, // Ensure text wraps
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomRestaurantCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final GeoPoint location;
  final List<String> cuisineTypes;
  final String restaurantID;
  final String intro;
  final double rating;
  final Restaurant restaurant;
  final bool isFavourited;

  const CustomRestaurantCard({
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.cuisineTypes,
    required this.restaurantID,
    required this.intro,
    required this.rating,
    required this.restaurant,
    required this.isFavourited,
    super.key,
  });

  @override
  _CustomRestaurantCardState createState() => _CustomRestaurantCardState();
}

class _CustomRestaurantCardState extends State<CustomRestaurantCard> {
  String? address;
  bool isLoadingAddress = true; // Track address loading state

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
          address =
              "${placemark.street}, ${placemark.locality}, ${placemark.country}";
          isLoadingAddress = false; // Update loading state
        });
      }
    } catch (e) {
      setState(() {
        address = "Address not available";
        isLoadingAddress = false; // Update loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final String? userId = userProvider.firebaseUser?.uid;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailsScreen(
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
        child: Stack(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: Image.network(
                    widget.imageUrl,
                    height: 130,
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
                          isLoadingAddress
                              ? 'Fetching address...'
                              : (address ?? 'Address not available'),
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
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.rating.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  widget.isFavourited ? Icons.favorite : Icons.favorite_border,
                  color: widget.isFavourited ? Colors.red : Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    if (widget.isFavourited) {
                      favoriteProvider.removeFavorite(
                          userId!, widget.restaurantID);
                    } else {
                      favoriteProvider.addFavorite(
                          userId!, widget.restaurantID);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBookingCard extends StatefulWidget {
  final String restaurantName;
  final GeoPoint location;
  final DateTime bookingDate;
  final String imageUrl;
  final VoidCallback onTap;
  final String status; // Add status property
  final int numberOfPeople;

  const CustomBookingCard({
    required this.restaurantName,
    required this.location,
    required this.bookingDate,
    required this.imageUrl,
    required this.onTap,
    required this.status, // Initialize status
    required this.numberOfPeople,
    super.key,
  });

  @override
  _CustomBookingCardState createState() => _CustomBookingCardState();
}

class _CustomBookingCardState extends State<CustomBookingCard> {
  String? address;
  bool isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    if (widget.location.latitude != 0.0 && widget.location.longitude != 0.0) {
      _getAddressFromCoordinates();
    }
  }

  @override
  void didUpdateWidget(CustomBookingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.location.latitude != 0.0 || widget.location.longitude != 0.0) &&
        (widget.location != oldWidget.location)) {
      _getAddressFromCoordinates();
    }
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
          address =
              "${placemark.street}, ${placemark.locality}, ${placemark.country}";
          isLoadingAddress = false;
        });
      } else {
        setState(() {
          address = "No address found";
          isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        address = "Address not available";
        isLoadingAddress = false;
      });
    }
  }

  Color _getStatusColor() {
    switch (widget.status) {
      case 'Pending':
        return Colors.blue;
      case 'Booked':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('MMMM dd, yyyy – hh:mm a').format(widget.bookingDate);

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: AppColors.tertiary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Image.network(
                widget.imageUrl,
                width: 100,
                height: 120,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.restaurantName,
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            widget.status,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLoadingAddress
                          ? 'Fetching address...'
                          : (address ?? 'Address not available'),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${widget.numberOfPeople} people",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
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
