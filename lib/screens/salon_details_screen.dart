import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:barber_flow/screens/user/booking_selection_screen.dart';
import 'package:barber_flow/models/salon.dart';
import 'package:barber_flow/viewmodels/salon_viewmodel.dart';
import 'package:barber_flow/theme/responsive_layout.dart';
import '../constants.dart';

class SalonDetailsScreen extends StatefulWidget {
  final Salon salon;

  const SalonDetailsScreen({
    super.key,
    required this.salon,
  });

  @override
  State<SalonDetailsScreen> createState() => _SalonDetailsScreenState();
}

class _SalonDetailsScreenState extends State<SalonDetailsScreen> {
  late Future<List<dynamic>> _barbersFuture;


  Color _getStatusTextColor(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'free') return const Color(0xFF2E7D32);
    if (s == 'with client') return const Color(0xFFE65100);
    if (s == 'busy') return const Color(0xFFC62828);
    return const Color(0xFF2E7D32);
  }

  @override
  void initState() {
    super.initState();
    _barbersFuture = Provider.of<SalonViewModel>(context, listen: false)
        .fetchBarbers(widget.salon.id);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      extendBodyBehindAppBar: isWide ? false : true,
      appBar: AppBar(
        backgroundColor: isWide ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white) : Colors.transparent,
        elevation: 0,
        title: isWide
            ? Text(
                widget.salon.name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                ),
              )
            : null,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: isWide ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: CenteredBox(
        maxWidth: 1100,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Salon Details Card (40% width)
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 250,
                      color: Colors.grey.shade300,
                      child: widget.salon.thumbnailPic != null && widget.salon.thumbnailPic!.isNotEmpty
                          ? Image.network(
                              widget.salon.thumbnailPic!.startsWith('http')
                                  ? widget.salon.thumbnailPic!
                                  : '${AppConstants.backendUrl}${widget.salon.thumbnailPic}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.storefront, size: 80, color: Colors.grey),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.storefront, size: 80, color: Colors.grey),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.salon.name,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildOpenStatusBadge(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.star, color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.salon.rating.toStringAsFixed(1)} (${widget.salon.reviewsCount} reviews)',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.near_me, color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '0.8 miles away • ${widget.salon.address ?? "Address not available"}',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        widget.salon.openingTime != null && widget.salon.closingTime != null
                            ? 'Hours: ${widget.salon.openingTime} - ${widget.salon.closingTime}'
                            : 'Hours not set',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 48),
            // Right Column: Barbers (60% width)
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Barbers',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBarbersList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Salon Cover Image Header
          Container(
            height: 300,
            color: Colors.grey.shade300,
            child: widget.salon.thumbnailPic != null && widget.salon.thumbnailPic!.isNotEmpty
                ? Image.network(
                    widget.salon.thumbnailPic!.startsWith('http')
                        ? widget.salon.thumbnailPic!
                        : '${AppConstants.backendUrl}${widget.salon.thumbnailPic}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.storefront, size: 80, color: Colors.grey),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.storefront, size: 80, color: Colors.grey),
                  ),
          ),
          
          // Salon Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.salon.name,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildOpenStatusBadge(),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.salon.rating.toStringAsFixed(1)} (${widget.salon.reviewsCount} reviews)',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '0.8 miles away',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Today's Barbers Section
                Text(
                  'Today\'s Barbers',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildBarbersList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.salon.isOpen ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: widget.salon.isOpen ? const Color(0xFFC8E6C9) : const Color(0xFFFFCDD2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.salon.isOpen ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.salon.isOpen ? 'OPEN' : 'CLOSED',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: widget.salon.isOpen ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarbersList() {
    return FutureBuilder<List<dynamic>>(
      future: _barbersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final dbBarbers = snapshot.data ?? [];
        final List<Map<String, String>> displayBarbers = [];
        
        if (dbBarbers.isNotEmpty) {
          for (var item in dbBarbers) {
            displayBarbers.add({
              'id': item['id']?.toString() ?? '',
              'name': item['name'] ?? 'Unknown',
              'role': item['experience'] != null ? '${item['experience']} yrs exp • Barber' : 'Barber',
              'experience': item['experience']?.toString() ?? '0',
              'rating': item['rating']?.toString() ?? '5.0',
              'cuttings_count': item['cuttings_count']?.toString() ?? '0',
              'profile_pic': item['profile_pic'] ?? '',
              'status': item['status'] ?? 'Free',
              'details': item['details'] ?? '',
              'image': 'assets/images/barber1.jpg',
            });
          }
        } else {
          // Fallback to static mock barbers
          displayBarbers.addAll([
            {
              'id': 'mock1',
              'name': 'Marcus Thorne',
              'role': '5 yrs exp • Master Barber • Beard Specialist',
              'experience': '5',
              'rating': '4.8',
              'cuttings_count': '120',
              'profile_pic': '',
              'status': 'Free',
              'details': 'Ready for appointments',
              'image': 'assets/images/barber1.jpg',
            },
            {
              'id': 'mock2',
              'name': 'Julian Vance',
              'role': '4 yrs exp • Senior Stylist • Hair Tattoo',
              'experience': '4',
              'rating': '4.7',
              'cuttings_count': '85',
              'profile_pic': '',
              'status': 'With Client',
              'details': 'Finishing a fresh fade',
              'image': 'assets/images/barber2.jpg',
            },
            {
              'id': 'mock3',
              'name': 'Arthur Morgan',
              'role': '8 yrs exp • Traditional Cuts • Hot Shave',
              'experience': '8',
              'rating': '4.9',
              'cuttings_count': '250',
              'profile_pic': '',
              'status': 'Busy',
              'details': 'On lunch break',
              'image': 'assets/images/barber3.jpg',
            },
          ]);
        }

        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayBarbers.length,
          itemBuilder: (context, index) {
            final barber = displayBarbers[index];
            final bool isFree = barber['status']?.toLowerCase() == 'free';

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.02),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1), width: 2),
                        ),
                        child: ClipOval(
                          child: Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey.shade100,
                            child: barber['profile_pic'] != null && barber['profile_pic']!.isNotEmpty
                                ? Image.network(
                                    barber['profile_pic']!.startsWith('http')
                                        ? barber['profile_pic']!
                                        : '${AppConstants.backendUrl}${barber['profile_pic']}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.grey),
                                  )
                                : const Icon(Icons.person, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              barber['name']!,
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              barber['role']!,
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  barber['rating'] ?? '5.0',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '(${barber['cuttings_count'] ?? '0'} cuts)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (barber['details'] != null && barber['details']!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                barber['details']!,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      isFree
                          ? ElevatedButton(
                              onPressed: widget.salon.isOpen
                                  ? () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => BookingSelectionScreen(
                                            barber: barber,
                                            salonName: widget.salon.name,
                                            salonId: widget.salon.id,
                                            openingTime: widget.salon.openingTime,
                                            closingTime: widget.salon.closingTime,
                                          ),
                                        ),
                                      );
                                    }
                                  : () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(Icons.info_outline, color: Colors.white),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Sorry, ${widget.salon.name} is currently closed.',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: const Color(0xFFE53935),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Book'),
                            )
                          : Text(
                              barber['status'] ?? 'Busy',
                              style: GoogleFonts.poppins(
                                color: _getStatusTextColor(barber['status'] ?? 'Busy'),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
