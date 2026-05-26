import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_flow/screens/user/booking_confirmation_screen.dart';
import 'package:barber_flow/services/auth_service.dart';
import 'package:barber_flow/services/booking_service.dart';
import 'package:barber_flow/models/booking_model.dart';

class BookingSelectionScreen extends StatefulWidget {
  final Map<String, String> barber;
  final String salonName;
  final int salonId;

  const BookingSelectionScreen({
    super.key,
    required this.barber,
    required this.salonName,
    required this.salonId,
  });

  @override
  State<BookingSelectionScreen> createState() => _BookingSelectionScreenState();
}

class _BookingSelectionScreenState extends State<BookingSelectionScreen> {
  int _selectedServiceIndex = 0;
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = 0;

  final List<Map<String, dynamic>> services = [
    {
      'title': 'Classic Haircut',
      'duration': '30 mins',
      'desc': 'Professional cut & style',
      'price': 30.0,
    },
    {
      'title': 'Beard Trim',
      'duration': '20 mins',
      'desc': 'Shape, trim & hot towel',
      'price': 20.0,
    },
    {
      'title': 'Full Service',
      'duration': '60 mins',
      'desc': 'Haircut, beard & facial',
      'price': 45.0,
    },
  ];

  final List<Map<String, String>> dates = [
    {'day': 'Sat', 'date': '12', 'month': 'Oct'},
    {'day': 'Sun', 'date': '13', 'month': 'Oct'},
    {'day': 'Mon', 'date': '14', 'month': 'Oct'},
    {'day': 'Tue', 'date': '15', 'month': 'Oct'},
    {'day': 'Wed', 'date': '16', 'month': 'Oct'},
  ];

  final List<String> times = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '01:00 PM',
    '02:30 PM',
    '04:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barber Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.barber['name']!,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.salonName,
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, color: Theme.of(context).primaryColor, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '4.9 (120+ reviews)',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Select Service
                  Text(
                    'Select Service',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(services.length, (index) {
                    final service = services[index];
                    final isSelected = _selectedServiceIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedServiceIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['title'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${service['duration']} • ${service['desc']}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '\$${service['price'].toInt()}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),

                  // Select Date
                  Text(
                    'Select Date',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(dates.length, (index) {
                        final date = dates[index];
                        final isSelected = _selectedDateIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDateIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                              border: Border.all(
                                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  date['month']!,
                                  style: GoogleFonts.poppins(
                                    color: isSelected ? Colors.white70 : Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date['date']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date['day']!,
                                  style: GoogleFonts.poppins(
                                    color: isSelected ? Colors.white70 : Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Select Time
                  Text(
                    'Select Time',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(times.length, (index) {
                      final isSelected = _selectedTimeIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTimeIndex = index;
                          });
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 48 - 24) / 3,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                            border: Border.all(
                              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            times[index],
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // Special Notes
                  Text(
                    'Special Notes',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Any special requests for the barber...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Bottom Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Price',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '\$${services[_selectedServiceIndex]['price'].toInt()}.00',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          // Show loading spinner
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator()),
                          );
    
                          try {
                            final customerName = await AuthService.getUserName();
                            final dateStr = '${dates[_selectedDateIndex]['month']} ${dates[_selectedDateIndex]['date']}';
                            final timeStr = times[_selectedTimeIndex];
                            final serviceTitle = services[_selectedServiceIndex]['title'];
                            final priceVal = (services[_selectedServiceIndex]['price'] as num).toDouble();
                            final barberNameVal = widget.barber['name'] ?? 'Unknown Barber';
    
                            final newBooking = BookingModel(
                              id: '', // Backend will assign ID
                              customerName: customerName,
                              serviceName: serviceTitle,
                              time: '$dateStr, $timeStr',
                              price: priceVal,
                              barberName: barberNameVal,
                            );
    
                            final success = await BookingService.createBooking(widget.salonId, newBooking);
    
                            if (context.mounted) {
                              Navigator.pop(context); // Dismiss loading spinner
                            }
    
                            if (success) {
                              final details = {
                                'salonName': widget.salonName,
                                'barber': barberNameVal,
                                'service': serviceTitle,
                                'price': priceVal.toStringAsFixed(2),
                                'date': dateStr,
                                'time': timeStr,
                              };
    
                              if (context.mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BookingConfirmationScreen(
                                      bookingDetails: details,
                                    ),
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to book appointment. Please try again.')),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context); // Dismiss loading if it was open
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('An error occurred: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('Book Now'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
