















// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';

// class EditJobScreen extends StatefulWidget {
//   final String jobId;
//   final Map<String, dynamic> jobData;

//   const EditJobScreen({super.key, required this.jobId, required this.jobData});

//   @override
//   State<EditJobScreen> createState() => _EditJobScreenState();
// }

// class _EditJobScreenState extends State<EditJobScreen> {
//   int _currentStep = 0;
//   bool _isUpdating = false;

//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _salaryController = TextEditingController();
//   final _summaryController = TextEditingController();

//   String selectedLocation = 'Dhaka, Bangladesh';
//   String selectedJobType = 'Part-time';
//   String selectedSkill = 'Driving';
//   String selectedExperience = '1+ year';
//   String selectedEducation = 'Secondary';

//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();

//     _titleController.text = widget.jobData['title'] ?? '';
//     _descriptionController.text = widget.jobData['description'] ?? '';
//     _salaryController.text = widget.jobData['salary'] ?? '';
//     _summaryController.text = widget.jobData['summary'] ?? '';

//     selectedLocation = widget.jobData['location'] ?? 'Dhaka, Bangladesh';
//     selectedJobType = widget.jobData['jobType'] ?? 'Part-time';
//     selectedSkill = widget.jobData['skill'] ?? 'Driving';
//     selectedExperience = widget.jobData['experience'] ?? '1+ year';
//     selectedEducation = widget.jobData['education'] ?? 'Secondary';
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() => _selectedImage = File(pickedFile.path));
//     }
//   }

//   Future<void> _updateJob() async {
//     if (_isUpdating) return;
//     setState(() => _isUpdating = true);
//     final theme = Theme.of(context);

//     try {
//       String imageUrl = widget.jobData['imageUrl'] ?? '';

//       if (_selectedImage != null) {
//         final ref = FirebaseStorage.instance
//             .ref()
//             .child('jobpost')
//             .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
//         await ref.putFile(_selectedImage!);
//         imageUrl = await ref.getDownloadURL();
//       }

