import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../driver/presentation/providers/driver_provider.dart';

final _profileImageProvider = StateProvider<File?>((ref) => null);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(driverProfileProvider).valueOrNull;
    final pickedImage = ref.watch(_profileImageProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Gold header ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        'Profile',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.backgroundPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppColors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Avatar with camera button
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.white,
                        backgroundImage: pickedImage != null
                            ? FileImage(pickedImage) as ImageProvider<Object>
                            : (profile?.avatarUrl != null
                                ? NetworkImage(profile!.avatarUrl!) as ImageProvider<Object>
                                : null),
                        child: pickedImage == null &&
                                profile?.avatarUrl == null
                            ? Text(
                                profile != null
                                    ? '${profile.firstName.isNotEmpty ? profile.firstName[0] : ''}${profile.lastName.isNotEmpty ? profile.lastName[0] : ''}'
                                    : 'D',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryGold,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () =>
                              _showImagePickerSheet(context, ref),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundPrimary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryGold,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: AppColors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Read-only fields ─────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  children: [
                    _ReadOnlyField(
                      label: 'First Name',
                      value: profile?.firstName ?? '',
                    ),
                    const SizedBox(height: 16),
                    _ReadOnlyField(
                      label: 'Last Name',
                      value: profile?.lastName ?? '',
                    ),
                    const SizedBox(height: 16),
                    _ReadOnlyField(
                      label: 'Number',
                      value: profile?.phone ?? '',
                      prefix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 12),
                          Text(
                            '\u{1F1F2}\u{1F1F9}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 24,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ReadOnlyField(
                      label: 'Email',
                      value: profile?.email ?? '',
                    ),
                    const SizedBox(height: 32),

                    // ── Edit? Contact Supplier ─────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Edit request sent to your supplier',
                              ),
                              backgroundColor: AppColors.primaryGold,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: AppColors.backgroundPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Edit? Contact Supplier',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
    );
  }

  void _showImagePickerSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Update Profile Photo',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.backgroundPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primaryGold,
                  ),
                ),
                title: Text(
                  'Take a Selfie',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.backgroundPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Use camera to take a photo',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ref, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primaryGold,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.backgroundPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Select an existing photo',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ref, ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null) {
      ref.read(_profileImageProvider.notifier).state = File(picked.path);
    }
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final Widget? prefix;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: prefix != null
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: prefix != null
              ? Row(
                  children: [
                    prefix!,
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          value,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.backgroundPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.backgroundPrimary,
                  ),
                ),
        ),
      ],
    );
  }
}

