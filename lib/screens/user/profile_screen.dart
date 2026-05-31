import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:barber_flow/services/auth_service.dart';
import 'package:barber_flow/services/salon_service.dart';
import 'package:barber_flow/screens/auth/login_screen.dart';
import 'package:barber_flow/screens/admin/admin_main_screen.dart';
import 'package:barber_flow/constants.dart';
import 'package:barber_flow/viewmodels/theme_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Guest Client';
  String _userEmail = 'client@barberflow.com';
  String _userRole = 'user';
  bool _isLoading = true;

  String? _userProfilePic;
  bool _isUploadingPic = false;

  // Modern UI states
  bool _pushNotifications = true;
  bool get _darkMode => Provider.of<ThemeViewModel>(context, listen: false).isDarkMode;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final name = await AuthService.getUserName();
      final role = await AuthService.getRole();
      
      // Attempt to retrieve email (with fallback)
      final email = await AuthService.getUserEmail();
      final profilePic = await AuthService.getUserProfilePic();

      if (mounted) {
        setState(() {
          _userName = name;
          _userRole = role ?? 'user';
          _userEmail = email;
          _userProfilePic = profilePic;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadProfilePic() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploadingPic = true;
      });

      // Upload using SalonService
      final uploadedUrl = await SalonService.uploadThumbnail(image.path);

      if (uploadedUrl != null) {
        await AuthService.saveUserProfilePic(uploadedUrl);

        // Update the profile picture in the database
        final userId = await AuthService.getUserId();
        final userEmail = await AuthService.getUserEmail();

        await AuthService.updateProfilePicOnServer(
          userId: userId,
          email: userEmail,
          profilePic: uploadedUrl,
        );

        if (mounted) {
          setState(() {
            _userProfilePic = uploadedUrl;
            _isUploadingPic = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully!')),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isUploadingPic = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload profile picture. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingPic = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final isDark = Provider.of<ThemeViewModel>(context, listen: false).isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Change Password',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (currentPasswordController.text.isEmpty ||
                  newPasswordController.text.isEmpty ||
                  confirmPasswordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all password fields.')),
                );
                return;
              }
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New passwords do not match.')),
                );
                return;
              }

              // Show loading spinner
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              try {
                final userId = await AuthService.getUserId();
                if (userId == null) {
                  Navigator.pop(context); // Pop loading spinner
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User session expired. Please log in again.')),
                  );
                  return;
                }

                final result = await AuthService.changePassword(
                  userId: userId,
                  currentPassword: currentPasswordController.text,
                  newPassword: newPasswordController.text,
                );

                if (context.mounted) {
                  Navigator.pop(context); // Pop loading spinner
                }

                if (result['success'] == true) {
                  if (context.mounted) {
                    Navigator.pop(context); // Pop change password dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated successfully on server!')),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'] ?? 'Failed to update password.')),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Pop loading spinner
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog() {
    final nameController = TextEditingController(text: _userName);
    final isDark = Provider.of<ThemeViewModel>(context, listen: false).isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Edit Username',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name cannot be empty.')),
                );
                return;
              }

              // Show loading spinner
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              try {
                final userId = await AuthService.getUserId();
                if (userId == null) {
                  Navigator.pop(context); // Pop loading spinner
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User session expired. Please log in again.')),
                  );
                  return;
                }

                final result = await AuthService.updateName(
                  userId: userId,
                  name: newName,
                );

                if (context.mounted) {
                  Navigator.pop(context); // Pop loading spinner
                }

                if (result['success'] == true) {
                  if (context.mounted) {
                    setState(() {
                      _userName = newName;
                    });
                    Navigator.pop(context); // Pop edit name dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Username updated successfully!')),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'] ?? 'Failed to update username.')),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Pop loading spinner
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _darkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Help Center',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _darkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How can we help you today?',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Live Chat',
                    desc: '2 min wait time',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildContactCard(
                    icon: Icons.mail_outline_rounded,
                    title: 'Email Us',
                    desc: '24 hour response',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _darkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildFAQTile('How do I reschedule a booking?', 'You can go to the "My Bookings" page, click on your upcoming booking, and select "Reschedule" to pick a new date and time slot.'),
            _buildFAQTile('What is the cancellation policy?', 'Appointments can be cancelled free of charge up to 2 hours before the scheduled time slot.'),
            _buildFAQTile('How do I rate my barber?', 'Once your appointment is completed offline, you can rate and review your barber directly from the "My Bookings" screen.'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: _darkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQTile(String question, String answer) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        unselectedWidgetColor: _darkMode ? Colors.grey.shade400 : Colors.grey.shade600,
      ),
      child: ExpansionTile(
        iconColor: Theme.of(context).primaryColor,
        title: Text(
          question,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            color: _darkMode ? Colors.white : Colors.black87,
          ),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Text(
            answer,
            style: GoogleFonts.manrope(
              fontSize: 12.5,
              color: _darkMode ? Colors.grey.shade300 : Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _darkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Privacy Policy',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _darkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Last updated: May 31, 2026',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 24),
              _buildPolicySection('1. Information We Collect', 
                'We collect information you provide directly to us when creating an account, making a booking, or contacting customer support. This includes your name, email address, phone number, and booking histories.'),
              _buildPolicySection('2. How We Use Your Information', 
                'We use the collected information to schedule and manage your barber appointments, process payments, send confirmation notifications, and improve the BarberFlow application experience.'),
              _buildPolicySection('3. Information Sharing', 
                'BarberFlow does not sell or lease your personal data. We only share information with salons and barbers with whom you make bookings to ensure they are prepared for your appointment.'),
              _buildPolicySection('4. Security of Data', 
                'We utilize industry-standard security protocols to encrypt and safeguard your personal information and booking details against unauthorized access or breaches.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection(String heading, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14.5,
              color: _darkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: _darkMode ? Colors.grey.shade300 : Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutBarberFlowDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _darkMode ? const Color(0xFF1E1E1E) : Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.storefront_rounded, color: Theme.of(context).primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'BarberFlow',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: _darkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.cut, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'BarberFlow client-side app',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: _darkMode ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              'Version 2.4.0 (Stable)',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'BarberFlow is a premium appointment scheduling and salon management platform. Discover the best local barbers, pick real-time open slots, and get a fresh cut with zero waiting time.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: _darkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: _darkMode ? Colors.grey.shade800 : Colors.grey.shade200),
            const SizedBox(height: 8),
            Text(
              '© 2026 BarberFlow Inc. All rights reserved.',
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ignore: no_leading_underscores_for_local_identifiers
    final _darkMode = context.watch<ThemeViewModel>().isDarkMode;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: _darkMode ? const Color(0xFF121212) : Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Curve & User Profile Summary Card
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  height: 330,
                  width: double.infinity,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 190,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor,
                          primaryColor.withOpacity(0.85),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 110,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 48,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _darkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: _darkMode ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: _darkMode ? Colors.grey.shade900 : Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        // User Avatar
                        GestureDetector(
                          onTap: _isUploadingPic ? null : _pickAndUploadProfilePic,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: primaryColor, width: 2),
                                ),
                                child: _isUploadingPic
                                    ? SizedBox(
                                        width: 84,
                                        height: 84,
                                        child: Padding(
                                          padding: const EdgeInsets.all(24.0),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                          ),
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 42,
                                        backgroundColor: primaryColor.withOpacity(0.1),
                                        backgroundImage: _userProfilePic != null && _userProfilePic!.isNotEmpty
                                            ? NetworkImage(
                                                _userProfilePic!.startsWith('http')
                                                    ? _userProfilePic!
                                                    : '${AppConstants.backendUrl}$_userProfilePic',
                                              )
                                            : null,
                                        child: _userProfilePic == null || _userProfilePic!.isEmpty
                                            ? Text(
                                                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                              )
                                            : null,
                                      ),
                              ),
                              if (!_isUploadingPic)
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 32), // visually balances the edit icon for perfect centering
                            Text(
                              _userName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _darkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: _showEditNameDialog,
                              color: primaryColor,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userEmail,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: _darkMode ? Colors.grey.shade400 : Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Role / Membership Pill Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _userRole == 'admin' ? Icons.security : Icons.stars_rounded,
                                size: 14,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _userRole == 'admin' ? 'ADMINISTRATOR' : 'PREMIUM MEMBER',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Push content below stack overlap
            const SizedBox(height: 40),
 
            // Profile Sections List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Admin Panel (If user is Admin)
                  if (_userRole == 'admin') ...[
                    Text(
                      'Administrative Access',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _darkMode ? Colors.grey.shade400 : Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: _darkMode ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _darkMode ? Colors.grey.shade900 : primaryColor.withOpacity(0.15)),
                        boxShadow: [
                          BoxShadow(
                            color: _darkMode ? Colors.black.withOpacity(0.3) : primaryColor.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Icon(Icons.admin_panel_settings, color: primaryColor),
                        ),
                        title: Text(
                          'Go to Admin Panel',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: _darkMode ? Colors.white : primaryColor,
                          ),
                        ),
                        subtitle: Text(
                          'Manage bookings, salons & barbers',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: _darkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        trailing: Icon(Icons.chevron_right_rounded, color: primaryColor),
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const AdminMainScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
 
                  // Section: Account Settings
                  Text(
                    'Account Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _darkMode ? Colors.grey.shade400 : Colors.grey.shade500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionContainer([
                    _buildSettingsTile(
                      icon: Icons.lock_outline_rounded,
                      iconColor: Colors.blue.shade600,
                      title: 'Change Password',
                      onTap: _showChangePasswordDialog,
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.payment_outlined,
                      iconColor: Colors.teal.shade600,
                      title: 'Payment Methods',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.notifications_none_rounded,
                      iconColor: Colors.amber.shade700,
                      title: 'Push Notifications',
                      trailing: Switch(
                        value: _pushNotifications,
                        onChanged: (val) {
                          setState(() {
                            _pushNotifications = val;
                          });
                        },
                        activeColor: primaryColor,
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.dark_mode_outlined,
                      iconColor: Colors.deepPurple.shade600,
                      title: 'Dark Mode',
                      trailing: Switch(
                        value: _darkMode,
                        onChanged: (val) {
                          Provider.of<ThemeViewModel>(context, listen: false).toggleTheme(val);
                        },
                        activeColor: primaryColor,
                      ),
                    ),
                  ]),
 
                  const SizedBox(height: 28),
 
                  // Section: Preferences & Support
                  Text(
                    'Preferences & Support',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _darkMode ? Colors.grey.shade400 : Colors.grey.shade500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionContainer([
                    _buildSettingsTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: Colors.orange.shade600,
                      title: 'Help Center',
                      onTap: _showHelpCenterSheet,
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.shield_outlined,
                      iconColor: Colors.blueGrey.shade600,
                      title: 'Privacy Policy',
                      onTap: _showPrivacyPolicySheet,
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: Colors.indigo.shade600,
                      title: 'About BarberFlow',
                      onTap: _showAboutBarberFlowDialog,
                    ),
                  ]),
 
                  const SizedBox(height: 36),
 
                  // Section: Danger Zone / Actions
                  ElevatedButton(
                    onPressed: () async {
                      await AuthService.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      foregroundColor: Colors.red,
                      side: BorderSide(color: _darkMode ? Colors.grey.shade900 : const Color(0xFFFFCDD2)),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Log Out Account',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _darkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _darkMode ? Colors.grey.shade900 : Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _darkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.015),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
          color: _darkMode ? Colors.white : Colors.black87,
        ),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: _darkMode ? Colors.grey.shade600 : Colors.grey.shade400, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: _darkMode ? Colors.grey.shade800 : Colors.grey.shade50,
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
    );
  }
}
