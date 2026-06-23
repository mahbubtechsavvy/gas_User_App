import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/services/profile_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const ProfileEditScreen({super.key, required this.profile});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _fatherNameController;
  late TextEditingController _villageController;
  late TextEditingController _houseController;

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.profile['name']?.toString() ?? '',
    );
    _emailController = TextEditingController(
      text: widget.profile['email']?.toString() ?? '',
    );
    _mobileController = TextEditingController(
      text: (widget.profile['mobile'] ?? widget.profile['phone'] ?? '')
          .toString(),
    );
    _fatherNameController = TextEditingController(
      text: widget.profile['father_name']?.toString() ?? '',
    );
    _villageController = TextEditingController(
      text: widget.profile['village']?.toString() ?? '',
    );
    _houseController = TextEditingController(
      text: widget.profile['house_name']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _fatherNameController.dispose();
    _villageController.dispose();
    _houseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login again')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ProfileService.updateProfile(
        token: token,
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        fatherName: _fatherNameController.text.trim(),
        village: _villageController.text.trim(),
        houseName: _houseController.text.trim(),
        profileImage: _selectedImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.profile['profile_image']?.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                color: Colors.blue.shade50,
                child: ListTile(
                  leading: const Icon(Icons.badge, color: Colors.blue),
                  title: const Text('User ID (Read Only)'),
                  subtitle: Text(
                    widget.profile['unique_id']?.toString() ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : imageUrl != null && imageUrl.isNotEmpty
                          ? NetworkImage(_absoluteImageUrl(imageUrl))
                          : null,
                      child:
                          _selectedImage == null &&
                              (imageUrl == null || imageUrl.isEmpty)
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 20,
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
              const SizedBox(height: 24),
              _field(
                controller: _nameController,
                label: 'Name *',
                icon: Icons.person,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _mobileController,
                label: 'Mobile *',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _fatherNameController,
                label: "Father's Name",
                icon: Icons.family_restroom,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _villageController,
                label: 'Village',
                icon: Icons.location_city,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _houseController,
                label: 'House/Bari Name',
                icon: Icons.home,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: validator,
    );
  }

  String _absoluteImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return 'https://gaslagbaadmin.gtgroup.cloud/$imageUrl';
  }
}
