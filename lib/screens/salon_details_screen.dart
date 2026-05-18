import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:barber_flow/screens/user/booking_selection_screen.dart';
import 'package:barber_flow/models/salon.dart';
import 'package:barber_flow/viewmodels/salon_viewmodel.dart';

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

  @override
  void initState() {
    super.initState();
    _barbersFuture = Provider.of<SalonViewModel>(context, listen: false)
        .fetchBarbers(widget.salon.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Salon Cover Image Header
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                image: widget.salon.thumbnailPic != null && widget.salon.thumbnailPic!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(
                          widget.salon.thumbnailPic!.startsWith('http')
                              ? widget.salon.thumbnailPic!
                              : 'http://192.168.1.15:5000${widget.salon.thumbnailPic}',
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.salon.thumbnailPic == null || widget.salon.thumbnailPic!.isEmpty
                  ? const Center(
                      child: Icon(Icons.storefront, size: 80, color: Colors.grey),
                    )
                  : null,
            ),
            
            // Salon Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.salon.name,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Theme.of(context).primaryColor, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.salon.rating.toStringAsFixed(1)} (128 reviews)',
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

                  // Barbers List (FutureBuilder)
                  FutureBuilder<List<dynamic>>(
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
                            'role': item['role'] ?? 'Barber',
                            'image': 'assets/images/barber1.jpg',
                          });
                        }
                      } else {
                        // Fallback to static mock barbers so newly created salons still have options
                        displayBarbers.addAll([
                          {
                            'id': 'mock1',
                            'name': 'Marcus Thorne',
                            'role': 'Master Barber • Beard Specialist',
                            'image': 'assets/images/barber1.jpg',
                          },
                          {
                            'id': 'mock2',
                            'name': 'Julian Vance',
                            'role': 'Senior Stylist • Hair Tattoo',
                            'image': 'assets/images/barber2.jpg',
                          },
                          {
                            'id': 'mock3',
                            'name': 'Arthur Morgan',
                            'role': 'Traditional Cuts • Hot Shave',
                            'image': 'assets/images/barber3.jpg',
                          },
                        ]);
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayBarbers.length,
                        itemBuilder: (context, index) {
                          final barber = displayBarbers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey.shade200,
                                  child: const Icon(Icons.person, color: Colors.grey),
                                ),
                                title: Text(
                                  barber['name']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    barber['role']!,
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => BookingSelectionScreen(
                                          barber: barber,
                                          salonName: widget.salon.name,
                                          salonId: widget.salon.id,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                  ),
                                  child: const Text('Book'),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
