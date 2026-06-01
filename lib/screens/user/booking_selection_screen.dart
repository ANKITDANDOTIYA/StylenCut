import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_flow/screens/user/booking_confirmation_screen.dart';
import 'package:barber_flow/services/auth_service.dart';
import 'package:barber_flow/services/booking_service.dart';
import 'package:barber_flow/models/booking_model.dart';
import 'package:barber_flow/theme/responsive_layout.dart';
import '../../constants.dart';

class BookingSelectionScreen extends StatefulWidget {
  final Map<String, String> barber;
  final String salonName;
  final int salonId;
  final String? openingTime;
  final String? closingTime;

  const BookingSelectionScreen({
    super.key,
    required this.barber,
    required this.salonName,
    required this.salonId,
    this.openingTime,
    this.closingTime,
  });

  @override
  State<BookingSelectionScreen> createState() => _BookingSelectionScreenState();
}

class _BookingSelectionScreenState extends State<BookingSelectionScreen> {
  Color _getStatusColor(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'free') return const Color(0xFF4CAF50);
    if (s == 'with client') return const Color(0xFFFFB300);
    if (s == 'busy') return const Color(0xFFE53935);
    return const Color(0xFF4CAF50);
  }

  Color _getStatusTextColor(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'free') return const Color(0xFF2E7D32);
    if (s == 'with client') return const Color(0xFFE65100);
    if (s == 'busy') return const Color(0xFFC62828);
    return const Color(0xFF2E7D32);
  }

  int _selectedServiceIndex = 0;
  late DateTime _selectedDate;
  int _selectedTimeIndex = -1;

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

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  static const List<String> _weekdays = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  List<BookingModel> _existingBookings = [];
  bool _isLoadingBookings = true;
  List<String> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoadingBookings = true;
    });
    try {
      final list = await BookingService.fetchBookings(widget.salonId);
      setState(() {
        _existingBookings = list;
        _isLoadingBookings = false;
        _timeSlots = _generateTimeSlots();
        _selectedTimeIndex = _timeSlots.isNotEmpty ? 0 : -1;
      });
    } catch (e) {
      setState(() {
        _isLoadingBookings = false;
        _timeSlots = _generateTimeSlots();
        _selectedTimeIndex = _timeSlots.isNotEmpty ? 0 : -1;
      });
    }
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _timeSlots = _generateTimeSlots();
      _selectedTimeIndex = _timeSlots.isNotEmpty ? 0 : -1;
    });
  }

  void _onServiceChanged(int newIndex) {
    setState(() {
      _selectedServiceIndex = newIndex;
      _timeSlots = _generateTimeSlots();
      _selectedTimeIndex = _timeSlots.isNotEmpty ? 0 : -1;
    });
  }

  int _timeStringToMinutes(String timeStr) {
    if (timeStr.contains(',')) {
      timeStr = timeStr.split(',').last.trim();
    }
    timeStr = timeStr.trim();

    // 12-hour format e.g. "10:30 AM"
    final amPmRegex = RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false);
    final amPmMatch = amPmRegex.firstMatch(timeStr);
    if (amPmMatch != null) {
      int hour = int.parse(amPmMatch.group(1)!);
      int minute = int.parse(amPmMatch.group(2)!);
      String period = amPmMatch.group(3)!.toUpperCase();
      if (period == 'PM' && hour < 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }
      return hour * 60 + minute;
    }

    // 24-hour format e.g. "09:00"
    final time24Regex = RegExp(r'(\d+):(\d+)');
    final match24 = time24Regex.firstMatch(timeStr);
    if (match24 != null) {
      int hour = int.parse(match24.group(1)!);
      int minute = int.parse(match24.group(2)!);
      return hour * 60 + minute;
    }

    return 540; // Default to 9:00 AM (540 mins) if unparseable
  }

  String _minutesToTimeString(int totalMinutes) {
    int hour = totalMinutes ~/ 60;
    int minute = totalMinutes % 60;
    String period = 'AM';
    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) {
        hour -= 12;
      }
    } else if (hour == 0) {
      hour = 12;
    }
    String hourStr = hour.toString().padLeft(2, '0');
    String minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $period';
  }

  int _getSelectedServiceDuration() {
    final durationStr = services[_selectedServiceIndex]['duration'] as String;
    final cleanStr = durationStr.replaceAll(RegExp(r'\D'), '');
    return int.tryParse(cleanStr) ?? 30; // Default to 30 mins
  }

  List<String> _generateTimeSlots() {
    final List<String> slots = [];
    final int openingMin = _timeStringToMinutes(widget.openingTime ?? '09:00 AM');
    final int closingMin = _timeStringToMinutes(widget.closingTime ?? '09:00 PM');
    final int serviceDuration = _getSelectedServiceDuration();
    const int slotInterval = 30; // standard 30 min intervals

    final now = DateTime.now();
    final bool isSelectedDateToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    final int currentMinutes = now.hour * 60 + now.minute;

    for (int start = openingMin; start + serviceDuration <= closingMin; start += slotInterval) {
      final int end = start + serviceDuration;

      // 1. Lunch Break Constraint: 12:00 PM to 02:00 PM (720 to 840 minutes)
      // Overlaps if start < 840 and end > 720
      if (start < 840 && end > 720) {
        continue;
      }

      // 2. Today's Future Time Constraint: if selected date is today, slot must be in the future (with 10-minute buffer)
      if (isSelectedDateToday && start <= currentMinutes + 10) {
        continue;
      }

      // 3. Barber Overlap Constraint: check against existing bookings on this date for this barber
      bool hasOverlap = false;
      final selectedBarberName = widget.barber['name']?.trim().toLowerCase() ?? '';
      final String selectedDateYYYYMMDD =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      for (final booking in _existingBookings) {
        if (booking.barberName.trim().toLowerCase() != selectedBarberName) {
          continue;
        }

        final String statusLower = booking.status.trim().toLowerCase();
        if (statusLower == 'cancelled' || statusLower == 'completed') {
          continue;
        }

        bool dateMatches = false;
        if (booking.bookingDate != null && booking.bookingDate!.isNotEmpty) {
          dateMatches = (booking.bookingDate!.trim() == selectedDateYYYYMMDD);
        } else {
          final timeStr = booking.time.toLowerCase();
          final String monthStr = _months[_selectedDate.month - 1].toLowerCase();
          final String dayStr = _selectedDate.day.toString();
          dateMatches = timeStr.contains(selectedDateYYYYMMDD) ||
                        (timeStr.contains(monthStr) && timeStr.contains(dayStr));
        }

        if (!dateMatches) {
          continue;
        }

        final int existStart = _timeStringToMinutes(booking.time);
        int existDuration = 30;
        final sName = booking.serviceName.toLowerCase();
        if (sName.contains('haircut')) {
          existDuration = 30;
        } else if (sName.contains('beard')) {
          existDuration = 20;
        } else if (sName.contains('full')) {
          existDuration = 60;
        }
        final int existEnd = existStart + existDuration;

        if (start < existEnd && end > existStart) {
          hasOverlap = true;
          break;
        }
      }

      if (hasOverlap) {
        continue;
      }

      slots.add(_minutesToTimeString(start));
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CenteredBox(
        maxWidth: 750,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning Banner if Barber is not Free
                  if (widget.barber['status']?.toLowerCase() != 'free') ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF332701) : const Color(0xFFFFF3CD), // Warm amber background
                        border: Border.all(color: isDark ? const Color(0xFF664D03) : const Color(0xFFFFEBAA), width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFF856404), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This barber is currently ${widget.barber['status'] ?? 'Unavailable'}. You cannot book them at the moment.',
                              style: GoogleFonts.poppins(
                                color: isDark ? const Color(0xFFFFE69C) : const Color(0xFF856404),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Barber Info
                  Row(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 60,
                          height: 60,
                          color: isDark ? const Color(0xFF2E2E2E) : Colors.grey.shade200,
                          child: widget.barber['profile_pic'] != null && widget.barber['profile_pic']!.isNotEmpty
                              ? Image.network(
                                  widget.barber['profile_pic']!.startsWith('http')
                                      ? widget.barber['profile_pic']!
                                      : '${AppConstants.backendUrl}${widget.barber['profile_pic']}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.grey),
                                )
                              : const Icon(Icons.person, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
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
                              '${widget.salonName} • ${widget.barber['experience'] ?? '0'} yrs exp',
                              style: GoogleFonts.poppins(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, color: Theme.of(context).primaryColor, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${widget.barber['rating'] ?? '5.0'} (${widget.barber['cuttings_count'] ?? '0'} completed cuts)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(widget.barber['status'] ?? 'Free').withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(widget.barber['status'] ?? 'Free'),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        widget.barber['status'] ?? 'Free',
                                        style: GoogleFonts.poppins(
                                          color: _getStatusTextColor(widget.barber['status'] ?? 'Free'),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.barber['details'] != null && widget.barber['details']!.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      widget.barber['details']!,
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade500,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
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
                      onTap: () => _onServiceChanged(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Theme.of(context).primaryColor : (isDark ? Colors.grey.shade900 : Colors.grey.shade200),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.08) : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
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
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Date',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_month, color: Theme.of(context).primaryColor, size: 28),
                          onPressed: () async {
                            final selected = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: isDark
                                        ? ColorScheme.dark(
                                            primary: Theme.of(context).primaryColor,
                                            onPrimary: Colors.white,
                                            onSurface: Colors.white70,
                                          )
                                        : ColorScheme.light(
                                            primary: Theme.of(context).primaryColor,
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black87,
                                          ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (selected != null) {
                              _onDateChanged(selected);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 30,
                        itemBuilder: (context, index) {
                          final date = DateTime.now().add(Duration(days: index));
                          final isSelected =
                              _selectedDate.year == date.year &&
                              _selectedDate.month == date.month &&
                              _selectedDate.day == date.day;

                          final dayName = _weekdays[date.weekday % 7];
                          final dayNumber = date.day.toString();
                          final monthName = _months[date.month - 1];

                          return GestureDetector(
                            onTap: () => _onDateChanged(date),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Theme.of(context).primaryColor : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                                border: Border.all(
                                  color: isSelected ? Theme.of(context).primaryColor : (isDark ? Colors.grey.shade900 : Colors.grey.shade200),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    monthName,
                                    style: GoogleFonts.poppins(
                                      color: isSelected ? Colors.white70 : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dayNumber,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dayName,
                                    style: GoogleFonts.poppins(
                                      color: isSelected ? Colors.white70 : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
                    _isLoadingBookings
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _timeSlots.isEmpty
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.event_busy, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, size: 40),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No Slots Available',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Try selecting another date or service.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: List.generate(_timeSlots.length, (index) {
                                  final isSelected = _selectedTimeIndex == index;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedTimeIndex = index;
                                      });
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width < 600
                                          ? (MediaQuery.of(context).size.width - 72) / 3
                                          : 110,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Theme.of(context).primaryColor : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                                        border: Border.all(
                                          color: isSelected ? Theme.of(context).primaryColor : (isDark ? Colors.grey.shade900 : Colors.grey.shade200),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _timeSlots[index],
                                        style: GoogleFonts.poppins(
                                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
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
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Any special requests for the barber...',
                        hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDark ? BorderSide(color: Colors.grey.shade900) : BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDark ? BorderSide(color: Colors.grey.shade900) : BorderSide.none),
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
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: Border(
                  top: BorderSide(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200),
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
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '\$${services[_selectedServiceIndex]['price'].toInt()}.00',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade200,
                            disabledForegroundColor: Colors.grey.shade500,
                          ),
                          onPressed: (widget.barber['status']?.toLowerCase() == 'free' && _selectedTimeIndex != -1)
                              ? () async {
                                  // Show loading spinner
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(child: CircularProgressIndicator()),
                                  );
            
                                  try {
                                    final customerName = await AuthService.getUserName();
                                    final String selectedDateYYYYMMDD =
                                        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
                                    final dateStr = '${_months[_selectedDate.month - 1]} ${_selectedDate.day}';
                                    final timeStr = _timeSlots[_selectedTimeIndex];
                                    final serviceTitle = services[_selectedServiceIndex]['title'];
                                    final priceVal = (services[_selectedServiceIndex]['price'] as num).toDouble();
                                    final barberNameVal = widget.barber['name'] ?? 'Unknown Barber';
            
                                    final newBooking = BookingModel(
                                      id: '', // Backend will assign ID
                                      salonId: widget.salonId,
                                      customerName: customerName,
                                      serviceName: serviceTitle,
                                      time: '$selectedDateYYYYMMDD, $timeStr', // formatted date and time for display
                                      bookingDate: selectedDateYYYYMMDD, // pass normalized date
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
                                }
                              : null,
                          child: Text(
                            widget.barber['status']?.toLowerCase() == 'free'
                                ? (_selectedTimeIndex == -1 ? 'Select Time Slot' : 'Book Now')
                                : 'Barber is ${widget.barber['status'] ?? 'Unavailable'}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
     ),
    );
  }
}
