import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import'package:pillmate_college/screens/notification_permission.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import'package:pillmate_college/widget/reusable_widgets.dart';

class SettingProfileScreen extends StatefulWidget {
  const SettingProfileScreen({super.key});

  @override
  State<SettingProfileScreen> createState() => _SettingProfileScreenState();
}

class _SettingProfileScreenState extends State<SettingProfileScreen> {
  // Text field controller
  TextEditingController nameController = TextEditingController();

  // Firebase instances
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // UI state variables
  String selectedGender = "Select";
  String selectedDate = "Select";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData(); // Load existing user data when screen opens
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

          // Profile picture
          const Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFF4C8CFF),
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
          ),

          const SizedBox(height: 30),

          // Title
          const Text(
            "Complete your profile",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),

          // Name label
          const Text(
            "Name",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Name text field
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

          // Gender selector
          GestureDetector(
            onTap: showGenderPicker,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Gender",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Text(
                      selectedGender,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down,
                        color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 30),

          // Date of birth selector
          GestureDetector(
            onTap: showDatePickerDialog,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Date of Birth",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Text(
                      selectedDate,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down,
                        color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),

          // Save Profile button
          const SizedBox(height: 80),

          // ✅ REUSABLE BUTTON HERE!
          PrimaryButton(
            text: "Save Profile",
            onPressed: () {
              // Call your saveProfileData function first
              saveProfileData();

              // Then navigate to NotificationPermissionUIScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationPermissionUIScreen(),
                ),
              );

            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Load existing user data from Firestore
  void loadUserData() async {
    // Show loading spinner
    setState(() {
      isLoading = true;
    });

    try {
      // Get current logged in user
      User? currentUser = auth.currentUser;

      if (currentUser != null) {
        // Get user data from Firestore using their UID
        DocumentSnapshot userDoc = await firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        // If user document exists, load the data
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          setState(() {
            // Fill in the fields with existing data
            nameController.text = userData['name'] ?? '';
            selectedGender = userData['gender'] ?? 'Select';
            selectedDate = userData['dateOfBirth'] ?? 'Select';
          });
        }
      }
    } catch (error) {
      print("Error loading user data: $error");
      showError("Failed to load profile data");
    }

    // Hide loading spinner
    setState(() {
      isLoading = false;
    });
  }

  // Save profile data to Firestore
  void saveProfileData() async {
    // Get values from fields
    String name = nameController.text.trim();
    String gender = selectedGender;
    String dateOfBirth = selectedDate;

    // Check if name is empty
    if (name.isEmpty) {
      showError("Please enter your name");
      return;
    }

    // Check if gender is selected
    if (gender == "Select") {
      showError("Please select your gender");
      return;
    }

    // Check if date of birth is selected
    if (dateOfBirth == "Select") {
      showError("Please select your date of birth");
      return;
    }

    // Show loading spinner
    setState(() {
      isLoading = true;
    });

    try {
      // Get current logged in user
      User? currentUser = auth.currentUser;

      if (currentUser != null) {
        // Save/Update user data in Firestore under their UID
        await firestore.collection('users').doc(currentUser.uid).update({
          'name': name,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
          'profileCompleted': true,
          'updatedAt': DateTime.now().toIso8601String(),
        });

        // Show success message
        showSuccess("Profile saved successfully!");

        print("Profile data saved for user: ${currentUser.email}");
        print("Name: $name, Gender: $gender, DOB: $dateOfBirth");
      }
    } on FirebaseException catch (error) {
      // If save fails
      if (error.code == 'not-found') {
        showError("User profile not found. Please sign up again.");
      } else if (error.code == 'permission-denied') {
        showError("Permission denied. Please check your login.");
      } else {
        showError("Failed to save profile: ${error.message}");
      }
    } catch (error) {
      showError("An error occurred: $error");
    }

    // Hide loading spinner
    setState(() {
      isLoading = false;
    });
  }

  // Show gender picker bottom sheet
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
            // Title
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Choose Gender",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Male option
            ListTile(
              title: const Text("Male"),
              onTap: () {
                setState(() {
                  selectedGender = "Male";
                });
                Navigator.pop(context);
              },
            ),

            // Female option
            ListTile(
              title: const Text("Female"),
              onTap: () {
                setState(() {
                  selectedGender = "Female";
                });
                Navigator.pop(context);
              },
            ),

            // Other option
            ListTile(
              title: const Text("Other"),
              onTap: () {
                setState(() {
                  selectedGender = "Other";
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Show date picker dialog
  void showDatePickerDialog() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd/MMM/yyyy').format(pickedDate);
      setState(() {
        selectedDate = formattedDate;
      });
    }
  }

  // Show error message (red snackbar)
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show success message (green snackbar)
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Clean up controller when screen is closed
  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}