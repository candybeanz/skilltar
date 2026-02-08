import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Document verification status for host onboarding (Step 2 of 3).
enum DocumentStatus { pending, verified, actionRequired }

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  static const int totalSteps = 3;
  static const int currentStep = 2;

  static const String keyGovernmentId = 'government_id';
  static const String keyProfessionalCert = 'professional_certification';
  static const String keyProofOfAddress = 'proof_of_address';

  final Map<String, DocumentStatus> _status = {
    keyGovernmentId: DocumentStatus.pending,
    keyProfessionalCert: DocumentStatus.pending,
    keyProofOfAddress: DocumentStatus.pending,
  };

  final Map<String, String?> _filePaths = {
    keyGovernmentId: null,
    keyProfessionalCert: null,
    keyProofOfAddress: null,
  };

  bool get _canSubmit =>
      _filePaths[keyGovernmentId] != null &&
      _filePaths[keyProfessionalCert] != null &&
      _filePaths[keyProofOfAddress] != null;

  Future<void> _pickFile(String key) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    setState(() {
      _filePaths[key] = path;
      _status[key] = DocumentStatus.pending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F1FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'STEP $currentStep OF $totalSteps',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B6B6B),
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: currentStep / totalSteps,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE7E1F5),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B4DA8)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Verify Your Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DocumentUploadCard(
                        title: 'Government ID',
                        status: _status[keyGovernmentId]!,
                        filePath: _filePaths[keyGovernmentId],
                        onTap: () => _pickFile(keyGovernmentId),
                      ),
                      const SizedBox(height: 14),
                      _DocumentUploadCard(
                        title: 'Professional Certification',
                        status: _status[keyProfessionalCert]!,
                        filePath: _filePaths[keyProfessionalCert],
                        onTap: () => _pickFile(keyProfessionalCert),
                      ),
                      const SizedBox(height: 14),
                      _DocumentUploadCard(
                        title: 'Proof of Address',
                        status: _status[keyProofOfAddress]!,
                        filePath: _filePaths[keyProofOfAddress],
                        onTap: () => _pickFile(keyProofOfAddress),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.lock_outline, size: 18, color: Color(0xFF6B6B6B)),
                          SizedBox(width: 8),
                          Text(
                            'Your data is encrypted and secure.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B6B6B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _canSubmit
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Submitted for review ✅')),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B4DA8),
                            disabledBackgroundColor: const Color(0xFFB8B0D4),
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white70,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Submit for Review',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentUploadCard extends StatelessWidget {
  final String title;
  final DocumentStatus status;
  final String? filePath;
  final VoidCallback onTap;

  const _DocumentUploadCard({
    required this.title,
    required this.status,
    required this.filePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = filePath != null && filePath!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD1CBE3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
                _StatusPill(status: status, hasFile: hasFile),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 28,
                  color: hasFile
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF7B9FD1),
                ),
                const SizedBox(width: 12),
                Text(
                  hasFile
                      ? (filePath != null && !kIsWeb
                          ? filePath!.split(RegExp(r'[/\\]')).last
                          : 'Uploaded')
                      : 'Drag & Drop or Upload',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final DocumentStatus status;
  final bool hasFile;

  const _StatusPill({required this.status, required this.hasFile});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bgColor;
    Color textColor;
    IconData icon;
    if (status == DocumentStatus.verified) {
      label = 'Verified';
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
      icon = Icons.check_circle;
    } else if (status == DocumentStatus.actionRequired) {
      label = 'Action Required';
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFB00020);
      icon = Icons.warning_amber_rounded;
    } else {
      label = 'Pending';
      bgColor = const Color(0xFFFFF8E1);
      textColor = const Color(0xFFE65100);
      icon = Icons.schedule;
    }
    if (hasFile && status == DocumentStatus.pending) {
      label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
