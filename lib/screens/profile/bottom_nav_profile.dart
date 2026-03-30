import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../auth/login_screen.dart';


class bottom_nav_profile extends StatefulWidget {
  const bottom_nav_profile({super.key});

  @override
  State<bottom_nav_profile> createState() => _bottom_nav_profileState();
}

class _bottom_nav_profileState extends State<bottom_nav_profile> {

  UserModel? _user;   // null until loaded
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Load user profile
  Future<void> _loadProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final user = await UserService.getUser(uid);
        setState(() {
          _user     = user;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape  : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title  : const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF4C8CFF),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFF4C8CFF),
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _user?.name ?? 'Not set',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // All values come from UserModel — same data SettingProfileScreen saved
            _infoTile(Icons.person, 'Name',          _user?.name        ?? 'Not set'),
            _infoTile(Icons.cake,   'Date of Birth', _user?.dateOfBirth  ?? 'Not set'),
            _infoTile(Icons.email,  'Email',         _user?.email        ?? 'Not set'),
            _infoTile(Icons.wc,     'Gender',        _user?.gender       ?? 'Not set'),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon : const Icon(Icons.logout),
                label: const Text('Log Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading : Icon(icon, color: const Color(0xFF4C8CFF)),
        title   : Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value.isEmpty ? 'Not set' : value),
      ),
    );
  }
}