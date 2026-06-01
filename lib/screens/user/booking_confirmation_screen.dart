import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_flow/screens/main_screen.dart';
import 'package:barber_flow/theme/responsive_layout.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> bookingDetails;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        automaticallyImplyLeading: false, // Prevents backing out to selection
      ),
      body: SafeArea(
        child: CenteredBox(
          maxWidth: 600,
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Success Icon
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
  
              // Title and Subtitle
              Text(
                'Booking Confirmed!',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your appointment has been successfully scheduled. We\'ve sent a confirmation email.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
  
              // Service Details Card
              Text(
                'Service Details',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2E2E2E) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.storefront, color: Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.grey, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookingDetails['salonName'] ?? 'The Gilded Razor',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bookingDetails['service'] ?? 'Classic Haircut',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${bookingDetails['barber']} • ${bookingDetails['date']}, ${bookingDetails['time']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
  
              // Summary List
              Text(
                'Summary',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSummaryRow(context, 'Salon', bookingDetails['salonName'] ?? 'The Gilded Razor'),
              _buildSummaryRow(context, 'Barber', bookingDetails['barber'] ?? 'Marcus Thorne'),
              _buildSummaryRow(context, 'Date & Time', '${bookingDetails['date']}, ${bookingDetails['time']}'),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Price',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${bookingDetails['price'] ?? '45.00'}',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
  
              // Primary Action
              ElevatedButton(
                onPressed: () {
                  // Navigate back to home and clear stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Back to Home'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MainScreen(initialIndex: 2),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('View My Bookings'),
              ),
            ],
          ),
        ),
      ),
     ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
