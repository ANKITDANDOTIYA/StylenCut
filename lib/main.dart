import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:barber_flow/screens/onboarding/splash_screen.dart';
import 'package:barber_flow/viewmodels/admin_viewmodel.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
      ],
      child: MaterialApp(
        title: 'BarberFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFC19A6B),
            primary: const Color(0xFFC19A6B),
            background: const Color(0xFFFFFFFF),
          ),
          useMaterial3: true,
          primaryColor: const Color(0xFFC19A6B),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light Grey section background
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme.copyWith(
              // Headings
              displayLarge: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 24),
              displayMedium: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 24),
              displaySmall: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 24),
              headlineLarge: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 24),
              headlineMedium: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 24),
              titleLarge: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w600), // Card Titles
              
              // Body/Metadata
              bodyMedium: const TextStyle(color: Color(0xFF666666), fontSize: 14, fontWeight: FontWeight.normal),
              bodySmall: const TextStyle(color: Color(0xFF666666), fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC19A6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50), // Pill-shaped 
              ),
              elevation: 0,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFFC19A6B),
            unselectedItemColor: Color(0xFF666666),
            selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}