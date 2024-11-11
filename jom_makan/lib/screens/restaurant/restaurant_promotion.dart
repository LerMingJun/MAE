import 'package:flutter/material.dart';
import 'package:jom_makan/models/promotion.dart';
import 'package:jom_makan/providers/promotion_provider.dart';
import 'package:provider/provider.dart';
import 'package:jom_makan/screens/restaurant/add_promotion.dart'; // Import the Add Promotion page
import 'package:jom_makan/screens/restaurant/restaurant_home.dart'; 

class PromotionPage extends StatefulWidget {
  final String restaurantId;

  const PromotionPage({Key? key, required this.restaurantId}) : super(key: key);

  @override
  _PromotionPageState createState() => _PromotionPageState();
}

class _PromotionPageState extends State<PromotionPage> {
  String filterStatus = 'All'; // Filter for Active, Inactive, and All

  // Edit Promotion
  void _editPromotion(BuildContext context, Promotion promotion) async {
    final result = await _showEditDialog(
      context,
      currentTitle: promotion.title,
      currentDescription: promotion.description,
      currentDiscountAmount: promotion.discountAmount,
      currentStatus: promotion.status,
    );

    if (result != null) {
      // Show confirmation before updating
      bool? confirmUpdate = await _showConfirmationDialog(context, "Are you sure you want to update this promotion?");
    
      if (confirmUpdate == true) {
        // Handle the discount amount (preserving RM or %)
        String discountAmount = result['discountAmount'];
        if (discountAmount.startsWith('RM') || discountAmount.endsWith('%')) {
          // The user didn't modify the RM or %, so just use the result
        } else {
          // Handle any cases where the user has input an invalid discount amount
          discountAmount = promotion.discountAmount;  // Keep the original value if invalid
        }

        Promotion updatedPromotion = Promotion(
          id: promotion.id,  // Ensure the promotion ID is passed
          restaurantId: widget.restaurantId, // Ensure the restaurant ID is passed
          title: result['title'],
          description: result['description'],
          status: result['status'],
          discountAmount: discountAmount,  // Use the validated discount amount
        );

        // Pass both updatedPromotion and promotion.id to the provider method
        await Provider.of<PromotionProvider>(context, listen: false)
            .updatePromotion(updatedPromotion, promotion.id, widget.restaurantId);

        // Trigger refresh by fetching updated promotions
        setState(() {});
      }
    }
  }

  // Delete Promotion
  void _deletePromotion(String promotionId, String restaurantId) async {
    // Show confirmation dialog before deleting
    bool? confirmDelete = await _showConfirmationDialog(context, "Are you sure you want to delete this promotion?");

    if (confirmDelete == true) {
      try {
        await Provider.of<PromotionProvider>(context, listen: false)
            .deletePromotion(promotionId, restaurantId);  // Correct call to deletePromotion

        // Trigger refresh by fetching updated promotions
        setState(() {});
      } catch (e) {
        print('Error deleting promotion: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete promotion')),
        );
      }
    }
  }

  Future<bool?> _showConfirmationDialog(BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Action'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);  // User pressed Cancel
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);  // User pressed Confirm
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Show the Edit Dialog for Promotion
  Future<Map<String, dynamic>?> _showEditDialog(
    BuildContext context, {
    required String currentTitle,
    required String currentDescription,
    required String currentDiscountAmount,
    required bool currentStatus,
  }) {
    final TextEditingController titleController = TextEditingController(text: currentTitle);
    final TextEditingController descriptionController = TextEditingController(text: currentDescription);

    // Extract the numeric part of the discount amount, remove RM or % for display
    String displayDiscountAmount = currentDiscountAmount.replaceAll(RegExp(r'[^0-9.]'), '');

    final TextEditingController discountController = TextEditingController(text: displayDiscountAmount);
    bool isActive = currentStatus;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Promotion'),
          content: SingleChildScrollView(  // Add SingleChildScrollView here
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: discountController,
                  decoration: InputDecoration(labelText: 'Discount Amount'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),  // Allow decimal input
                ),
                SwitchListTile(
                  title: Text('Status'),
                  value: isActive,
                  onChanged: (value) {
                    isActive = value;
                    (context as Element).markNeedsBuild(); // Force rebuild to update status text
                  },
                  subtitle: Text(isActive ? 'Active' : 'Inactive'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Attach RM or % to the discount amount when saving
                String updatedDiscountAmount = discountController.text;
                if (currentDiscountAmount.startsWith('RM')) {
                  updatedDiscountAmount = 'RM $updatedDiscountAmount';
                } else if (currentDiscountAmount.endsWith('%')) {
                  updatedDiscountAmount = '$updatedDiscountAmount%';
                }

                Navigator.pop(context, {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'discountAmount': updatedDiscountAmount,
                  'status': isActive,
                });
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Filter promotions based on the selected status
  Future<List<Promotion>> _fetchPromotions() async {
    List<Promotion> promotions = await Provider.of<PromotionProvider>(context, listen: false)
        .getPromotionsByRestaurantId(widget.restaurantId);
    
    if (filterStatus == 'Active') {
      return promotions.where((promotion) => promotion.status).toList();
    } else if (filterStatus == 'Inactive') {
      return promotions.where((promotion) => !promotion.status).toList();
    } else {
      return promotions;  // 'All'
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Promotions"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the HomePage (or the desired page)
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => RestaurantHome(restaurantId: widget.restaurantId)),
              (Route<dynamic> route) => false, // Remove all previous routes
            );
          },
        ),
        actions: [
          // Filter Dropdown
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'All',
                child: Text('All'),
              ),
              PopupMenuItem(
                value: 'Active',
                child: Text('Active'),
              ),
              PopupMenuItem(
                value: 'Inactive',
                child: Text('Inactive'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Promotion>>(
        future: _fetchPromotions(), // Fetch filtered promotions
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading promotions"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No promotions available"));
          } else {
            final promotions = snapshot.data!;
            return ListView.builder(
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                final promotion = promotions[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(promotion.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description: ${promotion.description}'),
                        Text('Discount: ${promotion.discountAmount}'),
                        Text(
                          'Status: ${promotion.status ? "Active" : "Inactive"}',
                          style: TextStyle(
                            color: promotion.status ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editPromotion(context, promotion),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deletePromotion(promotion.id, widget.restaurantId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Promotion page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPromotionScreen(restaurantId: widget.restaurantId),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
