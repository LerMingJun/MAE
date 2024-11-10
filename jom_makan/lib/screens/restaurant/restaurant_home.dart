import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:jom_makan/models/booking.dart';
import 'package:jom_makan/providers/booking_provider.dart';
import 'package:jom_makan/widgets/restaurant/custom_bottom_navigation.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';  // Import the smooth_page_indicator package
import 'package:image_picker/image_picker.dart';  // Import image picker package
import 'package:firebase_storage/firebase_storage.dart';  // Import Firebase Storage
import 'package:jom_makan/widgets/Restaurant/custom_loading.dart';  // Import the loading dialog
import 'package:jom_makan/screens/restaurant/restaurant_report.dart';
import 'package:jom_makan/screens/restaurant/restaurant_review.dart';
import 'package:jom_makan/screens/restaurant/restaurant_support.dart';


class RestaurantHome extends StatefulWidget {
  final String restaurantId;

  const RestaurantHome({super.key, required this.restaurantId});

  @override
  _RestaurantHomeState createState() => _RestaurantHomeState();
}

class _RestaurantHomeState extends State<RestaurantHome> {
  int _selectedIndex = 0;
  int _currentCarouselIndex = 0;
  List<String>? _menuImageUrls; // List to hold menu image URLs
  final PageController pageController = PageController(); // Define the PageController

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMenuImages();
      Provider.of<BookingProvider>(context, listen: false)
          .fetchPendingBookings(widget.restaurantId);
    });
  }

  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  // Fetch menu images from Firestore
  Future<void> _fetchMenuImages() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .get();

      if (docSnapshot.exists) {
        List<dynamic> menuImages = docSnapshot['menu'];
        setState(() {
          _menuImageUrls = menuImages.cast<String>();
        });
      } else {
        print('Restaurant not found.');
      }
    } catch (e) {
      print("Error fetching menu images: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Show menu images and allow editing options
  void _showMenuImages() {
    if (_menuImageUrls != null && _menuImageUrls!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Menu Images'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_a_photo),
                  onPressed: _uploadImage, // Upload a new image
                ),
              ],
            ),
            body: Stack(
              children: [
                PhotoViewGallery.builder(
                  itemCount: _menuImageUrls!.length,
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: NetworkImage(_menuImageUrls![index]),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered,
                      heroAttributes: PhotoViewHeroAttributes(tag: _menuImageUrls![index]),
                    );
                  },
                  scrollPhysics: const BouncingScrollPhysics(),
                  backgroundDecoration: const BoxDecoration(color: Colors.black),
                  pageController: pageController, // Use the globally defined PageController
                ),
                Positioned(
                  top: 8.0,
                  right: 8.0,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      final currentImageUrl = _menuImageUrls![pageController.page!.round()];
                      _showDeleteDialog(currentImageUrl);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: const Text('Menu images not available.'),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  // Upload a new image
  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      CustomLoading.show(context);  // Show loading dialog
      try {
        final fileName = pickedFile.name;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('restaurant_images/${widget.restaurantId}/$fileName');

        await storageRef.putFile(File(pickedFile.path));
        final downloadUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .update({
          'menu': FieldValue.arrayUnion([downloadUrl]),
        });

        // Update UI after uploading
        setState(() {
          _menuImageUrls?.add(downloadUrl);
        });

        CustomLoading.hide(context);  // Hide loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')),
        );

        // Navigate back to the main page
        Navigator.of(context).pop();

      } catch (e) {
        CustomLoading.hide(context);  // Hide loading dialog
        print("Error uploading image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    }
  }

  // Delete image from Firestore and Firebase Storage
  Future<void> _deleteImage(String imageUrl) async {
    if (_menuImageUrls != null && _menuImageUrls!.length > 1) {
      CustomLoading.show(context);  // Show loading dialog
      try {
        final Uri url = Uri.parse(imageUrl);
        final String imageFileName = url.pathSegments.last;

        final storageRef = FirebaseStorage.instance
            .ref()
            .child(imageFileName);

        await storageRef.delete();
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .update({
          'menu': FieldValue.arrayRemove([imageUrl]),
        });

        setState(() {
          _menuImageUrls?.remove(imageUrl);
        });

        CustomLoading.hide(context);  // Hide loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image deleted successfully')),
        );

        // Navigate back to the main page
        Navigator.of(context).pop();

      } catch (e) {
        CustomLoading.hide(context);  // Hide loading dialog
        print("Error deleting image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete image')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There must be at least one menu image')),
      );
    }
  }

  // Show dialog to confirm image deletion
  void _showDeleteDialog(String imageUrl) {
    if (_menuImageUrls != null && _menuImageUrls!.length == 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Cannot Delete Image'),
            content: const Text('There must be at least one menu image.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Image'),
            content: const Text('Are you sure you want to delete this image?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _deleteImage(imageUrl);
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    List<Booking> pendingBookings = bookingProvider.bookings
        .where((booking) => booking.status == 'Pending') // Filter pending bookings
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          children: [
            Image.asset('assets/logo.jpg', width: 50, height: 50),
            const SizedBox(width: 8),
            const Text(
              'JOM MAKAN',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Notification action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pending Bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            bookingProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : pendingBookings.isEmpty
                    ? const Center(child: Text('No pending bookings'))
                    : SizedBox(
                        height: 130,
                        child: PageView.builder(
                          itemCount: pendingBookings.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentCarouselIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return _buildCarouselCard(pendingBookings[index]);
                          },
                        ),
                      ),
            const SizedBox(height: 16),
            Center(
              child: SmoothPageIndicator(
                controller: PageController(initialPage: _currentCarouselIndex),
                count: pendingBookings.length,
                effect: const WormEffect(
                  activeDotColor: Colors.orange,
                  dotHeight: 8.0,
                  dotWidth: 8.0,
                  spacing: 16.0,
                ),
              ),
            ),
            const SizedBox(height: 50),
            GridView(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              children: [
                _buildGridItem(Icons.analytics, 'Report', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportPage(restaurantId: widget.restaurantId),
                    ),
                  );
                }),
                _buildGridItem(Icons.menu_book, 'Menu', onTap: _showMenuImages),
                _buildGridItem(Icons.message_rounded, 'Review', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewPage(restaurantId: widget.restaurantId),
                    ),
                  );
                }),
                // _buildGridItem(Icons.settings, 'Settings'),
                _buildGridItem(Icons.settings_rounded, 'Settings', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SupportPage(restaurantId: widget.restaurantId),
                    ),
                  );
                }),
                
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
        restaurantId: widget.restaurantId,
      ),
    );
  }

  Widget _buildCarouselCard(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              const Icon(Icons.pending, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Booking ID: ${booking.bookingId}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Number of People: ${booking.numberOfPeople}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.black54, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Time Slot: ${booking.timeSlot.toDate()}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildGridItem(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }
}
