import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:barber_flow/screens/admin/admin_dashboard_screen.dart';
import 'package:barber_flow/screens/admin/admin_today_bookings_screen.dart';
import 'package:barber_flow/screens/admin/admin_manage_barbers_screen.dart';
import 'package:barber_flow/screens/main_screen.dart';
import 'package:barber_flow/services/auth_service.dart';
import 'package:barber_flow/viewmodels/admin_viewmodel.dart';
import '../../viewmodels/salon_viewmodel.dart';
import 'admin_edit_salon_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;
  bool _initializing = true;
  String? _errorMessage;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminTodayBookingsScreen(),
    const AdminManageBarbersScreen(),
    const _AdminSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAdminWorkspace();
  }

  Future<void> _initializeAdminWorkspace() async {
    try {
      final adminId = await AuthService.getUserId();
      if (adminId == null) {
        setState(() {
          _errorMessage = "Unable to retrieve authenticated Admin account ID.";
          _initializing = false;
        });
        return;
      }

      final salonViewModel = Provider.of<SalonViewModel>(context, listen: false);
      await salonViewModel.fetchAdminSalon(adminId);

      if (salonViewModel.adminSalon == null) {
        setState(() {
          _errorMessage = "No salon found for your Admin account. Please contact support.";
          _initializing = false;
        });
        return;
      }

      final adminViewModel = Provider.of<AdminViewModel>(context, listen: false);
      await adminViewModel.initializeSalon(salonViewModel.adminSalon!.id);

      setState(() {
        _initializing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error initializing workspace: ${e.toString()}";
        _initializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_initializing) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Initializing Admin Workspace...',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 24),
                Text(
                  'Workspace Error',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                    );
                  },
                  child: const Text('Back to Client Panel'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                      Icons.admin_panel_settings_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Admin Panel',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dash'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: Text('Schedule'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.group_outlined),
                  selectedIcon: Icon(Icons.group),
                  label: Text('Barbers'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: _screens[_currentIndex],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
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
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dash',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Barbers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _AdminSettingsScreen extends StatefulWidget {
  const _AdminSettingsScreen();

  @override
  State<_AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<_AdminSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<SalonViewModel>();
      if (viewModel.adminSalon == null) {
        final adminId = await AuthService.getUserId();
        if (adminId != null) {
          viewModel.fetchAdminSalon(adminId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.grey.shade100;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Admin Settings',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: Consumer<SalonViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.adminSalon == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final salon = viewModel.adminSalon;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome / Salon Profile Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.storefront,
                          color: Theme.of(context).primaryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              salon?.name ?? 'No Salon Configured',
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              salon?.address ?? 'No address set',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'ACCOUNT & SALON',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),

                // Settings Menu List
                if (salon != null) ...[
                  _buildSettingsTile(
                    icon: Icons.edit_note,
                    title: 'Edit Salon Details',
                    subtitle: 'Name, hours, cover image, and phone',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AdminEditSalonScreen(salon: salon),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                _buildSettingsTile(
                  icon: Icons.swap_horizontal_circle_outlined,
                  title: 'Switch to User Panel',
                  subtitle: 'Browse salons as a client',
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.grey.shade100;
    
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.white24 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
