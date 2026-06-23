import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:userapp/providers/auth_provider.dart';
import 'package:userapp/screens/auth/login_screen.dart';
import 'package:userapp/screens/profile/order_history_screen.dart';
import 'package:userapp/screens/profile/profile_edit_screen.dart';
import 'package:userapp/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final profile = await ProfileService.getProfile(token);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _copyUniqueId() {
    final uniqueId = _profile?['unique_id']?.toString();
    if (uniqueId == null || uniqueId.isEmpty) return;
    Clipboard.setData(ClipboardData(text: uniqueId));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('User ID copied!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isLoading && _profile != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileEditScreen(profile: _profile!),
                  ),
                );
                if (result == true) _loadProfile();
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _profile == null
            ? const Center(child: Text('Failed to load profile'))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildUniqueIdCard(),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: const Text('Order History'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const OrderHistoryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInfoSection('Personal Information', [
                      _buildInfoTile(Icons.person, 'Name', _profile!['name']),
                      _buildInfoTile(
                        Icons.phone,
                        'Mobile',
                        _profile!['mobile'] ?? _profile!['phone'],
                      ),
                      _buildInfoTile(
                        Icons.email,
                        'Email',
                        _profile!['email'] ?? 'Not set',
                      ),
                      _buildInfoTile(
                        Icons.family_restroom,
                        "Father's Name",
                        _profile!['father_name'] ?? 'Not set',
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildInfoSection('Address', [
                      _buildInfoTile(
                        Icons.location_city,
                        'Village',
                        _profile!['village'] ?? 'Not set',
                      ),
                      _buildInfoTile(
                        Icons.home,
                        'House/Bari',
                        _profile!['house_name'] ?? 'Not set',
                      ),
                    ]),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final imageUrl = _profile!['profile_image']?.toString();
    final name = _profile!['name']?.toString() ?? 'User';

    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: imageUrl != null && imageUrl.isNotEmpty
              ? NetworkImage(_absoluteImageUrl(imageUrl))
              : null,
          child: imageUrl == null || imageUrl.isEmpty
              ? Text(
                  name.isEmpty ? 'U' : name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text(name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          _profile!['email']?.toString() ?? 'No email',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildUniqueIdCard() {
    return Card(
      color: Colors.blue.shade50,
      child: ListTile(
        leading: const Icon(Icons.badge, color: Colors.blue),
        title: const Text('User ID'),
        subtitle: Text(
          _profile!['unique_id']?.toString() ?? 'N/A',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: _copyUniqueId,
          tooltip: 'Copy ID',
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(value ?? 'Not set', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _absoluteImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return 'https://gaslagbaadmin.gtgroup.cloud/$imageUrl';
  }
}
