import 'package:flutter/material.dart';

class ModifyDetailScreen extends StatefulWidget {
  final String fieldType;

  const ModifyDetailScreen({super.key, required this.fieldType});

  @override
  _ModifyDetailScreenState createState() => _ModifyDetailScreenState();
}

class _ModifyDetailScreenState extends State<ModifyDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isButtonEnabled = false;
  String? errorMessage;

  String getFieldLabel() {
    switch (widget.fieldType) {
      case "phone":
        return "Contact Number";
      case "email":
        return "Email";
      case "address":
        return "Address";
      default:
        return "";
    }
  }

  Widget? getPrefixIcon() {
    switch (widget.fieldType) {
      case "phone":
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 12),
            SizedBox(
              width: 24,
              height: 24,
              child: Image.asset('assets/malaysiaflag.png'), // Malaysia flag
            ),
            const SizedBox(width: 4),
            const Text("+03 ", style: TextStyle(color: Colors.black)), // Malaysia code
          ],
        );
      case "email":
        return const Icon(Icons.email);
      case "address":
        return const Icon(Icons.location_on);
      default:
        return null;
    }
  }

  String getPlaceholderText() {
    switch (widget.fieldType) {
      case "phone":
        return "Enter your contact number";
      case "email":
        return "Enter your email";
      case "address":
        return "Enter your address";
      default:
        return "";
    }
  }

  String? validateInput(String value) {
    switch (widget.fieldType) {
      case "phone":
        final phone = value.replaceAll(RegExp(r'^\+60|03'), ''); // Remove country code and area code
        if (phone.isEmpty) {
          return "This mobile number is invalid. Please try again.";
        } else if (phone.length < 8 || phone.length > 9) {
          return "This mobile number is invalid. Please try again.";
        }
        break;
      case "email":
        final emailPattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[com]{3}$');
        if (!emailPattern.hasMatch(value)) {
          return "Invalid email format. Please try again.";
        }
        break;
      case "address":
        if (value.isEmpty) {
          return "Address cannot be empty.";
        }
        break;
    }
    return null;
  }

  void onInputChanged() {
    final validationMessage = validateInput(_controller.text);
    setState(() {
      errorMessage = validationMessage;
      isButtonEnabled = validationMessage == null;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(onInputChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(onInputChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getFieldLabel()),
      
      ),
      body: Form(

        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getFieldLabel(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _controller,
                    keyboardType: widget.fieldType == "phone"
                        ? TextInputType.phone
                        : widget.fieldType == "email"
                            ? TextInputType.emailAddress
                            : TextInputType.text,
                    decoration: InputDecoration(
                      hintText: getPlaceholderText(),
                      border: const OutlineInputBorder(),
                      prefixIcon: getPrefixIcon(),
                      errorText: errorMessage,
                    ),
                  ),
                ],
              ),
            ),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  child: SizedBox(
    width: double.infinity,
    height: 60, // Increased height for the Save button
    child: ElevatedButton(
      onPressed: isButtonEnabled
          ? () {
              Navigator.pop(context, _controller.text);
            }
          : null,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey; // Gray color when disabled
            }
            return Theme.of(context).primaryColor; // Default color when enabled
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey; // Text color matches button background when disabled
            }
            return Colors.white; // White text color when enabled
          },
        ),
      ),
      child: const Text("Save"),
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}
