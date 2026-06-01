import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:barber_flow/models/barber_model.dart';
import 'package:barber_flow/viewmodels/admin_viewmodel.dart';
import '../../constants.dart';

class AdminStatusModal extends StatelessWidget {
  final BarberModel barber;

  const AdminStatusModal({super.key, required this.barber});

  static void show(BuildContext context, BarberModel barber) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => AdminStatusModal(barber: barber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statuses = [
      {
        'status': BarberStatus.free,
        'title': 'Free',
        'subtitle': 'Ready for walk-ins',
        'icon': Icons.check_circle_outline,
      },
      {
        'status': BarberStatus.withClient,
        'title': 'With Client',
        'subtitle': 'Currently in service',
        'icon': Icons.content_cut,
      },
      {
        'status': BarberStatus.busy,
        'title': 'Break / Busy',
        'subtitle': 'Away from station',
        'icon': Icons.coffee,
      },
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.grey.shade200;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Update Status',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ClipOval(
                  child: Container(
                    width: 48,
                    height: 48,
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
                    child: barber.profilePic != null && barber.profilePic!.isNotEmpty
                        ? Image.network(
                            barber.profilePic!.startsWith('http')
                                ? barber.profilePic!
                                : '${AppConstants.backendUrl}${barber.profilePic}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: isDark ? Colors.white54 : Colors.grey),
                          )
                        : Icon(Icons.person, color: isDark ? Colors.white54 : Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      barber.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Master Barber',
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Current Status',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(statuses.length, (index) {
              final status = statuses[index];
              final statusEnum = status['status'] as BarberStatus;
              final isSelected = barber.status == statusEnum;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : cardColor,
                ),
                child: ListTile(
                  leading: Icon(
                    status['icon'] as IconData,
                    color: statusEnum.color,
                  ),
                  title: Text(
                    status['title'] as String,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    status['subtitle'] as String,
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                  onTap: () {
                    Provider.of<AdminViewModel>(context, listen: false).updateBarberStatus(barber.id, statusEnum);
                    Navigator.of(context).pop();
                  },
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
