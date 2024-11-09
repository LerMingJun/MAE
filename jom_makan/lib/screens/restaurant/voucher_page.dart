import 'package:flutter/material.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  _VoucherScreenState createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  TextEditingController discountController = TextEditingController();
  TextEditingController minimumOrderController = TextEditingController();
  TextEditingController maxAmountController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  bool noMaxAmount = true;
  bool isPercentage = true;
  bool setEndDate = false;

void onNextButtonPressed() {
  double? discountValue = double.tryParse(discountController.text);
  if (discountValue == null || discountValue <= 0) {
    showError("Please enter a valid discount value.");
    return;
  }

  if (isPercentage) {
    if (discountValue < 5 || discountValue > 90) {
      showError("Discount percentage must be between 5% and 90%.");
      return;
    }
  } else {
    double? minimumOrderValue = double.tryParse(minimumOrderController.text);
    if (minimumOrderValue == null || minimumOrderValue <= 0) {
      showError("Please enter a valid minimum order value.");
      return;
    }
  }

  if (!noMaxAmount) {
    double? maxAmountValue = double.tryParse(maxAmountController.text);
    if (maxAmountValue == null || maxAmountValue <= 0) {
      showError("Please enter a valid maximum discount amount.");
      return;
    }
  }

  if (startDateController.text.isEmpty) {
    showError("Please select a start date.");
    return;
  }

  if (setEndDate && endDateController.text.isEmpty) {
    showError("Please select an end date.");
    return;
  }

  // Passing the data to the NextScreen
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => NextScreen(
        discountValue: discountValue,
        isPercentage: isPercentage,
        maxAmount: noMaxAmount ? null : double.tryParse(maxAmountController.text),
        startDate: startDateController.text,
        endDate: setEndDate ? endDateController.text : null,
      ),
    ),
  );
}

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        DateTime fullDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        controller.text =
            "${fullDateTime.day} ${_getMonthName(fullDateTime.month)}, "
            "${_getWeekdayName(fullDateTime.weekday)} at "
            "${selectedTime.format(context)}";
      }
    }
  }

  String _getMonthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return weekdays[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set discount value"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Step 1 of 2",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              "Discount value",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isPercentage ? "Enter the discount percentage." : "Enter the discount amount.",
                suffixText: isPercentage ? "%" : "RM",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                helperText: isPercentage ? "It must be between 5% and 90%." : "Enter a fixed discount amount.",
              ),
            ),
            const SizedBox(height: 16),
            if (isPercentage)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [10, 15, 20, 25].map((value) {
                  return ElevatedButton(
                    onPressed: () {
                      discountController.text = "$value";
                    },
                    child: Text("$value%"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
            const Text(
              "Maximum Redemption Amount",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RadioListTile<bool>(
              title: const Text("No Maximum Amount"),
              value: true,
              groupValue: noMaxAmount,
              onChanged: (value) {
                setState(() {
                  noMaxAmount = value!;
                  maxAmountController.clear();
                });
              },
            ),
            RadioListTile<bool>(
              title: const Text("Set a Maximum Redemption Amount"),
              value: false,
              groupValue: noMaxAmount,
              onChanged: (value) {
                setState(() {
                  noMaxAmount = value!;
                });
              },
            ),
            if (!noMaxAmount)
              TextField(
                controller: maxAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter Maximum Redemption Amount",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              "Set a Redemption Period",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: startDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Start Date",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onTap: () => selectDate(context, startDateController),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text("Set an end date"),
              value: setEndDate,
              onChanged: (value) {
                setState(() {
                  setEndDate = value!;
                  if (!setEndDate) {
                    endDateController.clear();
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (setEndDate)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: endDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "End Date",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onTap: () => selectDate(context, endDateController),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            const SizedBox(height: 16),
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
    );
  }
}

class NextScreen extends StatelessWidget {
  final double discountValue;
  final bool isPercentage;
  final double? maxAmount;
  final String startDate;
  final String? endDate;

  NextScreen({
    required this.discountValue,
    required this.isPercentage,
    this.maxAmount,
    required this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Your Promotion"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Promotion Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Content container with a stylish design
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Discount Value: ${discountValue.toStringAsFixed(2)} ${isPercentage ? "%" : "RM"}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue[900]),
                  ),
                  const SizedBox(height: 8),
                  if (maxAmount != null)
                    Text(
                      "Maximum Redemption Amount: RM ${maxAmount!.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue[900]),
                    ),
                  if (maxAmount != null) const SizedBox(height: 8),
                  Text(
                    "Start Date: $startDate",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue[900]),
                  ),
                  const SizedBox(height: 8),
                  if (endDate != null)
                    Text(
                      "End Date: $endDate",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue[900]),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Confirm button
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
          title: const Text("Confirm Promotion"),
          content: const Text("Are you sure you want to confirm this promotion?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Code for confirming the promotion goes here
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Promotion confirmed!")),
                );
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
}