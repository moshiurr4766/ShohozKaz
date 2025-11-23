import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';

/// ------------------------------
/// KYC WIZARD SCREEN
/// ------------------------------
class KycWizard extends StatefulWidget {
  const KycWizard({super.key});

  @override
  State<KycWizard> createState() => _KycWizardState();
}

class _KycWizardState extends State<KycWizard> {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  int _currentStep = 0;
  bool _loading = false;

  File? _frontFile;
  File? _backFile;
  File? _selfieFile;

  final nameCtrl = TextEditingController();
  final nidCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final bloodCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final postOfficeCtrl = TextEditingController();
  final postcodeCtrl = TextEditingController();
  final fatherCtrl = TextEditingController();
  final motherCtrl = TextEditingController();

  // -----------------------------
  // LIFECYCLE
  // -----------------------------
  @override
  void dispose() {
    nameCtrl.dispose();
    nidCtrl.dispose();
    dobCtrl.dispose();
    bloodCtrl.dispose();
    addressCtrl.dispose();
    postOfficeCtrl.dispose();
    postcodeCtrl.dispose();
    fatherCtrl.dispose();
    motherCtrl.dispose();
    super.dispose();
  }

  // -----------------------------
  // IMAGE PICKER (for NID front/back)
  // -----------------------------
  Future<File?> _pickImageDialog() async {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (c) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(c, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Upload from gallery'),
              onTap: () => Navigator.pop(c, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (src == null) return null;
    final x = await _picker.pickImage(source: src, imageQuality: 92);
    return x == null ? null : File(x.path);
  }

  // -----------------------------
  // OCR / BARCODE HELPERS
  // -----------------------------
  Future<RecognizedText> _ocr(File file) async {
    final input = InputImage.fromFile(file);
    final r = GoogleMlKit.vision.textRecognizer();
    final out = await r.processImage(input);
    await r.close();
    return out;
  }

  Future<List<Barcode>> _scanBarcodes(File file) async {
    final input = InputImage.fromFile(file);
    final s = GoogleMlKit.vision.barcodeScanner();
    final out = await s.processImage(input);
    await s.close();
    return out;
  }

  // -----------------------------
  // TEXT PARSERS
  // -----------------------------
  String? _extractNidNumber(String s) =>
      RegExp(r'\b\d{10,17}\b').firstMatch(s)?.group(0);

  String? _extractDob(String s) {
    final m1 = RegExp(r'\b\d{1,2}[-/]\d{1,2}[-/]\d{4}\b').firstMatch(s);
    if (m1 != null) return m1.group(0);
    final m2 = RegExp(
      r'\b(\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{4})\b',
      caseSensitive: false,
    ).firstMatch(s);
    return m2?.group(1);
  }

  String? _extractBlood(String s) => RegExp(
    r'\b(?:A|B|AB|O)[\+\-]\b',
    caseSensitive: false,
  ).firstMatch(s)?.group(0)?.toUpperCase();

  String? _extractPostcode(String s) =>
      RegExp(r'\b(\d{4})\b').firstMatch(s)?.group(1);

  String? _extractPostOffice(String s) {
    final patterns = [
      r'Post Office[:\s\-]*([A-Za-z0-9\s\.\-,\u0980-\u09FF]+)',
      r'Post[:\s\-]*([A-Za-z0-9\s\.\-,\u0980-\u09FF]+)',
      r'পোস্ট(?:\s*অফিস)?[:\s\-]*([^\n,]+)',
      r'ডাকঘর[:\s\-]*([^\n,]+)',
      r'\b(?:PO|P\.O|Post)[:\s]*([A-Za-z0-9\s\.\-,\u0980-\u09FF]+)',
    ];
    for (final p in patterns) {
      final m = RegExp(p, caseSensitive: false).firstMatch(s);
      if (m != null) return m.group(1)!.trim();
    }
    return null;
  }

  String _norm(String s) =>
      s.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), ' ').trim();

