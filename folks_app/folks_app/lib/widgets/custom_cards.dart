import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:folks_app/models/restaurant.dart';
import 'package:folks_app/screens/user/restaurantDetails.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:folks_app/theming/custom_themes.dart';
import 'package:folks_app/widgets/custom_loading.dart';
import 'package:folks_app/widgets/custom_text.dart';
import 'package:intl/intl.dart';

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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.white,
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: Container(
        height: 100,
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              decoration: BoxDecoration(
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
                    return CustomImageLoading(width: 100);
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
                    Spacer(),
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime date = date1.toDate();
    String formattedDate = DateFormat('MMMM dd').format(date).toUpperCase();
    return Container(
      margin: EdgeInsets.only(bottom: 10, right: 16),
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
                  Container(
                    width: double.infinity,
                    height: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return CustomImageLoading(width: 160);
                          }
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8), // Better padding
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
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
                padding: EdgeInsets.all(10),
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

class CustomEventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final Timestamp hostDate;
  final String eventID;
  final String type;

  const CustomEventCard({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.hostDate,
    required this.eventID,
    required this.type,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime date = hostDate.toDate();
    String formattedDate =
        DateFormat('MMMM dd, yyyy').format(date).toUpperCase();

    return GestureDetector(
      onTap: () {
        type == "project"
            ? Navigator.pushNamed(
                context,
                '/eventDetail',
                arguments: eventID,
              )
            : Navigator.pushNamed(
                context,
                '/speechDetail',
                arguments: eventID,
              );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        child: Row(
          children: [
            // Image on the left side
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Image.network(
                imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return CustomImageLoading(
                      width: 100,
                      height: 100,
                    );
                  }
                },
              ),
            ),
            // Details on the right side
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 4),
                    Text(
                      location,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: GoogleFonts.lato(
                            fontSize: 10,
                            color: Colors.black45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: type == 'project'
                                ? AppColors.tertiary
                                : Colors.orange,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Icon(
                            type == 'project'
                                ? Icons.diversity_3_outlined
                                : Icons.campaign_outlined,
                            size: 15,
                            color: type == 'project'
                                ? Colors.blue
                                : AppColors.primary,
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
      ),
    );
  }
}

class CustomRestaurantCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final GeoPoint location;
  final List<String> cuisineTypes;
  final String restaurantID;
  final String intro;
  final double rating; // New field for rating
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailsScreen(
                restaurant: restaurant), // Pass the restaurant object here
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
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Image.network(
                imageUrl,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return CustomImageLoading(
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
                      name,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${location.latitude}, ${location.longitude}', // Extract latitude and longitude
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),

                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 4),
                    Text(
                      cuisineTypes.join(', '),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 4),
                    Text(
                      intro,
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        color: Colors.black45,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: 4),
                    // Displaying the rating
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          rating.toString(),
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
      ),
    );
  }
}
