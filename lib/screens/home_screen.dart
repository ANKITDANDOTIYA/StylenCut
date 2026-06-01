import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:barber_flow/screens/salon_details_screen.dart';
import 'package:barber_flow/viewmodels/salon_viewmodel.dart';
import 'package:barber_flow/theme/responsive_layout.dart';
import 'package:barber_flow/models/salon.dart';
import '../constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalonViewModel>().fetchSalons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CenteredBox(
          maxWidth: 1100,
          padding: EdgeInsets.zero,
          child: Consumer<SalonViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading && viewModel.salons.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final salons = viewModel.salons;

              return CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find your next look',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Search Bar
                          TextField(
                            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Search for salons, services...',
                              hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade500 : Colors.grey.shade400),
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              filled: true,
                              fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Filters
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('OPEN NOW', isSelected: true, context: context),
                                const SizedBox(width: 8),
                                _buildFilterChip('Top Rated', context: context),
                                const SizedBox(width: 8),
                                _buildFilterChip('Nearest', context: context),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Section Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'Premium Salons',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                'View All',
                                style: GoogleFonts.poppins(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Salons List
                  if (salons.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'No salons found.',
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      sliver: MediaQuery.of(context).size.width >= 650
                          ? SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: MediaQuery.of(context).size.width >= 950 ? 3 : 2,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                mainAxisExtent: 310,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final salon = salons[index];
                                  return _buildSalonCard(context, salon);
                                },
                                childCount: salons.length,
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final salon = salons[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20.0),
                                    child: _buildSalonCard(context, salon),
                                  );
                                },
                                childCount: salons.length,
                              ),
                            ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSalonCard(BuildContext context, Salon salon) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SalonDetailsScreen(salon: salon),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Image Preview
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(
                    salon.thumbnailPic != null && salon.thumbnailPic!.isNotEmpty
                        ? (salon.thumbnailPic!.startsWith('http')
                            ? salon.thumbnailPic!
                            : '${AppConstants.backendUrl}${salon.thumbnailPic}')
                        : 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80',
                  ),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    debugPrint('Error loading salon image: $exception');
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          salon.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            salon.rating.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.near_me, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          salon.address ?? 'Address not available',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          salon.openingTime != null && salon.closingTime != null
                              ? '${salon.openingTime} - ${salon.closingTime}'
                              : 'Hours not set',
                          style: GoogleFonts.poppins(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (salon.isOpen) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'OPEN',
                            style: GoogleFonts.poppins(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
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
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false, required BuildContext context}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Theme.of(context).primaryColor : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