  // -----------------------------
  // FRONT IMAGE PARSE
  // -----------------------------
  Future<void> _parseFront(File file) async {
    final text = await _ocr(file);
    final lines = <String>[];
    for (final b in text.blocks) {
      for (final l in b.lines) {
        lines.add(_norm(l.text));
      }
    }
    final glued = lines.join('\n');

    if (nameCtrl.text.isEmpty) {
      final nameLine = lines.firstWhere(
        (l) => l.toLowerCase().contains('name') || l.contains('নাম'),
        orElse: () => '',
      );
      if (nameLine.isNotEmpty) {
        nameCtrl.text = nameLine.split(':').last.trim();
      }
    }

    nidCtrl.text = _extractNidNumber(glued) ?? nidCtrl.text;
    dobCtrl.text = _extractDob(glued) ?? dobCtrl.text;

    if (fatherCtrl.text.isEmpty) {
      final fLine = lines.firstWhere(
        (l) => l.toLowerCase().contains('father') || l.contains('পিতা'),
        orElse: () => '',
      );
      if (fLine.isNotEmpty) {
        fatherCtrl.text = fLine.split(':').last.trim();
      }
    }

    if (motherCtrl.text.isEmpty) {
      final mLine = lines.firstWhere(
        (l) => l.toLowerCase().contains('mother') || l.contains('মাতা'),
        orElse: () => '',
      );
      if (mLine.isNotEmpty) {
        motherCtrl.text = mLine.split(':').last.trim();
      }
    }
  }

  // -----------------------------
  // BACK IMAGE PARSE
  // -----------------------------
  Future<void> _parseBack(File file) async {
    final text = await _ocr(file);
    final barcodes = await _scanBarcodes(file);

    final lines = <String>[];
    for (final b in text.blocks) {
      for (final l in b.lines) {
        lines.add(_norm(l.text));
      }
    }
    final glued = lines.join('\n');

    bloodCtrl.text = _extractBlood(glued) ?? bloodCtrl.text;
    postOfficeCtrl.text = _extractPostOffice(glued) ?? postOfficeCtrl.text;
    postcodeCtrl.text = _extractPostcode(glued) ?? postcodeCtrl.text;

    // Address guess
    final idx = lines.indexWhere(
      (l) => l.toLowerCase().contains('address') || l.contains('ঠিকানা'),
    );
    if (idx != -1) {
      final parts = lines.sublist(idx).take(4);
      addressCtrl.text = parts.join(' ');
    }

    // Use barcode data if found
    if (barcodes.isNotEmpty) {
      final rawBarcode = barcodes.map((b) => b.rawValue ?? '').join('\n');

      bloodCtrl.text = _extractBlood(rawBarcode) ?? bloodCtrl.text;
      postOfficeCtrl.text =
          _extractPostOffice(rawBarcode) ?? postOfficeCtrl.text;
      postcodeCtrl.text = _extractPostcode(rawBarcode) ?? postcodeCtrl.text;

      if (nidCtrl.text.isEmpty) {
        final nid = _extractNidNumber(rawBarcode);
        if (nid != null) nidCtrl.text = nid;
      }
      if (dobCtrl.text.isEmpty) {
        final dob = _extractDob(rawBarcode);
        if (dob != null) dobCtrl.text = dob;
      }
      if (addressCtrl.text.isEmpty) {
        final addr = RegExp(
          r'(?:ADDR|ADDRESS)[:=](.+?)(?:;|,|\||$)',
          caseSensitive: false,
        ).firstMatch(rawBarcode)?.group(1);
        if (addr != null) addressCtrl.text = addr.trim();
      }
    }
  }

  // -----------------------------
  // SUBMIT → Upload + Save
  // -----------------------------
  Future<void> _submit() async {
    // Make sure user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack('You must be logged in to submit KYC.');
      return;
    }

    if (_frontFile == null || _backFile == null || _selfieFile == null) {
      _snack('Please add front, back and selfie.');
      return;
    }
    if (nameCtrl.text.isEmpty ||
        nidCtrl.text.isEmpty ||
        dobCtrl.text.isEmpty ||
        addressCtrl.text.isEmpty) {
      _snack('Please complete required fields.');
      return;
    }

