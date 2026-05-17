import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/salon_viewmodel.dart';

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
    if (viewModel.salons.isNotEmpty) {
      _barbersFuture = viewModel.fetchBarbers(viewModel.salons.first.id);
    } else {
      _barbersFuture = Future.value([]);
    }
  }

  void _showAddBarberDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

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

                if (name.isEmpty || email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                final viewModel = Provider.of<SalonViewModel>(context, listen: false);
                if (viewModel.salons.isNotEmpty) {
                  final success = await viewModel.createBarber(
                    viewModel.salons.first.id,
                    name,
                    email,
                    password,
                  );

                  if (success) {
                    if (context.mounted) {
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
                      child: const Icon(Icons.person, color: Colors.grey, size: 30),
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
                          const SizedBox(height: 4),
                          Text(
                            barber['role'] ?? 'Barber',
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
          );
        },
      ),
    );
  }
}
