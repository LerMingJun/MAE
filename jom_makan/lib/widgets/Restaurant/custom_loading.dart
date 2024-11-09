// custom_loading.dart
import 'package:flutter/material.dart';

class CustomLoading extends StatelessWidget {
  const CustomLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const CustomLoading();
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
