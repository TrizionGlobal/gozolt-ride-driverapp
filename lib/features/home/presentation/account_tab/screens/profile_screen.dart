import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../driver/presentation/providers/driver_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  File? _pickedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(driverProfileProvider).valueOrNull;
    _firstNameController = TextEditingController(text: profile?.firstName);
    _lastNameController = TextEditingController(text: profile?.lastName);
    _emailController = TextEditingController(text: profile?.email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();

    if (firstName.isEmpty) {
      _showSnackBar('First Name is required', isError: true);
      return;
    }

    if (lastName.isEmpty) {
      _showSnackBar('Last Name is required', isError: true);
      return;
    }

    if (email.isEmpty) {
      _showSnackBar('Email is required', isError: true);
      return;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      _showSnackBar('Please enter a valid email address', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    
    bool success = true;

    // 1. Upload picked image if present
    if (_pickedImage != null) {
      final uploadSuccess = await ref.read(driverProfileProvider.notifier).uploadAvatar(_pickedImage!.path);
      if (!uploadSuccess) {
        success = false;
      }
    }

    // 2. Update profile text details
    if (success) {
      final updateSuccess = await ref.read(driverProfileProvider.notifier).updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
      if (!updateSuccess) {
        success = false;
      }
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
        if (success) {
          _pickedImage = null; // Clear the picked image file after successful upload/save
        }
      });
      _showSnackBar(
        success ? 'Profile updated successfully' : 'Failed to update profile',
        isError: !success,
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(driverProfileProvider).valueOrNull;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Gold header (covers status bar completely) ──────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 16 + statusBarHeight, 16, 24),
            decoration: const BoxDecoration(
              color: AppColors.primaryGold,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundPrimary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.backgroundPrimary,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Driver Profile',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.backgroundPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // Avatar with camera icon
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primaryGold.withOpacity(0.2),
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!) as ImageProvider
                              : (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty
                                  ? NetworkImage(ApiConstants.fullUrl(profile.avatarUrl!)) as ImageProvider
                                  : null),
                          child: (_pickedImage == null && (profile?.avatarUrl == null || profile!.avatarUrl!.isEmpty))
                              ? const Icon(Icons.person, size: 50, color: AppColors.primaryGold)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGold,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(Icons.camera_alt, size: 16, color: AppColors.backgroundPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  
                  // Personal Info Form
                  _buildSectionHeader('Personal Information'),
                  _buildTextField('First Name', _firstNameController),
                  const SizedBox(height: 12),
                  _buildTextField('Last Name', _lastNameController),
                  const SizedBox(height: 12),
                  _buildTextField('Email', _emailController),
                  const SizedBox(height: 20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.backgroundPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.backgroundPrimary,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Vehicle Info (Read-only for security)
                  _buildSectionHeader('Vehicle Details'),
                  _buildInfoCard(
                    icon: Icons.directions_car_rounded,
                    label: 'Vehicle Type',
                    value: profile?.vehicle?.type ?? 'Car',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.numbers_rounded,
                    label: 'Vehicle Plate',
                    value: profile?.vehicle?.plate ?? 'XYZ 1234',
                  ),
                  const SizedBox(height: 32),

                  // Document Status
                  _buildSectionHeader('Verification Documents'),
                  _buildDocumentTile('Driving License', true),
                  const SizedBox(height: 12),
                  _buildDocumentTile('Vehicle Registration (RC)', true),
                  const SizedBox(height: 12),
                  _buildDocumentTile('CPC Certificate', true),
                  const SizedBox(height: 12),
                  _buildDocumentTile('Vehicle Insurance', true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        TextField(
          controller: controller,
          enabled: true,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primaryGold,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required IconData icon, required String label, required String value}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGold),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
              Text(value, style: AppTextStyles.titleSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(String title, bool isVerified) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: isVerified ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isVerified ? Icons.verified_rounded : Icons.pending_rounded, 
               color: isVerified ? Colors.green : Colors.orange),
          const SizedBox(width: 16),
          Text(title, style: AppTextStyles.bodyMedium),
          const Spacer(),
          Text(
            isVerified ? 'VERIFIED' : 'PENDING',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isVerified ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _pickedImage = File(image.path));
    }
  }
}
