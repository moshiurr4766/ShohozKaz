import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shohozkaz/core/constants.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  int _currentStep = 0;
  bool _isPosting = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _summaryController = TextEditingController();

  String selectedLocation = 'Dhaka, Bangladesh';
  String selectedJobType = 'Part-time';
  String selectedSkill = 'Driving';
  String selectedExperience = '1+ year';
  String selectedEducation = 'Secondary';

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final jobTypes = ['Part-time', 'Full-time', 'Remote', 'One-time'];
  final skills = ['Electric', 'Plumbing', 'Driving', 'Cleaning'];
  final experiences = ['None', '1+ year', '2+ years', '5+ years'];
  final educations = ['None', 'Primary', 'Secondary', 'HSC', 'Graduate'];

  void _nextStep() {
    if (_currentStep < 2) setState(() => _currentStep++);
  }

  void _previousStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  // CHANGED: Updated job post function to include jobId
  // Future<void> _postJob() async {
  //   if (_isPosting) return;
  //   setState(() => _isPosting = true);

  //   try {
  //     String? imageUrl;

  //     //  Get current user info
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user == null) {
  //       throw Exception("User not logged in");
  //     }

  //     // Upload image to Firebase Storage
  //     if (_selectedImage != null) {
  //       final ref = FirebaseStorage.instance
  //           .ref()
  //           .child('jobpost')
  //           .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
  //       await ref.putFile(_selectedImage!);
  //       imageUrl = await ref.getDownloadURL();
  //     }

  //     // CHANGED: create a custom doc reference first (to get jobId)
  //     final jobRef = FirebaseFirestore.instance.collection('jobs').doc();

  //     //  CHANGED: Save job with jobId included
  //     await jobRef.set({
  //       'jobId': jobRef.id, //  new line: store jobId inside document
  //       'title': _titleController.text.trim(),
  //       'description': _descriptionController.text.trim(),
  //       'location': selectedLocation,
  //       'jobType': selectedJobType,
  //       'skill': selectedSkill,
  //       'experience': selectedExperience,
  //       'education': selectedEducation,
  //       'salary': _salaryController.text.trim(),
  //       'summary': _summaryController.text.trim(),
  //       'imageUrl': imageUrl ?? '',
  //       'postedAt': FieldValue.serverTimestamp(),
  //       'employerId': user.uid,
  //       'employerEmail': user.email,
  //     });

  //     // ignore: use_build_context_synchronously
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text(
  //           ' Job Posted Successfully!',
  //           style: TextStyle(color: Colors.white),
  //         ),
  //         // ignore: use_build_context_synchronously
  //         backgroundColor: Theme.of(context).colorScheme.primary,
  //         behavior: SnackBarBehavior.floating,
  //         margin: const EdgeInsets.all(16),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(14),
  //         ),
  //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  //       ),
  //     );

  //     // ignore: use_build_context_synchronously
  //     Navigator.of(context).pop();
  //   } catch (e) {
  //     // ignore: use_build_context_synchronously
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Text(
  //           ' Job Posted Failed!',
  //           style: TextStyle(color: Colors.white),
  //         ),
  //         // ignore: use_build_context_synchronously
  //         backgroundColor: Theme.of(context).colorScheme.primary,
  //         behavior: SnackBarBehavior.floating,
  //         margin: const EdgeInsets.all(16),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(14),
  //         ),
  //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  //       ),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _isPosting = false);
  //   }
  // }

  Future<void> _postJob() async {
    if (_isPosting) return;
    setState(() => _isPosting = true);

    try {
      // 1️⃣ Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError("You must be logged in to post jobs.");
        setState(() => _isPosting = false);
        return;
      }

      // 2️⃣ Check workerKyc status
      final doc = await FirebaseFirestore.instance
          .collection("workerKyc")
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        _showError("You must complete KYC verification before posting jobs.");
        setState(() => _isPosting = false);
        return;
      }

      final status = doc["status"] ?? "pending";

      if (status != "approved") {
        _showError("Your KYC is not approved yet. You cannot post jobs.");
        setState(() => _isPosting = false);
        return;
      }

      // 3️⃣ Upload image (if selected)
      String? imageUrl;
      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child("jobpost")
            .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      // 4️⃣ Create job document
      final jobRef = FirebaseFirestore.instance.collection("jobs").doc();

      await jobRef.set({
        "jobId": jobRef.id,
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "location": selectedLocation,
        "jobType": selectedJobType,
        "skill": selectedSkill,
        "experience": selectedExperience,
        "education": selectedEducation,
        "salary": _salaryController.text.trim(),
        "summary": _summaryController.text.trim(),
        "imageUrl": imageUrl ?? "",
        "postedAt": FieldValue.serverTimestamp(),
        "employerId": user.uid,
        "employerEmail": user.email,
      });

      // 5️⃣ Success message
      _showSuccess("Job Posted Successfully!");

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showError("Job posting failed: $e");
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.button,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  //  END CHANGED SECTION

  void _cancel() {
    if (_isPosting) return;
    Navigator.of(context).pop();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  InputDecoration _inputDecoration(String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? Colors.grey[900] : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.orange.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.orange.shade100),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _buildStepIndicator() {
    final titles = ['Job Details', 'Skills & Qualifications', 'Publish'];
    final totalSteps = titles.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalSteps, (index) {
            final isActive = index == _currentStep;
            return Text(
              titles[index],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.deepOrange : Colors.grey,
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 20,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned.fill(
                top: 6,
                child: Row(
                  children: List.generate(totalSteps - 1, (_) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        color: Colors.orange.shade100,
                      ),
                    );
                  }),
                ),
              ),
              Positioned.fill(
                top: 6,
                child: Row(
                  children: List.generate(totalSteps - 1, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        color: index < _currentStep
                            ? Colors.deepOrange
                            : Colors.transparent,
                      ),
                    );
                  }),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(totalSteps, (index) {
                  final isCompleted = index < _currentStep;
                  final isCurrent = index == _currentStep;
                  Color color = isCompleted || isCurrent
                      ? Colors.deepOrange
                      : Colors.orange.shade100;
                  return Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    void Function(String?)? onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: _inputDecoration('Select $label'),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildJobDetailsPage() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Job Title', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      TextField(
        controller: _titleController,
        decoration: _inputDecoration('Title Here'),
      ),
      const SizedBox(height: 16),
      const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      TextField(
        controller: _descriptionController,
        maxLines: 4,
        decoration: _inputDecoration('Sometext here...'),
      ),
      const SizedBox(height: 16),
      _buildDropdown('Location', selectedLocation, [
        'Dhaka, Bangladesh',
        'Chittagong, Bangladesh',
        'Sylhet, Bangladesh',
      ], (val) => setState(() => selectedLocation = val!)),
      const SizedBox(height: 16),
      _buildDropdown(
        'Job Type',
        selectedJobType,
        jobTypes,
        (val) => setState(() => selectedJobType = val!),
      ),
    ],
  );

  Widget _buildSkillsPage() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildDropdown(
        'Skill',
        selectedSkill,
        skills,
        (val) => setState(() => selectedSkill = val!),
      ),
      const SizedBox(height: 16),
      _buildDropdown(
        'Experience',
        selectedExperience,
        experiences,
        (val) => setState(() => selectedExperience = val!),
      ),
      const SizedBox(height: 16),
      _buildDropdown(
        'Education Level',
        selectedEducation,
        educations,
        (val) => setState(() => selectedEducation = val!),
      ),
    ],
  );

  Widget _buildPublishPage() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
              : const Icon(Icons.image, size: 80, color: Colors.orange),
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Expected Salary',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: _salaryController,
        decoration: _inputDecoration('৳1000/day'),
      ),
      const SizedBox(height: 16),
      const Text('Job Summary', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      TextField(
        controller: _summaryController,
        maxLines: 4,
        decoration: _inputDecoration('Sometext here...'),
      ),
      const SizedBox(height: 24),
      _buildPublishBottomButtons(),
    ],
  );

  Widget _buildPublishBottomButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isPosting ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isPosting ? 'Posting...' : 'Back',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _isPosting ? null : _cancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isPosting ? null : _postJob,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isPosting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Post Job',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    if (_currentStep == 0) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Next',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else if (_currentStep == 1) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildJobDetailsPage(),
      _buildSkillsPage(),
      _buildPublishPage(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Create Job'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStepIndicator(),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(child: pages[_currentStep]),
              ),
              const SizedBox(height: 16),
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }
}