    setState(() => _loading = true);

    try {
      final uid = user.uid;
      final folder = _storage.ref('kycInfo/$uid');

      final frontRef = folder.child('nid_front.jpg');
      final backRef = folder.child('nid_back.jpg');
      final selfieRef = folder.child('selfie.jpg');

      await Future.wait([
        frontRef.putFile(_frontFile!),
        backRef.putFile(_backFile!),
        selfieRef.putFile(_selfieFile!),
      ]);

      final frontUrl = await frontRef.getDownloadURL();
      final backUrl = await backRef.getDownloadURL();
      final selfieUrl = await selfieRef.getDownloadURL();

      await _firestore.collection('workerKyc').doc(uid).set({
        'uid': uid,
        'name': nameCtrl.text.trim(),
        'nidNumber': nidCtrl.text.trim(),
        'dob': dobCtrl.text.trim(),
        'bloodGroup': bloodCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'postOffice': postOfficeCtrl.text.trim(),
        'postcode': postcodeCtrl.text.trim(),
        'fatherName': fatherCtrl.text.trim(),
        'motherName': motherCtrl.text.trim(),
        'nidFrontUrl': frontUrl,
        'nidBackUrl': backUrl,
        'selfieUrl': selfieUrl,
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      //_snack(' KYC submitted successfully!');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _KycStatusPage()),
      );
    } catch (e) {
      debugPrint('Error submitting KYC: $e');
      _snack('Upload failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // -----------------------------
  // UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final bool isWide = size.width >= 700;

    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final bg = theme.colorScheme.background;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          'KYC Verification',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: surface,
      ),
      body: SafeArea(
        top: false,
        child: Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: primary,
              secondary: primary,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth > 900 ? 48.0 : 8.0;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 0,
                ),
                child: Stepper(
                  type: isWide ? StepperType.horizontal : StepperType.vertical,
                  currentStep: _currentStep,
                  onStepContinue: () async {
                    if (_currentStep == 0 && _frontFile != null) {
                      await _parseFront(_frontFile!);
                    }
                    if (_currentStep == 1 && _backFile != null) {
                      await _parseBack(_backFile!);
                    }
                    if (_currentStep < 3) {
                      setState(() => _currentStep++);
                    } else {
                      await _submit();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep--);
                    }
                  },
                  controlsBuilder: (context, details) {
                    final isLast = _currentStep == 3;
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: _loading ? null : details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLast
                                ? (_loading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text('Submit'))
                                : const Text('Next'),
                          ),
                          const SizedBox(width: 12),
                          if (_currentStep > 0)
                            OutlinedButton(
                              onPressed: _loading ? null : details.onStepCancel,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primary,
                                side: BorderSide(color: primary),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Back'),
                            ),
                        ],
                      ),
                    );
                  },
                  steps: [
                    Step(
                      title: const Text('Front side'),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0
                          ? StepState.complete
                          : StepState.indexed,
                      content: _imageSelector(
                        file: _frontFile,
                        label: 'Add front image of your NID',
                        onPick: () async {
                          final f = await _pickImageDialog();
                          if (f != null) {
                            setState(() => _frontFile = f);
                          }
                        },
                      ),
                    ),
                    Step(
                      title: const Text('Back side'),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1
                          ? StepState.complete
                          : StepState.indexed,
                      content: _imageSelector(
                        file: _backFile,
                        label: 'Add back image of your NID',
                        onPick: () async {
                          final f = await _pickImageDialog();
                          if (f != null) {
                            setState(() => _backFile = f);
                          }
                        },
                      ),
                    ),
                    Step(
                      title: const Text('Review'),
                      isActive: _currentStep >= 2,
                      state: _currentStep > 2
                          ? StepState.complete
                          : StepState.indexed,
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            _field(
                              nameCtrl,
                              'Full name *',
                              icon: Icons.person_outline,
                            ),
                            _field(
                              nidCtrl,
                              'NID number *',
                              keyboard: TextInputType.number,
                              icon: Icons.badge_outlined,
                            ),
                            _field(
                              dobCtrl,
                              'Date of Birth *',
                              icon: Icons.cake_outlined,
                            ),
                            _field(
                              bloodCtrl,
                              'Blood group',
                              icon: Icons.bloodtype_outlined,
                            ),
                            _field(
                              addressCtrl,
                              'Address *',
                              maxLines: 2,
                              icon: Icons.home_outlined,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: _field(
                                    postOfficeCtrl,
                                    'Post office',
                                    icon: Icons.local_post_office_outlined,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _field(
                                    postcodeCtrl,
                                    'Postcode',
                                    keyboard: TextInputType.number,
                                    icon: Icons.location_on_outlined,
                                  ),
                                ),
                              ],
                            ),
                            _field(
                              fatherCtrl,
                              'Father’s name',
                              icon: Icons.man_outlined,
                            ),
                            _field(
                              motherCtrl,
                              'Mother’s name',
                              icon: Icons.woman_outlined,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Step(
                      title: const Text('Selfie'),
                      isActive: _currentStep >= 3,
                      state: _selfieFile != null
                          ? StepState.complete
                          : StepState.indexed,
                      content: _imageSelector(
                        file: _selfieFile,
                        label: 'Take a selfie holding your NID',
                        onPick: () async {
                          final file = await Navigator.push<File?>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SelfieCameraScreen(),
                            ),
                          );
                          if (file != null) {
                            setState(() => _selfieFile = file);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _imageSelector({
    required File? file,
    required String label,
    required VoidCallback onPick,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: isDark
              ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
              : theme.colorScheme.surfaceVariant.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: isDark ? 0 : 1,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                if (file != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      file,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.4),
                      ),
                      color: isDark
                          ? Colors.black.withOpacity(0.15)
                          : Colors.white.withOpacity(0.7),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: Text(file == null ? label : 'Retake image'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tip: Use good lighting and keep the card flat for better recognition.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    TextInputType? keyboard,
    int maxLines = 1,
    IconData? icon,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon) : null,
          labelText: label,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(
            theme.brightness == Brightness.dark ? 0.2 : 0.6,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------
/// STATUS PAGE
/// ------------------------------
class _KycStatusPage extends StatelessWidget {
  const _KycStatusPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'KYC Status',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: primary.withOpacity(0.1),
                child: Icon(Icons.verified_rounded, size: 56, color: primary),
              ),
              const SizedBox(height: 18),
              Text(
                'Your KYC is under review',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'We are verifying your information. You will be notified once the review is complete.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Back to app'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------------
/// SELFIE CAMERA SCREEN
/// ------------------------------
/// Live camera preview → capture → return File to KycWizard
class SelfieCameraScreen extends StatefulWidget {
  const SelfieCameraScreen({super.key});

  @override
  State<SelfieCameraScreen> createState() => _SelfieCameraScreenState();
}

class _SelfieCameraScreenState extends State<SelfieCameraScreen> {
  CameraController? _controller;
  Future<void>? _initFuture;
  bool _isCapturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      CameraDescription? front;

      try {
        front = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
      } catch (_) {
        if (cameras.isNotEmpty) front = cameras.first;
      }

      if (front == null) {
        setState(() {
          _error = 'No camera found on this device.';
        });
        return;
      }

      _controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _initFuture = _controller!.initialize();
      setState(() {});
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize camera: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isCapturing) return;

    setState(() => _isCapturing = true);
    try {
      final xfile = await _controller!.takePicture();
      if (!mounted) return;
      Navigator.pop(context, File(xfile.path));
    } catch (e) {
      setState(() {
        _error = 'Failed to capture image: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Take Selfie',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _initFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_controller == null || !_controller!.value.isInitialized) {
                  return Center(
                    child: Text(
                      'Camera not ready.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      color: Colors.black,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Hold your NID and align your face clearly.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: _isCapturing
                                    ? null
                                    : () => Navigator.pop(context),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _isCapturing ? null : _capture,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(18),
                                ),
                                child: _isCapturing
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.camera_alt),
                              ),
                              const SizedBox(width: 48), // spacer
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
