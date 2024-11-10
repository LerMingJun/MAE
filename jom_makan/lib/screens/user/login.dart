import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/providers/auth_provider.dart';
import 'package:jom_makan/screens/restaurant/restaurant_home.dart';
import 'package:jom_makan/screens/user/signup.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_buttons.dart';
import 'package:jom_makan/widgets/custom_text.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class Login extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Login({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  Image.asset(
                    'assets/logo-no-background.png',
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    controller: _emailController,
                    placeholderText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    controller: _passwordController,
                    placeholderText: 'Password',
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 40),
                  CustomPrimaryButton(
                    onPressed: () async {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      await authProvider.signInWithEmail(email, password);

                      // Check if user is logged in successfully
                      if (authProvider.user != null) {
                        // Determine role after successful login
                        String userRole =
                            await _determineUserRole(authProvider.user!);

                        if (userRole == 'user') {
                          Navigator.pushReplacementNamed(
                              context, '/homeScreen');
                        } else if (userRole == 'restaurant') {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RestaurantHome(
                                        restaurantId: authProvider.user!.uid,
                                      )));
                        } else if (userRole == 'admin') {
                          Navigator.pushReplacementNamed(context, '/adminHome');
                        } else {
                          // Show error if no role found
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content:
                                  Text('Error Logging In, Please Try Again.'),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content:
                                Text('Error Logging In, Please Try Again.'),
                          ),
                        );
                      }
                    },
                    text: "Login",
                  ),
                  const SizedBox(height: 50),
                  const Text("or", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      text: 'Not part of us yet? ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Sign Up Now!',
                          style: TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const SignUp();
                              }));
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      text: 'Join as restaurant partner? ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Sign Up Now!',
                          style: TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/restaurantSignUp');
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (authProvider.isLoading)
              Container(
                color: AppColors.background.withOpacity(0.7),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SpinKitWanderingCubes(
                      color: AppColors.primary,
                      size: 70.0,
                    ),
                    const SizedBox(height: 10),
                    Text("Logging you in...",
                        style: GoogleFonts.lato(
                            color: AppColors.primary, fontSize: 20))
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Future<String> _determineUserRole(auth.User user) async {
    // Check if the user is a restaurant
    DocumentSnapshot restaurantDoc = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(user.uid)
        .get();
    if (restaurantDoc.exists) {
      return 'restaurant';
    }

    // Check if the user is an admin
    if (user.email == 'admin@admin.com') {
      return 'admin';
    }

    // If neither, assume it's a regular user
    return 'user';
  }
}
