import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class AppColors {
  // static const Color primary = Color.fromARGB(255, 131, 121, 193);
  // Use color code 455045
  static const Color primary = Color(0xFFE69045);
  static const Color secondary = Color(0xFFD45769);
  static const Color tertiary = Color(0xFFF7EFE5);
  static const Color placeholder = Color.fromARGB(255, 104, 104, 104);
  static const Color background = Color(0xFFF5FFFF);
}
// class AppColors {
//   static const Color primary = Color(0xFF140F2D);
//   static const Color secondary = Color(0xFF3F88C5);
//   static const Color tertiary = Color(0xFFF49D37);
//   static const Color placeholder = Color.fromARGB(255, 104, 104, 104);
//   static const Color background = Color(0xFFF5FFFF);
// }
// class AppColors {
//   static const Color primary = Color(0xFF241E4E);
//   static const Color secondary = Color(0xFF247BA0);
//   static const Color tertiary = Color(0xFFCE6C47);
//   static const Color placeholder = Color.fromARGB(255, 104, 104, 104);
//   static const Color background = Color(0xFFF5FFFF);
// }
// class AppColors {
//   static const Color primary = Color(0xFF094074);
//   static const Color secondary = Color(0xFF3c6997);
//   static const Color tertiary = Color(0xFF5adbff);
//   static const Color placeholder = Color.fromARGB(255, 104, 104, 104);
//   static const Color background = Color(0xFFF5FFFF);
// }

// class AppColors {
//   static const Color primary = Color(0xFF006400);
//   static const Color secondary = Color(0xFF66CDAA);
//   static const Color tertiary = Color(0xFF98FB98);
//   static const Color placeholder = Color.fromARGB(255, 104, 104, 104);
//   static const Color background = Color(0xFFF5FFFF);
// }

class AppTextStyles {
  static final TextStyle authHead = GoogleFonts.lato(
      fontSize: 32.0,
      //fontWeight: FontWeight.bold,
      color: Colors.black);

  static final TextStyle displayLarge = GoogleFonts.lato(
    fontSize: 15.0,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16.0,
    color: AppColors.secondary,
  );

  // Add more text styles as needed
}

class CustomTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      hintColor: AppColors.placeholder,
      scaffoldBackgroundColor: AppColors.background,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shadowColor: AppColors.primary, // Text color of TextButton
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent
      ),
      
      
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      hintColor: AppColors.placeholder,
      scaffoldBackgroundColor: AppColors.background,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shadowColor: AppColors.primary, // Text color of TextButton
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent
      ),
    );
  }
}
