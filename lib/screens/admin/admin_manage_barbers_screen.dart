import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/salon_viewmodel.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../theme/responsive_layout.dart';
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

  Future<ImageSource?> _showImageSourcePicker() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Select Image Source',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFC19A6B)),
              title: Text(
                'Gallery / Laptop Files',
                style: GoogleFonts.manrope(color: isDark ? Colors.white70 : Colors.black87),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFC19A6B)),
              title: Text(
                'Take Photo (Camera)',
                style: GoogleFonts.manrope(color: isDark ? Colors.white70 : Colors.black87),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBarberDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final experienceController = TextEditingController();
    Uint8List? pickedImageBytes;
    String? pickedImageName;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Add New Barber',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        try {
                          final source = await _showImageSourcePicker();
                          if (source == null) return;
                          
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: source,
                            maxWidth: 512,
                            maxHeight: 512,
                            imageQuality: 85,
                          );
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setDialogState(() {
                              pickedImageBytes = bytes;
                              pickedImageName = image.name;
                            });
                          }
                        } catch (e) {
                          debugPrint('Error picking image: $e');
                        }
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ClipOval(
                            child: Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey.shade100,
                              child: pickedImageBytes != null
                                  ? Image.memory(pickedImageBytes!, fit: BoxFit.cover)
                                  : const Icon(Icons.person_add_alt_1_outlined, size: 36, color: Colors.grey),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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

                    if (name.isEmpty || email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields')),
                      );
                      return;
                    }

                    final expVal = int.tryParse(expText);

                    final viewModel = Provider.of<SalonViewModel>(context, listen: false);
                    if (viewModel.adminSalon != null) {
                      String? profilePicUrl;
                      if (pickedImageBytes != null) {
                        final uploadedUrl = await viewModel.uploadSalonThumbnail(null, bytes: pickedImageBytes, filename: pickedImageName);
                        profilePicUrl = uploadedUrl;
                      }

                      final success = await viewModel.createBarber(
                        viewModel.adminSalon!.id,
                        name,
                        email,
                        password,
                        experience: expVal,
                        profilePic: profilePicUrl,
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
      },
    );
  }

  void _showEditBarberDialog(Map<String, dynamic> barber) {
    final nameController = TextEditingController(text: barber['name']);
    final emailController = TextEditingController(text: barber['email']);
    final experienceController = TextEditingController(text: barber['experience']?.toString() ?? '');
    Uint8List? pickedImageBytes;
    String? pickedImageName;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Edit Barber Details',
                style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        try {
                          final source = await _showImageSourcePicker();
                          if (source == null) return;
                          
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: source,
                            maxWidth: 512,
                            maxHeight: 512,
                            imageQuality: 85,
                          );
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setDialogState(() {
                              pickedImageBytes = bytes;
                              pickedImageName = image.name;
                            });
                          }
                        } catch (e) {
                          debugPrint('Error picking image: $e');
                        }
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          ClipOval(
                            child: Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey.shade100,
                              child: pickedImageBytes != null
                                  ? Image.memory(pickedImageBytes!, fit: BoxFit.cover)
                                  : (barber['profile_pic'] != null && barber['profile_pic'].toString().isNotEmpty
                                      ? Image.network(
                                          barber['profile_pic'].toString().startsWith('http')
                                              ? barber['profile_pic'].toString()
                                              : '${AppConstants.backendUrl}${barber['profile_pic']}',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Icon(Icons.person_outline, size: 36, color: Colors.grey.shade400),
                                        )
                                      : Icon(Icons.person_outline, size: 36, color: Colors.grey.shade400)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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

                      String? profilePicUrl = barber['profile_pic'];
                      if (pickedImageBytes != null) {
                        final uploadedUrl = await viewModel.uploadSalonThumbnail(null, bytes: pickedImageBytes, filename: pickedImageName);
                        profilePicUrl = uploadedUrl;
                      }
                      
                      final success = await viewModel.updateBarber(
                        viewModel.adminSalon!.id,
                        barberId,
                        name,
                        email,
                        experience: expVal,
                        profilePic: profilePicUrl,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Barber Directory',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddBarberDialog,
          ),
        ],
      ),
      body: CenteredBox(
        maxWidth: 900,
        padding: EdgeInsets.zero,
        child: FutureBuilder<List<dynamic>>(
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
            final isWide = MediaQuery.of(context).size.width >= 650;

            return isWide
                ? GridView.builder(
                    padding: const EdgeInsets.all(24.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width >= 950 ? 3 : 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      mainAxisExtent: 104,
                    ),
                    itemCount: barbers.length,
                    itemBuilder: (context, index) {
                      final barber = barbers[index];
                      return _buildBarberItem(context, barber, cardColor, borderColor, true);
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: barbers.length,
                    itemBuilder: (context, index) {
                      final barber = barbers[index];
                      return _buildBarberItem(context, barber, cardColor, borderColor, false);
                    },
                  );
          },
        ),
      ),
    );
  }

  Widget _buildBarberItem(BuildContext context, dynamic barber, Color cardColor, Color borderColor, bool isGrid) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
            backgroundImage: barber['profile_pic'] != null && barber['profile_pic'].toString().isNotEmpty
                ? NetworkImage(
                    barber['profile_pic'].toString().startsWith('http')
                        ? barber['profile_pic'].toString()
                        : '${AppConstants.backendUrl}${barber['profile_pic']}',
                  )
                : null,
            child: barber['profile_pic'] == null || barber['profile_pic'].toString().isEmpty
                ? Icon(Icons.person, color: isDark ? Colors.white54 : Colors.grey, size: 28)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  barber['name'] ?? 'Unknown',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${barber['experience'] ?? 0} yrs exp',
                      style: GoogleFonts.manrope(
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white24 : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.star, color: Colors.amber, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      '${barber['rating'] ?? '5.0'}',
                      style: GoogleFonts.manrope(
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${barber['cuttings_count'] ?? 0} cuts completed',
                  style: GoogleFonts.manrope(
                    color: isDark ? Colors.white70 : Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () {
              _showEditBarberDialog(barber);
            },
          ),
        ],
      ),
    );
  }
}
