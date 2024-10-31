import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:folks_app/providers/auth_provider.dart';
import 'package:folks_app/theming/custom_themes.dart';
import 'package:folks_app/widgets/custom_buttons.dart';
import 'package:folks_app/widgets/custom_text.dart';
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/fist.png',
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                    Text(
                      "folks",
                      style: GoogleFonts.lato(
                          fontSize: 60.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary),
                      textAlign: TextAlign.center,
                    ),
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
                          Navigator.pushReplacementNamed(
                              context, '/homeScreen');
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
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconButton(
                            text: "Google Sign In",
                            onPressed: () async {
                              await authProvider.signInWithGoogle();
                              if (authProvider.user != null) {
                                Navigator.pushReplacementNamed(
                                    context, '/homeScreen');
                              }
                            },
                            imagePath: "assets/google.png"),
                      ],
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        text: 'Not part of us yet? ',
                        style: TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Sign Up Now!',
                            style: TextStyle(
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
                  ],
                ),
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
