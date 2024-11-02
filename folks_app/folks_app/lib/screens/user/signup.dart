import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:folks_app/providers/auth_provider.dart';
import 'package:folks_app/theming/custom_themes.dart';
import 'package:folks_app/widgets/custom_buttons.dart';
import 'package:folks_app/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  List<String> _selectedOptions = [];
  final List<String> _options = [
    'Italian',
    'Chinese',
    'Indian',
    'Mexican',
    'Thai',
    'French',
    'Japanese',
    'Korean',
    'Vietnamese',
    'Vegetarian',
    'Vegan',
    'Gluten-free',
    'Prawn Allergy',
    'Egg Allergy',
    'Fish Allergy',
    'Shellfish Allergy',
    'Dairy Allergy',
    'Soy Allergy',
    // Add more options as needed
  ];
   String _selectedOption = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Column(
                  children: [
                    Text("Greetings, Register to Join The Folks!",
                        style: AppTextStyles.authHead),
                    const SizedBox(height: 70),
                    CustomTextFormField(
                      controller: _usernameController,
                      placeholderText: 'Username',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _fullnameController,
                      placeholderText: 'Fullname',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _emailController,
                      placeholderText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _passwordController,
                      placeholderText: 'Password',
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                    ),
                    const SizedBox(height: 40),

                    // Preferences Selection
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select Your Preferences:",
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.black),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: _selectedOptions.map((option) {
                          return Chip(
                            label: Text(option),
                            deleteIcon: Icon(Icons.close),
                            onDeleted: () {
                              setState(() {
                                _selectedOptions.remove(option);
                              });
                            },
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Custom Scrollable Dropdown
                    CustomDropdown(
                      options: _options,
                      selectedOptions: _selectedOptions,
                      onChanged: (List<String> selected) {
                        setState(() {
                          _selectedOptions = selected;
                        });
                      },
                    ),
                    const SizedBox(height: 40),

                    CustomPrimaryButton(
                      onPressed: () async {
                        final username = _usernameController.text.trim();
                        final fullname = _fullnameController.text.trim();
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        if (username.isNotEmpty &&
                            fullname.isNotEmpty &&
                            email.isNotEmpty &&
                            password.isNotEmpty) {
                          if (password.length > 5) {
                            await authProvider.signUpWithEmail(email, password,
                                fullname, username, _selectedOptions);
                            if (authProvider.user != null) {
                              Navigator.pushReplacementNamed(
                                  context, '/homeScreen');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    'Something Went Wrong Please Try Again.',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white),
                                  ),
                                  showCloseIcon: true,
                                ),
                              );
                            }
                          } else {
                            AwesomeDialog(
                              context: context,
                              animType: AnimType.scale,
                              dialogType: DialogType.warning,
                              body: Center(
                                child: Text(
                                  'Password must be longer than 6 characters.',
                                  style: TextStyle(),
                                ),
                              ),
                              btnOkOnPress: () {},
                              btnOkColor: AppColors.secondary,
                            )..show();
                          }
                        } else {
                          AwesomeDialog(
                            context: context,
                            animType: AnimType.scale,
                            dialogType: DialogType.warning,
                            body: Center(
                              child: Text(
                                'Please fill in all relevant fields.',
                                style: TextStyle(),
                              ),
                            ),
                            btnOkOnPress: () {},
                            btnOkColor: AppColors.secondary,
                          )..show();
                        }
                      },
                      text: "Register",
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              if (authProvider.isLoading)
                Container(
                  color: AppColors.background,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitWanderingCubes(
                        color: AppColors.primary,
                        size: 70.0,
                      ),
                      SizedBox(height: 10),
                      Text("Registering...",
                          style: GoogleFonts.lato(
                              color: AppColors.primary, fontSize: 20))
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
