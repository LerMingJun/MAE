import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jom_makan/providers/auth_provider.dart';
import 'package:jom_makan/theming/custom_themes.dart';
import 'package:jom_makan/widgets/custom_buttons.dart';
import 'package:jom_makan/widgets/custom_text.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 20), // Horizontal padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Align items to the start
                crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
                children: [
                  const SizedBox(height: 100), // Space at the top to give some breathing room
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
                    onChanged: (value) {
                      // Handle text field changes
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    controller: _passwordController,
                    placeholderText: 'Password',
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    onChanged: (value) {
                      // Handle text field changes
                    },
                  ),
                  const SizedBox(height: 40),
                  CustomPrimaryButton(
                    onPressed: () async {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      await authProvider.signInWithEmail(email, password);
                      if (authProvider.user != null) {
                        Navigator.pushReplacementNamed(context, '/homeScreen');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              'Error Logging In, Please Try Again.',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                            showCloseIcon: true,
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
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Sign Up Now!',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/signup');
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40), // Add some space below
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
}
