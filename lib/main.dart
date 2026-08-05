import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:barber_flow/screens/onboarding/splash_screen.dart';
import 'package:barber_flow/viewmodels/admin_viewmodel.dart';
import 'package:barber_flow/viewmodels/auth_viewmodel.dart';
import 'package:barber_flow/viewmodels/salon_viewmodel.dart';
import 'package:barber_flow/viewmodels/theme_viewmodel.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  runApp(MyApp(initialDarkMode: isDarkMode));
}

class MyApp extends StatelessWidget {
  final bool initialDarkMode;
  const MyApp({super.key, required this.initialDarkMode});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => SalonViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel(initialDarkMode)),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, child) {
          final isDark = themeVM.isDarkMode;

          
          return MaterialApp(
            title: 'StylenCut',
            debugShowCheckedModeBanner: false,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              brightness: Brightness.light,
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
                  displayLarge: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 24),
                  displayMedium: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 24),
                  displaySmall: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 24),
                  headlineLarge: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 24),
                  headlineMedium: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 24),
                  titleLarge: const TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w600),
                  bodyMedium: const TextStyle(color: Color(0xFF666666), fontSize: 14, fontWeight: FontWeight.normal),
                  bodySmall: const TextStyle(color: Color(0xFF666666), fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC19A6B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
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
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                brightness: Brightness.dark,
                seedColor: const Color(0xFFC19A6B),
                primary: const Color(0xFFC19A6B),
                background: const Color(0xFF121212),
              ),
              useMaterial3: true,
              primaryColor: const Color(0xFFC19A6B),
              scaffoldBackgroundColor: const Color(0xFF121212), // Dark Slate background
              textTheme: GoogleFonts.poppinsTextTheme(
                Theme.of(context).textTheme.copyWith(
                  displayLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                  displayMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                  displaySmall: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                  headlineLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                  headlineMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                  titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  bodyMedium: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.normal),
                  bodySmall: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC19A6B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 0,
                ),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color(0xFF1E1E1E),
                selectedItemColor: Color(0xFFC19A6B),
                unselectedItemColor: Colors.white54,
                selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                unselectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                type: BottomNavigationBarType.fixed,
                elevation: 8,
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}