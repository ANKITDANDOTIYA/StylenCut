import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/salon_viewmodel.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../constants.dart';

class AdminManageBarbersScreen extends StatefulWidget {
  const AdminManageBarbersScreen({super.key});

  @override
  State<AdminManageBarbersScreen> createState() => _AdminManageBarbersScreenState();
}

class _AdminManageBarbersScreenState extends State<AdminManageBarbersScreen> {
  late Future<List<dynamic>> _barbersFuture;

  @override
  void initState() {
    super.initState();
    _fetchBarbers();
  }

  void _fetchBarbers() {
    final viewModel = Provider.of<SalonViewModel>(context, listen: false);
    if (viewModel.adminSalon != null) {
      _barbersFuture = viewModel.fetchBarbers(viewModel.adminSalon!.id);
    } else {
      _barbersFuture = Future.value([]);
    }
  }

  void _showAddBarberDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final experienceController = TextEditingController();
    final profilePicController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Add New Barber',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: experienceController,
                  decoration: const InputDecoration(labelText: 'Experience (years)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: profilePicController,
                  decoration: const InputDecoration(labelText: 'Profile Picture URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final password = passwordController.text.trim();
                final expText = experienceController.text.trim();
                final profilePic = profilePicController.text.trim();

                if (name.isEmpty || email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final expVal = int.tryParse(expText);

                final viewModel = Provider.of<SalonViewModel>(context, listen: false);
                if (viewModel.adminSalon != null) {
                  final success = await viewModel.createBarber(
                    viewModel.adminSalon!.id,
                    name,
                    email,
                    password,
                    experience: expVal,
                    profilePic: profilePic.isEmpty ? null : profilePic,
                  );

                  if (success) {
                    if (context.mounted) {
                      // Dynamically sync AdminViewModel statistics and barbers lists
                      Provider.of<AdminViewModel>(context, listen: false)
                          .initializeSalon(viewModel.adminSalon!.id);
                      
                      Navigator.pop(context);
                      setState(() {
                        _fetchBarbers(); // Refresh the list
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Barber added successfully')),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to add barber')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditBarberDialog(Map<String, dynamic> barber) {
    final nameController = TextEditingController(text: barber['name']);
    final emailController = TextEditingController(text: barber['email']);
    final experienceController = TextEditingController(text: barber['experience']?.toString() ?? '');
    final profilePicController = TextEditingController(text: barber['profile_pic'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Edit Barber Details',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: experienceController,
                  decoration: const InputDecoration(labelText: 'Experience (years)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: profilePicController,
                  decoration: const InputDecoration(labelText: 'Profile Picture URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final expText = experienceController.text.trim();
                final profilePic = profilePicController.text.trim();

                if (name.isEmpty || email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name and Email are required')),
                  );
                  return;
                }

                final expVal = int.tryParse(expText);

                final viewModel = Provider.of<SalonViewModel>(context, listen: false);
                if (viewModel.adminSalon != null) {
                  final barberId = int.tryParse(barber['id']?.toString() ?? '');
                  if (barberId == null) return;
                  
                  final success = await viewModel.updateBarber(
                    viewModel.adminSalon!.id,
                    barberId,
                    name,
                    email,
                    experience: expVal,
                    profilePic: profilePic.isEmpty ? null : profilePic,
                  );

                  if (success) {
                    if (context.mounted) {
                      // Dynamically sync AdminViewModel statistics and barbers lists
                      Provider.of<AdminViewModel>(context, listen: false)
                          .initializeSalon(viewModel.adminSalon!.id);
                      
                      Navigator.pop(context);
                      setState(() {
                        _fetchBarbers(); // Refresh the list
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Barber updated successfully')),
                      );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to update barber')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _showAddBarberDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _barbersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load barbers'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No barbers found. Add some!'));
          }

          final barbers = snapshot.data!;

          return ListView.builder(
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
                      backgroundImage: barber['profile_pic'] != null && barber['profile_pic'].toString().isNotEmpty
                          ? NetworkImage(
                              barber['profile_pic'].toString().startsWith('http')
                                  ? barber['profile_pic'].toString()
                                  : '${AppConstants.backendUrl}${barber['profile_pic']}',
                            )
                          : null,
                      child: barber['profile_pic'] == null || barber['profile_pic'].toString().isEmpty
                          ? const Icon(Icons.person, color: Colors.grey, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            barber['name'] ?? 'Unknown',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '${barber['experience'] ?? 0} yrs exp',
                                style: GoogleFonts.manrope(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                '${barber['rating'] ?? '5.0'}',
                                style: GoogleFonts.manrope(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${barber['cuttings_count'] ?? 0} cuts completed',
                                style: GoogleFonts.manrope(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        _showEditBarberDialog(barber);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
