import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_flow/services/auth_service.dart';
import 'package:barber_flow/services/salon_service.dart';

class RateReviewScreen extends StatefulWidget {
  final Map<String, dynamic> booking;

  const RateReviewScreen({super.key, required this.booking});

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  int _salonRating = 0;
  int _barberRating = 0;
  bool _isSubmitting = false;

  final TextEditingController _salonCommentController = TextEditingController();
  final TextEditingController _barberCommentController = TextEditingController();

  @override
  void dispose() {
    _salonCommentController.dispose();
    _barberCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Rate & Review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Booking Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.booking['salon'] ?? 'The Gilded Razor',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Barber: ${widget.booking['barber']}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        widget.booking['date'] ?? 'Oct 12, 2023',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Rate Salon
            Text(
              'Rate the Salon',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _salonRating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _salonRating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: index < _salonRating ? Colors.amber : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _salonCommentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your experience at the salon...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Rate Barber
            Text(
              'Rate your Barber',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _barberRating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _barberRating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: index < _barberRating ? Colors.amber : Colors.grey.shade300,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _barberCommentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'How was your haircut?',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Submit Action
            ElevatedButton(
              onPressed: _isSubmitting || _salonRating == 0 || _barberRating == 0
                  ? null
                  : () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);

                      setState(() {
                        _isSubmitting = true;
                      });
    
                      try {
                        final customerName = await AuthService.getUserName();
                        final salonId = widget.booking['salonId'] ?? 0;
                        final barberName = widget.booking['barber'] ?? 'Unknown Barber';
    
                        if (salonId == 0) {
                          throw Exception("Invalid Salon ID");
                        }
    
                        final success = await SalonService.submitReview(
                          salonId: salonId,
                          customerName: customerName,
                          barberName: barberName,
                          salonRating: _salonRating,
                          barberRating: _barberRating,
                          salonReview: _salonCommentController.text,
                          barberReview: _barberCommentController.text,
                        );
    
                        if (success) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text('Review submitted successfully!')),
                          );
                          navigator.pop();
                        } else {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text('Failed to submit review. Please try again.')),
                          );
                        }
                      } catch (e) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text('An error occurred: $e')),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isSubmitting = false;
                          });
                        }
                      }
                    },
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
