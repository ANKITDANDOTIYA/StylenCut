// import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/salon.dart';
import '../../viewmodels/salon_viewmodel.dart';
import '../../constants.dart';

class AdminEditSalonScreen extends StatefulWidget {
  final Salon salon;

  const AdminEditSalonScreen({super.key, required this.salon});

  @override
  State<AdminEditSalonScreen> createState() => _AdminEditSalonScreenState();
}

class _AdminEditSalonScreenState extends State<AdminEditSalonScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _openingTimeController;
  late TextEditingController _closingTimeController;
  
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.salon.name);
    _addressController = TextEditingController(text: widget.salon.address ?? '');
    _phoneController = TextEditingController(text: widget.salon.phoneNumber ?? '');
    _openingTimeController = TextEditingController(text: widget.salon.openingTime ?? '');
    _closingTimeController = TextEditingController(text: widget.salon.closingTime ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    super.dispose();
  }

  String? _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    // Resolve relative uploads folder endpoint relative to backend server
    return '${AppConstants.backendUrl}$path';
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

  Future<void> _pickImage() async {
    try {
      final source = await _showImageSourcePicker();
      if (source == null) return;

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = image.name;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _saveSalon() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<SalonViewModel>(context, listen: false);
      
      String? thumbnailPath = widget.salon.thumbnailPic;

      // Upload image first if a new one was selected using raw bytes
      if (_selectedImageBytes != null) {
        final uploadedUrl = await viewModel.uploadSalonThumbnail(null, bytes: _selectedImageBytes, filename: _selectedImageName);
        if (uploadedUrl == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload salon image. Please try again.')),
            );
          }
          return;
        }
        thumbnailPath = uploadedUrl;
      }
      
      final updated = await viewModel.updateSalon(
        widget.salon.id,
        widget.salon.ownerId,
        _nameController.text,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        openingTime: _openingTimeController.text.isNotEmpty ? _openingTimeController.text : null,
        closingTime: _closingTimeController.text.isNotEmpty ? _closingTimeController.text : null,
        thumbnailPic: thumbnailPath,
      );

      if (updated != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salon updated successfully!')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update salon.')),
        );
      }
    }
  }

  Widget _buildImagePreview() {
    if (_selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
      );
    }
    
    final existingUrl = _resolveImageUrl(widget.salon.thumbnailPic);
    if (existingUrl != null) {
      return Image.network(
        existingUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 48, color: isDark ? Colors.white30 : Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Select Salon Thumbnail',
            style: GoogleFonts.manrope(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap to browse gallery',
            style: GoogleFonts.manrope(
              color: isDark ? Colors.white30 : Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
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
          'Edit Salon Details',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: Consumer<SalonViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Premium Image Picker Card
                  Text(
                    'Salon Cover Image',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: _buildImagePreview(),
                            ),
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildTextField(
                    controller: _nameController,
                    label: 'Salon Name',
                    icon: Icons.storefront,
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _openingTimeController,
                          label: 'Opening Time',
                          icon: Icons.access_time,
                          hint: '09:00',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _closingTimeController,
                          label: 'Closing Time',
                          icon: Icons.access_time_filled,
                          hint: '20:00',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveSalon,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.manrope(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700),
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.grey.shade400),
        prefixIcon: Icon(icon, color: isDark ? Colors.white54 : Colors.grey.shade600),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
        ),
      ),
    );
  }
}
