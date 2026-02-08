import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Holds a picked file so it's really stored in the app (path on desktop/mobile, bytes on web).
class _PickedFile {
  final String? path;
  final Uint8List? bytes;
  final String name;

  _PickedFile({this.path, this.bytes, required this.name});

  bool get hasData =>
      (path != null && path!.isNotEmpty) ||
      (bytes != null && bytes!.length > 0) ||
      name.isNotEmpty;
  bool get isImage =>
      name.toLowerCase().endsWith('.jpg') ||
      name.toLowerCase().endsWith('.jpeg') ||
      name.toLowerCase().endsWith('.png');
}

enum DocumentStatus { pending, verified, actionRequired }

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  static const String keyGovernmentId = 'government_id';
  static const String keyProfessionalCert = 'professional_certification';
  static const String keyProofOfAddress = 'proof_of_address';

  final Map<String, DocumentStatus> _status = {
    keyGovernmentId: DocumentStatus.pending,
    keyProfessionalCert: DocumentStatus.pending,
    keyProofOfAddress: DocumentStatus.pending,
  };

  final Map<String, _PickedFile?> _files = {
    keyGovernmentId: null,
    keyProfessionalCert: null,
    keyProofOfAddress: null,
  };

  bool get _canSubmit =>
      _files[keyGovernmentId]?.hasData == true &&
      _files[keyProfessionalCert]?.hasData == true &&
      _files[keyProofOfAddress]?.hasData == true;

  static bool _isAllowedExtension(String name) {
    final lowerName = name.toLowerCase();
    return lowerName.endsWith('.pdf') ||
           lowerName.endsWith('.jpg') ||
           lowerName.endsWith('.jpeg') ||
           lowerName.endsWith('.png');
  }

  Future<void> _pickFile(String key) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) {
        print('File picker cancelled or no file selected');
        return;
      }
      final f = result.files.single;
      // On web, path is not available - only bytes
      final path = kIsWeb ? null : f.path;
      final bytes = f.bytes;
      final name = f.name ?? '';
      
      print('File selected: $name, path: $path, bytes length: ${bytes?.length}');
      
      // Check if file name has valid extension
      if (!_isAllowedExtension(name)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid file type: $name. Please choose a PDF or image (jpg, jpeg, png)')),
          );
        }
        return;
      }
      final String displayName = name.isNotEmpty
          ? name
          : (path != null && path.isNotEmpty
              ? path.split(RegExp(r'[/\\]')).last
              : 'document');
      
      if (!mounted) return;
      
      setState(() {
        _files[key] = _PickedFile(
          path: path,
          bytes: bytes,
          name: displayName,
        );
        _status[key] = DocumentStatus.pending;
      });
      
      print('File stored successfully: $displayName');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✓ $displayName selected')),
        );
      }
    } catch (e) {
      print('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting file: $e')),
        );
      }
    }
  }

  void _onSubmit() {
    if (!_canSubmit) return;
    showDialog<void>(
      context: context,
      builder: (context) => _ReviewDialog(
        files: Map.from(_files),
        onConfirm: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submitted for review ✅')),
          );
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
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
                        file: _files[keyGovernmentId],
                        onTap: () => _pickFile(keyGovernmentId),
                      ),
                      const SizedBox(height: 14),
                      _DocumentUploadCard(
                        title: 'Professional Certification',
                        status: _status[keyProfessionalCert]!,
                        file: _files[keyProfessionalCert],
                        onTap: () => _pickFile(keyProfessionalCert),
                      ),
                      const SizedBox(height: 14),
                      _DocumentUploadCard(
                        title: 'Proof of Address',
                        status: _status[keyProofOfAddress]!,
                        file: _files[keyProofOfAddress],
                        onTap: () => _pickFile(keyProofOfAddress),
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                          onPressed: _canSubmit ? _onSubmit : null,
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
  final _PickedFile? file;
  final VoidCallback onTap;

  const _DocumentUploadCard({
    required this.title,
    required this.status,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = file?.hasData == true;
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
                if (hasFile && file!.isImage && file!.bytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      file!.bytes!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 28,
                    color: hasFile
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF7B9FD1),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasFile ? file!.name : 'Tap to upload (image or PDF)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B6B6B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

class _ReviewDialog extends StatelessWidget {
  final Map<String, _PickedFile?> files;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ReviewDialog({
    required this.files,
    required this.onConfirm,
    required this.onCancel,
  });

  static const List<MapEntry<String, String>> _labels = [
    MapEntry('government_id', 'Government ID'),
    MapEntry('professional_certification', 'Professional Certification'),
    MapEntry('proof_of_address', 'Proof of Address'),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Review your documents'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirm and submit the following documents:',
              style: TextStyle(fontSize: 14, color: Color(0xFF5A5A5A)),
            ),
            const SizedBox(height: 16),
            ..._labels.map((e) {
              final f = files[e.key];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    if (f != null && f.isImage && f.bytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          f.bytes!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      const Icon(Icons.description, size: 40, color: Color(0xFF6B6B6B)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            f?.name ?? '—',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B6B6B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Back')),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B4DA8)),
          child: const Text('Confirm & Submit'),
        ),
      ],
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