//       await FirebaseFirestore.instance
//           .collection('jobs')
//           .doc(widget.jobId)
//           .update({
//         'title': _titleController.text.trim(),
//         'description': _descriptionController.text.trim(),
//         'location': selectedLocation,
//         'jobType': selectedJobType,
//         'skill': selectedSkill,
//         'experience': selectedExperience,
//         'education': selectedEducation,
//         'salary': _salaryController.text.trim(),
//         'summary': _summaryController.text.trim(),
//         'imageUrl': imageUrl,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       // ignore: use_build_context_synchronously
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text(' Job updated successfully!',
//             style: TextStyle(color: Colors.white),),
//           backgroundColor: theme.colorScheme.primary,
//           behavior: SnackBarBehavior.floating,
//           margin: const EdgeInsets.all(16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//         ),
//       );
//       // ignore: use_build_context_synchronously
//       Navigator.of(context).pop();
//     } catch (e) {
//       // ignore: use_build_context_synchronously
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(' Failed to update: $e'),
//           backgroundColor: theme.colorScheme.error,
//           behavior: SnackBarBehavior.floating,
//           margin: const EdgeInsets.all(16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//         ),
//       );
//     } finally {
//       if (mounted) setState(() => _isUpdating = false);
//     }
//   }

//   void _cancel() {
//     if (_isUpdating) return;
//     Navigator.of(context).pop();
//   }

//   void _nextStep() {
//     if (_currentStep < 2) setState(() => _currentStep++);
//   }

//   void _previousStep() {
//     if (_currentStep > 0) setState(() => _currentStep--);
//   }

//   InputDecoration _inputDecoration(String hint) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return InputDecoration(
//       hintText: hint,
//       filled: true,
//       fillColor: isDark ? Colors.grey[850] : Colors.white,
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(
//           // ignore: deprecated_member_use
//           color: Colors.deepOrange.withOpacity(0.4),
//         ),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Colors.deepOrange, width: 1.5),
//       ),
//       hintStyle: TextStyle(
//         color: isDark ? Colors.grey[400] : Colors.grey[600],
//       ),
//       contentPadding:
//           const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//     );
//   }

//   Widget _buildStepIndicator() {
//     final titles = ['Job Details', 'Skills & Qualifications', 'Publish'];
//     final totalSteps = titles.length;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: List.generate(totalSteps, (index) {
//             final isActive = index == _currentStep;
//             return Text(
//               titles[index],
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: isActive ? Colors.deepOrange : Colors.grey,
//               ),
//             );
//           }),
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           height: 20,
//           child: Stack(
//             alignment: Alignment.centerLeft,
//             children: [
//               Positioned.fill(
//                 top: 6,
//                 child: Row(
//                   children: List.generate(totalSteps - 1, (_) {
//                     return Expanded(
//                       child: Container(height: 4, color: Colors.orange.shade100),
//                     );
//                   }),
//                 ),
//               ),
//               Positioned.fill(
//                 top: 6,
//                 child: Row(
//                   children: List.generate(totalSteps - 1, (index) {
//                     return Expanded(
//                       child: Container(
//                         height: 4,
//                         color: index < _currentStep
//                             ? Colors.deepOrange
//                             : Colors.transparent,
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: List.generate(totalSteps, (index) {
//                   final isCompleted = index < _currentStep;
//                   final isCurrent = index == _currentStep;
//                   Color color = isCompleted || isCurrent
//                       ? Colors.deepOrange
//                       : Colors.orange.shade100;

//                   return Container(
//                     width: 16,
//                     height: 16,
//                     decoration: BoxDecoration(
//                       color: color,
//                       shape: BoxShape.circle,
//                     ),
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDropdown(String label, String value, List<String> items,
//       void Function(String?)? onChanged) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 6),
//         DropdownButtonFormField<String>(
//           initialValue: value,
//           decoration: _inputDecoration('Select $label'),
//           isExpanded: true,
//           icon: const Icon(Icons.arrow_drop_down),
//           items: items
//               .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//               .toList(),
//           onChanged: onChanged,
//         ),
//       ],
//     );
//   }

//   Widget _buildJobDetailsPage() => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Job Title', style: TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 6),
//           TextField(
//               controller: _titleController,
//               decoration: _inputDecoration('Title Here')),
//           const SizedBox(height: 16),
//           const Text('Description',
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 6),
//           TextField(
//             controller: _descriptionController,
//             maxLines: 4,
//             decoration: _inputDecoration('Sometext here...'),
//           ),
//           const SizedBox(height: 16),
//           _buildDropdown('Location', selectedLocation, [
//             'Dhaka, Bangladesh',
//             'Chittagong, Bangladesh',
//             'Sylhet, Bangladesh',
//           ], (val) => setState(() => selectedLocation = val!)),
//           const SizedBox(height: 16),
//           _buildDropdown('Job Type', selectedJobType,
//               ['Part-time', 'Full-time', 'Remote', 'One-time'],
//               (val) => setState(() => selectedJobType = val!)),
//         ],
//       );

//   Widget _buildSkillsPage() => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildDropdown('Skill', selectedSkill,
//               ['Electric', 'Plumbing', 'Driving', 'Cleaning'],
//               (val) => setState(() => selectedSkill = val!)),
//           const SizedBox(height: 16),
//           _buildDropdown('Experience', selectedExperience,
//               ['None', '1+ year', '2+ years', '5+ years'],
//               (val) => setState(() => selectedExperience = val!)),
//           const SizedBox(height: 16),
//           _buildDropdown('Education Level', selectedEducation,
//               ['None', 'Primary', 'Secondary', 'HSC', 'Graduate'],
//               (val) => setState(() => selectedEducation = val!)),
//         ],
//       );

//   Widget _buildPublishPage() => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           GestureDetector(
//             onTap: _pickImage,
//             child: Container(
//               height: 150,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Theme.of(context).brightness == Brightness.dark
//                     ? Colors.grey[850]
//                     : Colors.orange[50],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: _selectedImage != null
//                   ? ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.file(_selectedImage!, fit: BoxFit.cover),
//                     )
//                   : (widget.jobData['imageUrl'] != null &&
//                           widget.jobData['imageUrl'].toString().isNotEmpty)
//                       ? ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Image.network(widget.jobData['imageUrl'],
//                               fit: BoxFit.cover),
//                         )
//                       : const Icon(Icons.image,
//                           size: 80, color: Colors.orange),
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Text('Expected Salary',
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 6),
//           TextField(
//               controller: _salaryController,
//               decoration: _inputDecoration('৳1000/day')),
//           const SizedBox(height: 16),
//           const Text('Job Summary',
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 6),
//           TextField(
//             controller: _summaryController,
//             maxLines: 4,
//             decoration: _inputDecoration('Sometext here...'),
//           ),
//           const SizedBox(height: 24),
//           _buildUpdateButtons(),
//         ],
//       );

//   Widget _buildUpdateButtons() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: _isUpdating ? null : _previousStep,
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   side: const BorderSide(color: Colors.deepOrange),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text('Back',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.deepOrange)),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: _isUpdating ? null : _cancel,
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   side: const BorderSide(color: Colors.deepOrange),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text('Cancel',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.deepOrange)),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: _isUpdating ? null : _updateJob,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.deepOrange,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: _isUpdating
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                 : const Text('Update Job',
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBottomNavigation() {
//     if (_currentStep == 0) {
//       return SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           onPressed: _nextStep,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.deepOrange,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12)),
//           ),
//           child: const Text('Next',
//               style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//       );
//     } else if (_currentStep == 1) {
//       return Row(
//         children: [
//           Expanded(
//             child: OutlinedButton(
//               onPressed: _previousStep,
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//               ),
//               child: const Text('Back',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: ElevatedButton(
//               onPressed: _nextStep,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepOrange,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//               ),
//               child: const Text('Next',
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//           ),
//         ],
//       );
//     } else {
//       return const SizedBox.shrink();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final pages = [
//       _buildJobDetailsPage(),
//       _buildSkillsPage(),
//       _buildPublishPage(),
//     ];

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: const Text('Edit Job'),
//         elevation: 0,
//         foregroundColor: Theme.of(context).colorScheme.onSurface,
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               _buildStepIndicator(),
//               const SizedBox(height: 24),
//               Expanded(
//                 child: SingleChildScrollView(child: pages[_currentStep]),
//               ),
//               const SizedBox(height: 16),
//               _buildBottomNavigation(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

















import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:shohozkaz/core/constants.dart';
import 'package:shohozkaz/features/screen/pages/jobs/data/job_data.dart';

class EditJobScreen extends StatefulWidget {
  final String jobId;
  final Map<String, dynamic> jobData;

  const EditJobScreen({
    super.key,
    required this.jobId,
    required this.jobData,
  });

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  int _currentStep = 0;
  bool _isUpdating = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _summaryController = TextEditingController();

  String selectedJobType = 'One-time Task';
  String selectedSkill = 'Electrician';
  String selectedExperience = 'No Experience';
  String selectedEducation = 'No Formal Education';

  // Location (same pattern as CreateJobScreen)
  String? selectedDivision;
  String? selectedDistrict;
  String? selectedUpazila;

  String get selectedLocation {
    if (selectedDivision == null ||
        selectedDistrict == null ||
        selectedUpazila == null) {
      return "Select Location";
    }

    final cleanDivision = selectedDivision!.replaceAll(" Division", "").trim();
    return "$selectedUpazila, $selectedDistrict, $cleanDivision, Bangladesh";
  }

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final data = widget.jobData;

    _titleController.text = data['title'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _salaryController.text = data['salary'] ?? '';
    _summaryController.text = data['summary'] ?? '';

    selectedJobType = data['jobType'] ?? 'One-time Task';
    selectedSkill = data['skill'] ?? 'Electrician';
    selectedExperience = data['experience'] ?? 'No Experience';
    selectedEducation = data['education'] ?? 'No Formal Education';

    // Parse and pre-fill location if available
    final loc = (data['location'] ?? '').toString();
    final parts = loc.split(',').map((e) => e.trim()).toList();
    // Expected format: Upazila, District, Division, Bangladesh
    if (parts.length >= 3) {
      selectedUpazila = parts[0];
      selectedDistrict = parts[1];

      final divName = parts[2].replaceAll(" Division", "").trim();
      final divKey = "$divName Division";
      if (bdLocations.containsKey(divKey)) {
        selectedDivision = divKey;
      } else {
        selectedDivision = null;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Same validation behavior as CreateJobScreen
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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _updateJob() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    try {
      // Same validation as CreateJobScreen _postJob (but image not required)
      if (_titleController.text.trim().isEmpty) {
        _showError("Please enter a job title.");
        setState(() => _isUpdating = false);
        return;
      }

      if (_descriptionController.text.trim().isEmpty) {
        _showError("Please enter a job description.");
        setState(() => _isUpdating = false);
        return;
      }

      if (selectedDivision == null ||
          selectedDistrict == null ||
          selectedUpazila == null) {
        _showError(
          "Please select a full location (Division, District, Upazila).",
        );
        setState(() => _isUpdating = false);
        return;
      }

      if (selectedSkill.isEmpty) {
        _showError("Please select a skill.");
        setState(() => _isUpdating = false);
        return;
      }

      if (selectedExperience.isEmpty) {
        _showError("Please select experience level.");
        setState(() => _isUpdating = false);
        return;
      }

      if (selectedEducation.isEmpty) {
        _showError("Please select education level.");
        setState(() => _isUpdating = false);
        return;
      }

      if (_salaryController.text.trim().isEmpty) {
        _showError("Please enter expected salary.");
        setState(() => _isUpdating = false);
        return;
      }

      if (_summaryController.text.trim().isEmpty) {
        _showError("Please enter job summary.");
        setState(() => _isUpdating = false);
        return;
      }

      // Use existing image if no new image is selected
      String imageUrl = widget.jobData['imageUrl']?.toString() ?? '';

      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child("jobpost")
            .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection("jobs")
          .doc(widget.jobId)
          .update({
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "location": selectedLocation,
        "jobType": selectedJobType,
        "skill": selectedSkill,
        "experience": selectedExperience,
        "education": selectedEducation,
        "salary": _salaryController.text.trim(),
        "summary": _summaryController.text.trim(),
        "imageUrl": imageUrl,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      _showSuccess("Job Updated Successfully!");

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showError("Job update failed: $e");
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _cancel() {
    if (_isUpdating) return;
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
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
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.button,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
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
          value: value,
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

  Widget _buildLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        // Division
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
                .map((dist) =>
                    DropdownMenuItem(value: dist, child: Text(dist)))
                .toList(),
            onChanged: (val) {
              setState(() {
                selectedDistrict = val;
                selectedUpazila = null;
              });
            },
          ),
        const SizedBox(height: 16),

        // Upazila
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

        const Text(
          "Selected Location:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(selectedLocation, style: const TextStyle(color: Colors.blueGrey)),
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
          const Text('Description',
              style: TextStyle(fontWeight: FontWeight.bold)),
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
                  : (widget.jobData['imageUrl'] != null &&
                          widget.jobData['imageUrl'].toString().isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.jobData['imageUrl'],
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.image,
                          size: 80, color: Colors.orange),
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
          const Text('Job Summary',
              style: TextStyle(fontWeight: FontWeight.bold)),
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
                onPressed: _isUpdating ? null : _previousStep,
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
                  _isUpdating ? 'Updating...' : 'Back',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _isUpdating ? null : _cancel,
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
            onPressed: _isUpdating ? null : _updateJob,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isUpdating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Update Job',
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
        title: const Text('Edit Job'),
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





