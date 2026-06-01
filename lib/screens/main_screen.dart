import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_flow/screens/home_screen.dart';
import 'package:barber_flow/screens/user/my_bookings_screen.dart';
import 'package:barber_flow/screens/user/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const Scaffold(body: Center(child: Text('Explore Data Here'))),
      const MyBookingsScreen(),
      const ProfileScreen(),
    ];

    final isWide = MediaQuery.of(context).size.width >= 800;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
              selectedIconTheme: IconThemeData(color: Theme.of(context).primaryColor, size: 28),
              unselectedIconTheme: const IconThemeData(color: Colors.grey, size: 24),
              selectedLabelTextStyle: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Theme.of(context).primaryColor,
              ),
              unselectedLabelTextStyle: GoogleFonts.manrope(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey,
              ),
              leading: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cut,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'StylenCut',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: Text('Explore'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: Text('Bookings'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: screens[_currentIndex],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w500, fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
