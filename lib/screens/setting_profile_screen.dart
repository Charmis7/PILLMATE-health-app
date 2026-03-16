import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pillmate_college/screens/notification_permission.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pillmate_college/widget/reusable_widgets.dart';

class SettingProfileScreen extends StatefulWidget {
  const SettingProfileScreen({super.key});

  @override
  State<SettingProfileScreen> createState() => _SettingProfileScreenState();
}

class _SettingProfileScreenState extends State<SettingProfileScreen> {
  TextEditingController nameController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String selectedGender = "Select";
  String selectedDate = "Select";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        children: [
          const SizedBox(height: 80),

          const Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFF4C8CFF),
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Complete your profile",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),

          const Text("Name",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          TextField(
            controller: nameController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              hintText: "Enter your name",
            ),
          ),

          const SizedBox(height: 30),

          GestureDetector(
            onTap: showGenderPicker,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Gender",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    Text(
                      selectedGender,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 30),

          GestureDetector(
            onTap: showDatePickerDialog,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Date of Birth",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                Row(
                  children: [
                    Text(
                      selectedDate,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
          const SizedBox(height: 80),

          PrimaryButton(
            text: "Save Profile",
            onPressed: _saveAndNavigate,
            // ── FIX: now calls _saveAndNavigate which AWAITS the save
            // before navigating. Old code called saveProfileData() and
            // Navigator.pushReplacement() at the same time — the app
            // navigated BEFORE the data was saved to Firestore!
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── FIX: single async function that saves THEN navigates ───
  Future<void> _saveAndNavigate() async {
    // Step 1: validate inputs first
    String name = nameController.text.trim();

    if (name.isEmpty) {
      showError("Please enter your name");
      return;
    }
    if (selectedGender == "Select") {
      showError("Please select your gender");
      return;
    }
    if (selectedDate == "Select") {
      showError("Please select your date of birth");
      return;
    }

    // Step 2: show loading
    setState(() => isLoading = true);

    try {
      User? currentUser = auth.currentUser;

      if (currentUser != null) {
        // ── FIX: use .set() with merge:true instead of .update()
        // .update() FAILS if any field doesn't exist yet in the document
        // .set() with merge:true = creates fields if missing, updates if exists
        // This is safer and works for both new users and returning users
        await firestore
            .collection('users')
            .doc(currentUser.uid)
            .set({
          'name': name,
          'email': currentUser.email ?? '',
          // ── FIX: also save email here so profile screen can read it
          'gender': selectedGender,
          'dateOfBirth': selectedDate,
          // ── KEY NAME: 'dateOfBirth' — must match exactly what
          // bottom_nav_profile.dart reads: data['dateOfBirth']
          'profileCompleted': true,
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
        // SetOptions(merge: true) = only update the fields listed above,
        // keep all other fields (like 'createdAt', 'uid') unchanged
        // This is the SAFE version of .update()

        showSuccess("Profile saved!");
      }

      // Step 3: navigate ONLY after save is confirmed
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationPermissionUIScreen(),
          ),
        );
      }
    } on FirebaseException catch (error) {
      setState(() => isLoading = false);
      showError("Failed to save: ${error.message}");
    } catch (error) {
      setState(() => isLoading = false);
      showError("An error occurred: $error");
    }
  }

  void loadUserData() async {
    setState(() => isLoading = true);

    try {
      User? currentUser = auth.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>;

          setState(() {
            nameController.text = userData['name'] ?? '';
            selectedGender      = userData['gender'] ?? 'Select';
            selectedDate        = userData['dateOfBirth'] ?? 'Select';
          });
        }
      }
    } catch (error) {
      showError("Failed to load profile data");
    }

    setState(() => isLoading = false);
  }

  void showGenderPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Choose Gender",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              title: const Text("Male"),
              onTap: () {
                setState(() => selectedGender = "Male");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Female"),
              onTap: () {
                setState(() => selectedGender = "Female");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Other"),
              onTap: () {
                setState(() => selectedGender = "Other");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void showDatePickerDialog() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = DateFormat('dd/MMM/yyyy').format(pickedDate);
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2)),
    );
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}