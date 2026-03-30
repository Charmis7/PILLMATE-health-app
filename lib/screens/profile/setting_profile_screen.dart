import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../auth/reusable_widgets.dart';
import '../other/notification_permission.dart';

class SettingProfileScreen extends StatefulWidget {
  const SettingProfileScreen({super.key});

  @override
  State<SettingProfileScreen> createState() => _SettingProfileScreenState();
}

class _SettingProfileScreenState extends State<SettingProfileScreen> {
  final _nameController = TextEditingController();

  String selectedGender = 'Select';
  String selectedDate   = 'Select';
  bool   isLoading      = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  //load existing profile
  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final user = await UserService.getUser(uid);
        if (user != null) {
          _nameController.text = user.name;
          selectedGender       = user.gender;
          selectedDate         = user.dateOfBirth;
        }
      }
    } catch (e) {
      _showError('Failed to load data');
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }
  Future<void> _save() async {
    final name = _nameController.text.trim();

    if (name.isEmpty)
    { _showError('Enter name');
      return; }
    if (selectedGender == 'Select')
    { _showError('Select gender');
      return; }
    if (selectedDate   == 'Select')
    { _showError('Select DOB');
      return; }

    setState(() => isLoading = true);
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) { _showError('User not logged in'); return; }

//user model
      final userModel = UserModel(
        uid        : firebaseUser.uid,
        name       : name,
        email      : firebaseUser.email ?? '',
        gender     : selectedGender,
        dateOfBirth: selectedDate,
      );

      await UserService.updateUser(userModel);

      _showSuccess('Profile saved');
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NotificationPermissionUIScreen()),
      );
    } catch (e) {
      _showError('Save failed');
    }
    if (!mounted) return;
    setState(() => isLoading = false);
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Choose Gender', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          for (final g in ['Male', 'Female', 'Other'])
            ListTile(
              title: Text(g),
              onTap: () {
                setState(() => selectedGender = g);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context    : context,
      initialDate: DateTime(2000),
      firstDate  : DateTime(1950),
      lastDate   : DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = DateFormat('dd/MMM/yyyy').format(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FF),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
          const Center(
            child: Text('Complete your profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 40),

          const Text('Name'),
          const SizedBox(height: 8),
          TextField(controller: _nameController),
          const SizedBox(height: 30),

          GestureDetector(
            onTap: _showGenderPicker,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Gender'),
                Row(children: [
                  Text(selectedGender),
                  const Icon(Icons.arrow_drop_down),
                ]),
              ],
            ),
          ),
          const Divider(),

          GestureDetector(
            onTap: _showDatePicker,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Date of Birth'),
                Row(children: [
                  Text(selectedDate),
                  const Icon(Icons.arrow_drop_down),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 80),

          PrimaryButton(text: 'Save Profile', onPressed: _save),
        ],
      ),
    );
  }

  void _showError(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(m), backgroundColor: Colors.red),
  );

  void _showSuccess(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(m), backgroundColor: Colors.green),
  );
}