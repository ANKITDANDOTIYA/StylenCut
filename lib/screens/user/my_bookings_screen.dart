import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_flow/models/booking_model.dart';
import 'package:barber_flow/services/booking_service.dart';
import 'package:barber_flow/services/auth_service.dart';
import 'package:barber_flow/screens/user/rate_review_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final name = await AuthService.getUserName();
      final bookings = await BookingService.fetchCustomerBookings(name);
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBookings,
              child: _bookings.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey.shade100,
                                child: Icon(Icons.calendar_today, size: 40, color: Colors.grey.shade400),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No Bookings Yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Book a slot at a salon to see it here!',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      itemCount: _bookings.length,
                      itemBuilder: (context, index) {
                        final booking = _bookings[index];
                        final isCompleted = booking.status == 'Completed';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    booking.time,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isCompleted ? Colors.green.shade50 : Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isCompleted ? 'Completed' : 'Upcoming',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                booking.serviceName,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                booking.salonName.isNotEmpty ? booking.salonName : 'Premium Barber Shop',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey.shade100,
                                        child: const Icon(Icons.person, color: Colors.grey, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Barber',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                          Text(
                                            booking.barberName,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (isCompleted)
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => RateReviewScreen(
                                              booking: {
                                                'salon': booking.salonName.isNotEmpty ? booking.salonName : 'Premium Barber Shop',
                                                'barber': booking.barberName,
                                                'date': booking.time,
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Rate',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
