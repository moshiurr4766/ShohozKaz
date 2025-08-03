import 'dart:io';
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

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  final TextEditingController nameController = TextEditingController(
    text: 'Shahidul Islam',
  );
  final TextEditingController locationController = TextEditingController(
    text: 'Dhaka, Bangladesh',
  );
  final TextEditingController bioController = TextEditingController(
    text:
        'Experienced electrician with 5+ years in commercial and residential projects. Certified and reliable.',
  );

  String selectedRole = 'Worker';
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 16, top: 0),
          child: Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        toolbarHeight: 60,
        centerTitle: true,
        actions: [
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Iconsax.notification),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Profile Card
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
                      'Public Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This information will be visible to others on the platform.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 20),

                    // Profile Picture
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : null,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          child: _imageFile == null
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
                    const TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: 'shahidul@example.com',
                        border: UnderlineInputBorder(),
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
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: ToggleButtons(
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
                        textStyle: const TextStyle(fontWeight: FontWeight.w500),
                        children: const [Text('Worker'), Text('Employer')],
                      ),
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
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: ToggleButtons(
                        isSelected: [
                          'English',
                          'বাংলা',
                        ].map((e) => e == selectedRole).toList(),
                        onPressed: (index) {
                          setState(() {
                            selectedRole = ['English', 'বাংলা'][index];
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
                        textStyle: const TextStyle(fontWeight: FontWeight.w500),
                        children: const [Text('English'), Text('বাংলা')],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: () {
                          // Save logic
                        },
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Save Changes"),
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
