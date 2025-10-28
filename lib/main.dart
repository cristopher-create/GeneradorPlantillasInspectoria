import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/abordar_screen.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isLoggedInToday = await _checkLoginStatus();
  runApp(MyApp(isLoggedInToday: isLoggedInToday));
}

Future<bool> _checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final String? lastLoginDate = prefs.getString('last_login_date');

  if (lastLoginDate != null) {
    try {
      final DateTime storedDate = DateTime.parse(lastLoginDate);
      final DateTime now = DateTime.now();

      if (storedDate.year == now.year &&
          storedDate.month == now.month &&
          storedDate.day == now.day) {
        return true;
      } else {

        await prefs.remove('last_login_date');
        return false;
      }
    } catch (e) {

      print("Error parseando last_login_date: $e");
      await prefs.remove('last_login_date');
      return false;
    }
  }
  return false;
}

class MyApp extends StatelessWidget {
  final bool isLoggedInToday;

  const MyApp({super.key, required this.isLoggedInToday});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedInToday ? const AbordarScreen() : const LoginScreen(),

      routes: {
        '/abordar': (context) => const AbordarScreen(),
        '/login': (context) => const LoginScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1976D2),

        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          secondary: const Color(0xFF00BCD4),
        ),

        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        cardColor: Colors.white,
        canvasColor: Colors.white,

        textTheme: TextTheme(
          displayLarge: GoogleFonts.playfairDisplay(color: const Color(0xFF212121)),
          displayMedium: GoogleFonts.playfairDisplay(color: const Color(0xFF212121)),
          displaySmall: GoogleFonts.playfairDisplay(color: const Color(0xFF212121)),
          headlineLarge: GoogleFonts.playfairDisplay(color: const Color(0xFF212121)),
          headlineMedium: GoogleFonts.playfairDisplay(color: const Color(0xFF212121)),
          headlineSmall: GoogleFonts.playfairDisplay(color: const Color(0xFF212121)),
          titleLarge: GoogleFonts.playfairDisplay(color: const Color(0xFF212121)),
          titleMedium: GoogleFonts.quicksand(color: const Color(0xFF212121)),
          titleSmall: GoogleFonts.quicksand(color: const Color(0xFF212121)),
          bodyLarge: GoogleFonts.quicksand(color: const Color(0xFF424242)),
          bodyMedium: GoogleFonts.quicksand(color: const Color(0xFF616161)),
          labelLarge: GoogleFonts.quicksand(color: const Color(0xFF212121)),
          labelMedium: GoogleFonts.quicksand(color: const Color(0xFF616161)),
          labelSmall: GoogleFonts.quicksand(color: const Color(0xFF616161)),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 4.0,
          centerTitle: true,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF00BCD4),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2.0),
          ),
          labelStyle: GoogleFonts.quicksand(color: const Color(0xFF616161)),
          hintStyle: GoogleFonts.quicksand(color: const Color(0xFFBDBDBD)),
        ),
      ),
    );
  }
}