import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/auth_config.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/gold_price_page.dart';
import 'pages/metals_price_page.dart';
import 'pages/price_comparison_page.dart';
import 'pages/api_test_page.dart';
import 'pages/about_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (only if enabled and configured)
  if (AuthConfig.enableFirebase) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization error: $e');
      print('Firebase will be disabled. Using Supabase only.');
    }
  }
  
  // Initialize Supabase (only if enabled and configured)
  if (AuthConfig.enableSupabase && 
      AuthConfig.supabaseUrl.isNotEmpty && 
      AuthConfig.supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: AuthConfig.supabaseUrl,
        anonKey: AuthConfig.supabaseAnonKey,
      );
      print('Supabase initialized successfully');
    } catch (e) {
      print('Supabase initialization error: $e');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metal Fiyatları',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: GoogleFonts.poppins().fontFamily,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/gold': (context) => const GoldPricePage(),
        '/metals': (context) => const MetalsPricePage(),
        '/comparison': (context) => const PriceComparisonPage(),
        '/api-test': (context) => const ApiTestPage(),
        '/about': (context) => const AboutPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/profile': (context) => const ProfilePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
