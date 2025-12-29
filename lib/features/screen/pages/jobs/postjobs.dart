

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/jobs/data/job_data.dart';

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

  String selectedJobType = 'One-time Task';
  String selectedSkill = 'Electrician';
  String selectedExperience = 'No Experience';
  String selectedEducation = 'No Formal Education';

  //Marge and retuen electedLocation
  String? selectedDivision;
  String? selectedDistrict;
  String? selectedUpazila;

  String get selectedLocation {
    if (selectedDivision == null ||
        selectedDistrict == null ||
        selectedUpazila == null) {
      return "Select Location";
    }
    // Remove " Division" from division name
    final cleanDivision = selectedDivision!.replaceAll(" Division", "").trim();

    return "$selectedUpazila, $selectedDistrict, $cleanDivision, Bangladesh";
  }

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // void _nextStep() {
  //   if (_currentStep < 2) setState(() => _currentStep++);
  // }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_titleController.text.trim().isEmpty) {
        _showError("Please enter job title.");
        return;
      }
      if (_descriptionController.text.trim().isEmpty) {
        _showError("Please enter job description.");
        return;
      }
      if (selectedDivision == null) {
        _showError("Please select a division.");
        return;
      }
      if (selectedDistrict == null) {
        _showError("Please select a district.");
        return;
      }
      if (selectedUpazila == null) {
        _showError("Please select an upazila.");
        return;
      }
    }

    if (_currentStep == 1) {
      if (selectedSkill.isEmpty) {
        _showError("Please select a skill.");
        return;
      }
      if (selectedExperience.isEmpty) {
        _showError("Please select experience level.");
        return;
      }
      if (selectedEducation.isEmpty) {
        _showError("Please select education level.");
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }


  Future<void> _postJob() async {
    if (_isPosting) return;
    setState(() => _isPosting = true);

    try {
      // Step 0: Local Form Validation

      if (_titleController.text.trim().isEmpty) {
        _showError("Please enter a job title.");
        setState(() => _isPosting = false);
        return;
      }

      if (_descriptionController.text.trim().isEmpty) {
        _showError("Please enter a job description.");
        setState(() => _isPosting = false);
        return;
      }

      if (selectedDivision == null ||
          selectedDistrict == null ||
          selectedUpazila == null) {
        _showError(
          "Please select a full location (Division, District, Upazila).",
        );
        setState(() => _isPosting = false);
        return;
      }

      if (selectedSkill.isEmpty) {
        _showError("Please select a skill.");
        setState(() => _isPosting = false);
        return;
      }

      if (selectedExperience.isEmpty) {
        _showError("Please select experience level.");
        setState(() => _isPosting = false);
        return;
      }

      if (selectedEducation.isEmpty) {
        _showError("Please select education level.");
        setState(() => _isPosting = false);
        return;
      }

      if (_salaryController.text.trim().isEmpty) {
        _showError("Please enter expected salary.");
        setState(() => _isPosting = false);
        return;
      }

      if (_summaryController.text.trim().isEmpty) {
        _showError("Please enter job summary.");
        setState(() => _isPosting = false);
        return;
      }

      // Make image REQUIRED (Optional Feature)
      if (_selectedImage == null) {
        _showError("Please upload a job image.");
        setState(() => _isPosting = false);
        return;
      }

      // Step 1: Check user login
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError("You must be logged in to post jobs.");
        setState(() => _isPosting = false);
        return;
      }

      // Step 2: Check KYC status
      final kycDoc = await FirebaseFirestore.instance
          .collection("workerKyc")
          .doc(user.uid)
          .get();

      if (!kycDoc.exists) {
        _showError("You must complete KYC verification before posting jobs.");
        setState(() => _isPosting = false);
        return;
      }

      final status = kycDoc["status"] ?? "pending";

      if (status != "approved") {
        _showError("Your KYC is not approved. You cannot post jobs.");
        setState(() => _isPosting = false);
        return;
      }

      // Step 3: Upload Image
      String? imageUrl;
      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child("jobpost")
            .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      // Step 4: Create job in Firestore
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

      // Step 5: Success
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
      _buildLocationSelector(),

      const SizedBox(height: 16),
      _buildDropdown(
        'Job Type',
        selectedJobType,
        jobTypes,
        (val) => setState(() => selectedJobType = val!),
      ),
      const SizedBox(height: 16),
    ],
  );

  Widget _buildLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        //  Division
        DropdownButtonFormField<String>(
          value: selectedDivision,
          decoration: _inputDecoration("Select Division"),
          items: bdLocations.keys
              .map((div) => DropdownMenuItem(value: div, child: Text(div)))
              .toList(),
          onChanged: (val) {
            setState(() {
              selectedDivision = val;
              selectedDistrict = null;
              selectedUpazila = null;
            });
          },
        ),

        const SizedBox(height: 16),

        // District
        if (selectedDivision != null)
          DropdownButtonFormField<String>(
            value: selectedDistrict,
            decoration: _inputDecoration("Select District"),
            items: bdLocations[selectedDivision]!.keys
                .map((dist) => DropdownMenuItem(value: dist, child: Text(dist)))
                .toList(),
            onChanged: (val) {
              setState(() {
                selectedDistrict = val;
                selectedUpazila = null;
              });
            },
          ),

        const SizedBox(height: 16),

        //Upazila
        if (selectedDistrict != null)
          DropdownButtonFormField<String>(
            value: selectedUpazila,
            decoration: _inputDecoration("Select a sub area"),
            items: bdLocations[selectedDivision]![selectedDistrict]!
                .map((upa) => DropdownMenuItem(value: upa, child: Text(upa)))
                .toList(),
            onChanged: (val) {
              setState(() {
                selectedUpazila = val;
              });
            },
          ),

        const SizedBox(height: 16),

        // Result
        const Text(
          "Selected Location:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(selectedLocation, style: const TextStyle(color: Colors.blueGrey)),
      ],
    );
  }

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
