import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../driver/presentation/providers/driver_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/utils/snackbar_utils.dart';
import '../../../../auth/domain/models/country_code.dart';
import '../../../../auth/presentation/widgets/country_code_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _pickedImage;
  bool _isAvatarRemoved = false;
  bool _isSaving = false;
  String? _emailError;
  CountryCode _selectedCountry = supportedCountryCodes.first;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(driverProfileProvider).valueOrNull;
    _firstNameController = TextEditingController(text: profile?.firstName);
    _lastNameController = TextEditingController(text: profile?.lastName);
    _emailController = TextEditingController(text: profile?.email);
    
    // Parse phone to find matching country code
    String rawPhone = profile?.phone ?? '';
    if (rawPhone.startsWith('+')) {
      for (final code in supportedCountryCodes) {
        if (rawPhone.startsWith(code.dialCode)) {
          _selectedCountry = code;
          rawPhone = rawPhone.substring(code.dialCode.length);
          break;
        }
      }
    }
    _phoneController = TextEditingController(text: rawPhone);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phoneLocal = _phoneController.text.trim();
    final fullPhone = phoneLocal.isEmpty ? '' : '${_selectedCountry.dialCode}$phoneLocal';

    if (firstName.isEmpty) {
      _showSnackBar('First Name is required', isError: true);
      return;
    }

    if (lastName.isEmpty) {
      _showSnackBar('Last Name is required', isError: true);
      return;
    }

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      _showSnackBar('Email is required', isError: true);
      return;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      setState(() => _emailError = 'Please enter a valid email address');
      _showSnackBar('Please enter a valid email address', isError: true);
      return;
    }

    if (email.endsWith('@gmai.com') || email.endsWith('@gmail.co')) {
      setState(() => _emailError = 'Did you mean @gmail.com?');
      _showSnackBar('Please enter a valid email address', isError: true);
      return;
    }
    
    setState(() => _emailError = null);

    if (phoneLocal.isEmpty) {
      _showSnackBar('Mobile Number is required', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    
    bool success = true;

    // 1. Upload picked image or delete it if removed
    if (_pickedImage != null) {
      final uploadSuccess = await ref.read(driverProfileProvider.notifier).uploadAvatar(_pickedImage!.path);
      if (!uploadSuccess) {
        success = false;
      }
    } else if (_isAvatarRemoved) {
      final deleteSuccess = await ref.read(driverProfileProvider.notifier).deleteAvatar();
      if (!deleteSuccess) {
        success = false;
      }
    }

    // 2. Update profile text details
    String? updateError;
    if (success) {
      updateError = await ref.read(driverProfileProvider.notifier).updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: fullPhone,
      );
      if (updateError != null) {
        success = false;
      }
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
        if (success) {
          _isAvatarRemoved = false; // reset the flag after successful save
        }
      });
      _showSnackBar(
        success ? 'Profile updated successfully' : (updateError ?? 'Failed to update profile'),
        isError: !success,
      );
    }
  }

  void _showCountryPicker() {
    CountryCodePicker.show(
      context,
      selected: _selectedCountry,
      onSelected: (country) {
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (isError) {
      SnackbarUtils.showError(context, message);
    } else {
      SnackbarUtils.showSuccess(context, message);
    }
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
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGold.withOpacity(0.2),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _pickedImage != null
                              ? Image.file(_pickedImage!, fit: BoxFit.cover)
                              : _isAvatarRemoved
                                  ? const Icon(Icons.person, size: 50, color: AppColors.primaryGold)
                                  : (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty)
                                      ? CachedNetworkImage(
                                          imageUrl: ApiConstants.fullUrl(profile.avatarUrl!),
                                          fit: BoxFit.cover,
                                          errorListener: (err) {},
                                          errorWidget: (context, url, error) => const Icon(Icons.person, size: 50, color: AppColors.primaryGold),
                                          placeholder: (context, url) => const Icon(Icons.person, size: 50, color: AppColors.primaryGold),
                                        )
                                      : const Icon(Icons.person, size: 50, color: AppColors.primaryGold),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showAvatarOptions(context),
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
                  _buildTextField(
                    'Email', 
                    _emailController,
                    errorText: _emailError,
                    onChanged: (val) {
                      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      setState(() {
                        if (val.isEmpty) {
                          _emailError = 'Email is required';
                        } else if (!emailRegExp.hasMatch(val)) {
                          _emailError = 'Please enter a valid email address';
                        } else if (val.endsWith('@gmai.com') || val.endsWith('@gmail.co')) {
                          _emailError = 'Did you mean @gmail.com?';
                        } else {
                          _emailError = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Mobile Number', 
                    _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    prefixIcon: GestureDetector(
                      onTap: _showCountryPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Theme.of(context).dividerColor.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_selectedCountry.flag, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 4),
                            Text(_selectedCountry.dialCode, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
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

                  // Supplier Info
                  _buildSectionHeader('Supplier Details'),
                  if (profile?.supplier != null) ...[
                    _buildInfoCard(
                      icon: Icons.business_rounded,
                      label: 'Company Name',
                      value: profile!.supplier!.companyName,
                    ),
                    if (profile.supplier!.contactPhone != null || profile.supplier!.email != null)
                      const SizedBox(height: 12),
                    if (profile.supplier!.contactPhone != null)
                      _buildInfoCard(
                        icon: Icons.phone_rounded,
                        label: 'Contact Phone',
                        value: profile.supplier!.contactPhone!,
                      ),
                    if (profile.supplier!.contactPhone != null && profile.supplier!.email != null)
                      const SizedBox(height: 12),
                    if (profile.supplier!.email != null)
                      _buildInfoCard(
                        icon: Icons.email_rounded,
                        label: 'Email',
                        value: profile.supplier!.email!,
                      ),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text('No supplier assigned.', style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Vehicle Info (Read-only for security)
                  _buildSectionHeader('Vehicle Details'),
                  if (profile?.vehicle != null) ...[
                    _buildInfoCard(
                      icon: Icons.directions_car_rounded,
                      label: 'Make',
                      value: profile!.vehicle!.make.isNotEmpty ? profile.vehicle!.make : 'N/A',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.car_repair_rounded,
                      label: 'Model',
                      value: profile.vehicle!.model.isNotEmpty ? profile.vehicle!.model : 'N/A',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.color_lens_rounded,
                      label: 'Color',
                      value: profile.vehicle!.color.isNotEmpty ? profile.vehicle!.color : 'N/A',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.class_rounded,
                      label: 'Vehicle Type',
                      value: profile.vehicle!.type.isNotEmpty ? profile.vehicle!.type : 'N/A',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.numbers_rounded,
                      label: 'Vehicle Plate',
                      value: profile.vehicle!.plate.isNotEmpty ? profile.vehicle!.plate : 'N/A',
                    ),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text('No vehicle assigned yet.', style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Document Status
                  _buildSectionHeader('Verification Documents'),
                  if (profile != null && profile.documents.isNotEmpty)
                    ...profile.documents.map((doc) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildDocumentTile(
                            doc.uploadedName ?? doc.type.replaceAll('_', ' '),
                            doc.status == 'APPROVED',
                            doc.fileUrl,
                          ),
                        ))
                  else
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text('No documents uploaded yet.', style: TextStyle(color: Colors.grey)),
                    ),
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

  Widget _buildTextField(
    String label, 
    TextEditingController controller, {
    Widget? prefixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
    Function(String)? onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark ? Colors.white.withOpacity(0.05) : Theme.of(context).cardColor;
    final borderColor = Theme.of(context).dividerColor.withOpacity(0.1);

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
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
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
    final fillColor = isDark ? Colors.white.withOpacity(0.05) : Theme.of(context).cardColor;
    final borderColor = Theme.of(context).dividerColor.withOpacity(0.1);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
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

  Widget _buildDocumentTile(String title, bool isVerified, String url) {
    return GestureDetector(
      onTap: () async {
        if (url.isNotEmpty) {
          final uri = Uri.parse(ApiConstants.fullUrl(url));
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            _showSnackBar('Could not open document', isError: true);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: isVerified ? AppColors.success.withOpacity(0.3) : AppColors.warning.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(isVerified ? Icons.verified_rounded : Icons.pending_rounded, 
                 color: isVerified ? AppColors.success : AppColors.warning),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title, 
                style: AppTextStyles.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              isVerified ? 'VERIFIED' : 'PENDING',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isVerified ? AppColors.success : AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerTheme.color ?? Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primaryGold),
                title: Text('Take Photo', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primaryGold),
                title: Text('Choose from Gallery', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: Text('Remove Photo',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _pickedImage = null;
                    _isAvatarRemoved = true;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 400, maxHeight: 400, imageQuality: 50);
    if (image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: AppColors.primaryGold,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _pickedImage = File(croppedFile.path);
          _isAvatarRemoved = false;
        });
      }
    }
  }
}
