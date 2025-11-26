
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _imageFile;
  final picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  String selectedRole = 'Worker';
  String selectedLanguage = 'English';
  String email = '';
  String phone = '';
  String? profileImageUrl;

  bool _loading = true;
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('userInfo')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = data['name'] ?? '';
      locationController.text = data['location'] ?? '';
      bioController.text = data['bio'] ?? '';
      selectedRole = data['role'] ?? 'Worker';
      selectedLanguage = data['language'] ?? 'English';
      email = data['email'] ?? user.email ?? '';
      phone = data['phoneNumber'] ?? '';
      profileImageUrl = data['profileImage'];
    }

    setState(() => _loading = false);
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true); // start loading

    try {
      String? uploadedImageUrl = profileImageUrl;

      //  Upload new profile image if selected
      if (_imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('userprofile')
            .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(_imageFile!);
        uploadedImageUrl = await ref.getDownloadURL();
      }

      //  Save to Firestore
      await FirebaseFirestore.instance.collection('userInfo').doc(user.uid).set({
        'name': nameController.text.trim(),
        'email': email,
        'phoneNumber': phone,
        'location': locationController.text.trim(),
        'role': selectedRole,
        'language': selectedLanguage,
        'bio': bioController.text.trim(),
        'profileImage': uploadedImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() => profileImageUrl = uploadedImageUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Profile updated successfully"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      Navigator.pop(context); // go back
    } catch (e) {
      debugPrint("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isSaving = false); // stop loading
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Iconsax.notification)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Card(
              elevation: isDark ? 0 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Public Information",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),

                    //  Profile Image
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (profileImageUrl != null
                                  ? NetworkImage(
                                      "${profileImageUrl!}?v=${DateTime.now().millisecondsSinceEpoch}")
                                  : null) as ImageProvider?,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          child: _imageFile == null && profileImageUrl == null
                              ? const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 28,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    _buildLabel('Full Name'),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildLabel('Email Address'),
                    TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: email,
                        border: const UnderlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildLabel('Phone Number'),
                    TextField(
                      enabled: true,
                      decoration: InputDecoration(
                        hintText: phone.isNotEmpty ? phone : 'Not Provided',
                        border: const UnderlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildLabel('Location'),
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildLabel('Primary Role'),
                    ToggleButtons(
                      isSelected: [
                        'Worker',
                        'Employer',
                      ].map((e) => e == selectedRole).toList(),
                      onPressed: (index) {
                        setState(() {
                          selectedRole = ['Worker', 'Employer'][index];
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: colorScheme.onPrimary,
                      fillColor: colorScheme.primary,
                      color: colorScheme.onSurface,
                      constraints: const BoxConstraints(
                        minHeight: 42,
                        minWidth: 100,
                      ),
                      children: const [Text('Worker'), Text('Employer')],
                    ),

                    const SizedBox(height: 16),
                    _buildLabel('Bio'),
                    TextFormField(
                      controller: bioController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildLabel('Preferred Language'),
                    ToggleButtons(
                      isSelected: [
                        'English',
                        'বাংলা',
                      ].map((e) => e == selectedLanguage).toList(),
                      onPressed: (index) {
                        setState(() {
                          selectedLanguage = ['English', 'বাংলা'][index];
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: colorScheme.onPrimary,
                      fillColor: colorScheme.primary,
                      color: colorScheme.onSurface,
                      constraints: const BoxConstraints(
                        minHeight: 42,
                        minWidth: 100,
                      ),
                      children: const [Text('English'), Text('বাংলা')],
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _saveChanges,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Save Changes"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
