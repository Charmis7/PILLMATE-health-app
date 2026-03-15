import 'package:flutter/material.dart';

class bottom_nav_profile extends StatelessWidget {
  const bottom_nav_profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF4C8CFF),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            // Profile picture
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/img_12.png'),
            ),
            const SizedBox(height: 20),

            // Name
            _buildInfoTile(icon: Icons.person, title: "Name", value: "John Doe"),

            // DOB
            _buildInfoTile(icon: Icons.cake, title: "Date of Birth", value: "01 Jan 2000"),

            // Email
            _buildInfoTile(icon: Icons.email, title: "Email", value: "john.doe@example.com"),

            // Phone
            _buildInfoTile(icon: Icons.phone, title: "Phone", value: "+91 9876543210"),

            // Address
            _buildInfoTile(
                icon: Icons.location_on,
                title: "Address",
                value: "123, Sample Street, City, Country"),

            const SizedBox(height: 30),

            // Edit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C8CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required String value}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4C8CFF)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}