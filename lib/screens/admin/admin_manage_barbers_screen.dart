import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminManageBarbersScreen extends StatelessWidget {
  const AdminManageBarbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final barbers = [
      {
        'name': 'Marcus Thorne',
        'role': 'Master Barber',
        'experience': '10+ years',
      },
      {
        'name': 'Elias Thorne',
        'role': 'Senior Barber',
        'experience': '8 years',
      },
      {
        'name': 'Victor Vance',
        'role': 'Barber',
        'experience': '5 years',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Manage Barbers',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add Barber logic
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: barbers.length,
        itemBuilder: (context, index) {
          final barber = barbers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.person, color: Colors.grey, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barber['name']!,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${barber['role']}, ${barber['experience']}',
                        style: GoogleFonts.manrope(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Edit or Remove logic
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
