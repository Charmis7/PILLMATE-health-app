import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class bottom_nav_profile extends StatefulWidget {
  // Changed from StatelessWidget to StatefulWidget
  // Because we need to load data from Firestore (async operation)
  const bottom_nav_profile({super.key});

  @override
  State<bottom_nav_profile> createState() => _bottom_nav_profileState();
}

class _bottom_nav_profileState extends State<bottom_nav_profile> {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variables to hold profile data loaded from Firestore
  String name = "";
  String email = "";
  String dateOfBirth = "";
  String gender = "";
  bool isLoading = true;
  // isLoading = true while we fetch data from Firestore
  // Once data is loaded, set to false and show the profile

  @override
  void initState() {
    super.initState();
    loadProfile(); // Load data as soon as screen opens
  }

  // ── LOAD PROFILE FROM FIRESTORE ───────────────────────────
  Future<void> loadProfile() async {
    try {
      final user = _auth.currentUser;
      // Get the currently logged-in user

      if (user != null) {
        // Read this user's document from Firestore
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          // doc.data() returns the fields as a Map

          setState(() {
            // Update all state variables with data from Firestore
            name        = data['name']        ?? 'Not set';
            email       = data['email']       ?? user.email ?? 'Not set';
            dateOfBirth = data['dateOfBirth'] ?? 'Not set';
            gender      = data['gender']      ?? 'Not set';
            // ?? 'Not set' = if the field is missing/null, show 'Not set'
            isLoading   = false;
            // Done loading → hide spinner, show profile
          });
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  // ── LOGOUT FUNCTION ───────────────────────────────────────
  Future<void> _logout() async {
    // Show a confirmation dialog before logging out
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            // false = user pressed Cancel → don't log out
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            // true = user confirmed → proceed with logout
            child: const Text("Log Out"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _auth.signOut();
      // Signs the user out of Firebase Auth
      // After this, FirebaseAuth.instance.currentUser = null

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
          // pushAndRemoveUntil + (route) => false
          // = go to LoginScreen AND clear the entire navigation stack
          // User cannot press back to return to the app after logout
        );
      }
    }
  }

  // ── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF4C8CFF),
        centerTitle: true,
        automaticallyImplyLeading: false,
        // automaticallyImplyLeading: false = hide the back arrow
        // This is a bottom nav tab, not a pushed screen
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
      // Show spinner while data loads from Firestore
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // ── PROFILE PICTURE ────────────────────────
            const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFF4C8CFF),
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 8),

            // Show the name below profile picture
            Text(
              name,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ── PROFILE INFO TILES ─────────────────────
            // All values are now REAL data from Firestore
            _buildInfoTile(
              icon: Icons.person,
              title: "Name",
              value: name,
              // 'name' variable loaded from Firestore
            ),
            _buildInfoTile(
              icon: Icons.cake,
              title: "Date of Birth",
              value: dateOfBirth,
              // 'dateOfBirth' loaded from Firestore
            ),
            _buildInfoTile(
              icon: Icons.email,
              title: "Email",
              value: email,
              // 'email' loaded from Firestore
            ),
            _buildInfoTile(
              icon: Icons.wc,
              title: "Gender",
              value: gender,
              // 'gender' loaded from Firestore
            ),

            const SizedBox(height: 30),

            // ── LOGOUT BUTTON ──────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _logout,
                // Calls our _logout() function above
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Log Out",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── REUSABLE INFO TILE ─────────────────────────────────────
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4C8CFF)),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          value.isEmpty ? 'Not set' : value,
          // If value is empty string, show 'Not set'
        ),
      ),
    );
  }
}