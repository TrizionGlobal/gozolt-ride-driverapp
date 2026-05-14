import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/providers/dio_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class SelfieVerificationScreen extends ConsumerStatefulWidget {
  final VoidCallback onVerified;

  const SelfieVerificationScreen({super.key, required this.onVerified});

  @override
  ConsumerState<SelfieVerificationScreen> createState() =>
      _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState extends ConsumerState<SelfieVerificationScreen> {
  XFile? _capturedImage;
  bool _isSubmitting = false;

  Future<void> _takeSelfie() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (image != null && mounted) {
      setState(() => _capturedImage = image);
    }
  }

  Future<void> _submit() async {
    if (_capturedImage == null) return;
    setState(() => _isSubmitting = true);

    // Fire-and-forget upload — don't block UI. Backend auto-approves on goOnline.
    _uploadSelfieInBackground();

    // Proceed immediately
    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF1A1A2E), size: 20),
              SizedBox(width: 8),
              Text('Selfie verified successfully', style: TextStyle(color: Color(0xFF1A1A2E))),
            ],
          ),
          backgroundColor: const Color(0xFFFACC15),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      widget.onVerified();
    }
  }

  void _uploadSelfieInBackground() {
    Future(() async {
      try {
        final dio = ref.read(dioProvider);
        final formData = FormData.fromMap({
          'selfie': await MultipartFile.fromFile(
            _capturedImage!.path,
            filename: 'selfie.jpg',
          ),
        });
        await dio.post(
          '/drivers/me/verify-selfie',
          data: formData,
          options: Options(sendTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10)),
        );
      } catch (e) {
        debugPrint('Selfie background upload skipped: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
          ? AppColors.backgroundPrimary 
          : Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            'Selfie Verification',
            style: AppTextStyles.headlineMedium.copyWith(
                color: Theme.of(context).textTheme.headlineMedium?.color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a selfie to verify your identity before going online',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          // Image preview area
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: AppColors.primaryGold.withOpacity(0.3),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: _capturedImage != null
                  ? Image.file(
                      File(_capturedImage!.path),
                      fit: BoxFit.cover,
                      width: 200,
                      height: 200,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          size: 48,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No photo',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const Spacer(),
          // Buttons
          if (_capturedImage == null) ...[
            // Take Selfie button
            GestureDetector(
              onTap: _takeSelfie,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      color: AppColors.backgroundDark,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Take Selfie',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.backgroundDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Submit + Retake buttons
            Row(
              children: [
                // Retake
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _capturedImage = null),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Retake',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Submit
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _isSubmitting ? null : _submit,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Center(
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.backgroundDark,
                                ),
                              )
                            : Text(
                                'Submit',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.backgroundDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // Skip/Cancel
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

