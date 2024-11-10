import 'package:flutter/material.dart';
import 'package:jom_makan/models/promotion.dart';
import 'package:jom_makan/providers/promotion_provider.dart';
import 'package:provider/provider.dart';

class AddPromotionScreen extends StatefulWidget {
  final String restaurantId;
  const AddPromotionScreen({super.key, required this.restaurantId});

  @override
  _AddPromotionScreenState createState() => _AddPromotionScreenState();
}

class _AddPromotionScreenState extends State<AddPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  bool isPercentage = true;
  bool isActive = true;

  void onNextButtonPressed() {
    if (_formKey.currentState!.validate()) {
      double discountValue = double.parse(discountController.text);

      if (isPercentage && (discountValue < 5 || discountValue > 90)) {
        showError("Discount percentage must be between 5% and 90%.");
        return;
      }

      // Navigate to the NextScreen with the collected data
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NextScreen(
            restaurantId: widget.restaurantId,
            title: titleController.text,
            description: descriptionController.text,
            discountValue: discountValue.toString(),
            isPercentage: isPercentage,
            isActive: isActive,
          ),
        ),
      );
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Voucher Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Title"),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Enter title",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text("Description"),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Enter description",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text("Discount Value"),
              const SizedBox(height: 8),
              ToggleButtons(
                borderRadius: BorderRadius.circular(8),
                isSelected: [isPercentage, !isPercentage],
                onPressed: (index) {
                  setState(() {
                    isPercentage = index == 0;
                    discountController.clear();
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("Percentage"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text("Fixed Amount"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isPercentage
                      ? "Enter the discount percentage."
                      : "Enter the discount amount.",
                  suffixText: isPercentage ? "%" : "RM",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  helperText: isPercentage
                      ? "It must be between 5% and 90%."
                      : "Enter a fixed discount amount.",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a discount value.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text("Voucher Status"),
              const SizedBox(height: 8),
              SwitchListTile(
                title: Text(isActive ? "Active" : "Inactive"),
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onNextButtonPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Next"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NextScreen extends StatelessWidget {
  final String restaurantId;
  final String title;
  final String description;
  final String discountValue;
  final bool isPercentage;
  final bool isActive;

  const NextScreen({
    super.key,
    required this.restaurantId,
    required this.title,
    required this.description,
    required this.discountValue,
    required this.isPercentage,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Your Voucher"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Voucher Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text("Title: $title"),
            const SizedBox(height: 8),
            Text("Description: $description"),
            const SizedBox(height: 8),
            Text("Discount Value: ${isPercentage ? "$discountValue%" : "RM $discountValue"}"),
            const SizedBox(height: 8),
            Text("Status: ${isActive ? "Active" : "Inactive"}"),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Confirm"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Voucher"),
          content: const Text("Are you sure you want to confirm this voucher?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addPromotion(context); // Call addPromotion function
                Navigator.of(context).pop(); // Close the dialog

              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  void _addPromotion(BuildContext context) {
    final promotionProvider =
        Provider.of<PromotionProvider>(context, listen: false);

    Promotion promotion = Promotion(
      id: "",
      restaurantId: restaurantId,
      title: title,
      description: description,
      discountAmount: isPercentage ? '$discountValue%' : 'RM $discountValue',
      status: isActive,
    );
    promotionProvider.submitpromotion(promotion).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Voucher confirmed!")),
      );
      Navigator.of(context).pop(); // Navigate back or to a different screen
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to confirm voucher: $error")),
      );
    });
  }
}