import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'providers/registration_provider.dart';
import 'widgets/country_code_picker.dart';
import 'widgets/otp_input_field.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../domain/models/country_code.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _picker = ImagePicker();

  // Step 0: OTP Verification
  late final TextEditingController _otpController;
  final _otpKey = GlobalKey<OtpInputFieldState>();


  // Step 2: Identity & Contact Info
  late final TextEditingController _fullNameController;
  late final TextEditingController _dobController;
  late final TextEditingController _nationalityController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _passwordController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _homeAddressController;
  late final TextEditingController _emergencyContactNameController;
  late final TextEditingController _emergencyContactPhoneController;

  // Step 3: Credentials
  late final TextEditingController _licenseNumberController;
  late final TextEditingController _licenseCategoryController;
  late final TextEditingController _licenseIssueDateController;
  late final TextEditingController _licenseExpiryDateController;
  late final TextEditingController _licenseIssuingCountryController;
  late final TextEditingController _cpcNumberController;
  late final TextEditingController _taxiPhvLicenseController;

  // Step 4: Vehicle & Insurance (Self-Owned only)
  late final TextEditingController _vehicleNumberController;
  late final TextEditingController _vehicleMakeController;
  late final TextEditingController _vehicleModelController;
  late final TextEditingController _vehicleYearController;
  late final TextEditingController _vehicleColorController;
  late final TextEditingController _insurancePolicyNumberController;

  CountryCode _selectedCountry = supportedCountryCodes.first;
  CountryCode _selectedEmergencyCountry = supportedCountryCodes.first;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();

    _fullNameController = TextEditingController();
    _dobController = TextEditingController();
    _nationalityController = TextEditingController();
    _nationalIdController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _homeAddressController = TextEditingController();
    _emergencyContactNameController = TextEditingController();
    _emergencyContactPhoneController = TextEditingController();

    _licenseNumberController = TextEditingController();
    _licenseCategoryController = TextEditingController();
    _licenseIssueDateController = TextEditingController();
    _licenseExpiryDateController = TextEditingController();
    _licenseIssuingCountryController = TextEditingController();
    _cpcNumberController = TextEditingController();
    _taxiPhvLicenseController = TextEditingController();

    _vehicleNumberController = TextEditingController();
    _vehicleMakeController = TextEditingController();
    _vehicleModelController = TextEditingController();
    _vehicleYearController = TextEditingController();
    _vehicleColorController = TextEditingController();
    _insurancePolicyNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();

    _fullNameController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _nationalIdController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _homeAddressController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();

    _licenseNumberController.dispose();
    _licenseCategoryController.dispose();
    _licenseIssueDateController.dispose();
    _licenseExpiryDateController.dispose();
    _licenseIssuingCountryController.dispose();
    _cpcNumberController.dispose();
    _taxiPhvLicenseController.dispose();

    _vehicleNumberController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _vehicleColorController.dispose();
    _insurancePolicyNumberController.dispose();
    super.dispose();
  }

  int get _totalSteps => 3;

  void _showCountryPicker() {
    CountryCodePicker.show(
      context,
      selected: _selectedCountry,
      onSelected: (country) {
        setState(() {
          _selectedCountry = country;
        });
        ref.read(registrationProvider.notifier).setPhoneNumber(country.dialCode + _phoneController.text);
      },
    );
  }

  void _showEmergencyCountryPicker() {
    CountryCodePicker.show(
      context,
      selected: _selectedEmergencyCountry,
      onSelected: (country) {
        setState(() {
          _selectedEmergencyCountry = country;
        });
        ref.read(registrationProvider.notifier).setEmergencyContactPhone(country.dialCode + _emergencyContactPhoneController.text);
      },
    );
  }

  void _showUploadSourceSheet({
    required String title,
    required Function(String path) onPicked,
    bool allowFiles = true,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryGold),
                ),
                title: const Text('Take a Photo', style: AppTextStyles.titleSmall),
                subtitle: const Text('Capture document scan using device camera', style: TextStyle(fontSize: 12)),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                  if (photo != null) onPicked(photo.path);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primaryGold),
                ),
                title: const Text('Choose from Gallery', style: AppTextStyles.titleSmall),
                subtitle: const Text('Select a pre-existing photo or scan', style: TextStyle(fontSize: 12)),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
                  if (photo != null) onPicked(photo.path);
                },
              ),
              if (allowFiles) ...[
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primaryGold),
                  ),
                  title: const Text('Upload PDF / Document File', style: AppTextStyles.titleSmall),
                  subtitle: const Text('Select a PDF, DOCX, or text file from device storage', style: TextStyle(fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
                      );
                      if (result != null && result.files.single.path != null) {
                        onPicked(result.files.single.path!);
                      }
                    } catch (e) {
                      debugPrint('Error picking file: $e');
                    }
                  },
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, String fieldType) async {
    String currentValue = '';
    if (fieldType == 'dob') currentValue = _dobController.text;
    else if (fieldType == 'licenseIssue') currentValue = _licenseIssueDateController.text;
    else if (fieldType == 'licenseExpiry') currentValue = _licenseExpiryDateController.text;

    DateTime initialDate = DateTime.now();
    if (currentValue.isNotEmpty) {
      try {
        initialDate = DateTime.parse(currentValue);
      } catch (e) {
        // Fallback to now
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: DateTime(2040),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primaryGold,
                    onPrimary: Colors.black,
                    surface: Color(0xFF1E2124),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primaryGold,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      final notifier = ref.read(registrationProvider.notifier);
      setState(() {
        if (fieldType == 'dob') {
          _dobController.text = formatted;
          notifier.setDateOfBirth(formatted);
        } else if (fieldType == 'licenseIssue') {
          _licenseIssueDateController.text = formatted;
          notifier.setLicenseIssueDate(formatted);
        } else if (fieldType == 'licenseExpiry') {
          _licenseExpiryDateController.text = formatted;
          notifier.setLicenseExpiryDate(formatted);
        }
      });
    }
  }

  String _getStepTitle(int step, String driverType) {
    switch (step) {
      case 0:
        return 'OTP Verification';
      case 1:
        return 'Identity & Contact';
      case 2:
        return 'Licences & Credentials';
      default:
        return '';
    }
  }

  Future<void> _handleBack(RegistrationState state, RegistrationNotifier notifier) async {
    if (state.currentStep > 0) {
      notifier.setStep(state.currentStep - 1);
    } else {
      if (state.isOtpSent) {
        final shouldExit = await _showExitConfirmationDialog();
        if (shouldExit == true) {
          notifier.resetOtp();
          if (mounted) {
            context.go(RouteNames.welcome);
          }
        }
      } else {
        if (mounted) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteNames.welcome);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationProvider);
    final notifier = ref.read(registrationProvider.notifier);
    final totalSteps = _totalSteps;

    final isButtonEnabled = () {
      if (state.isLoading) return false;
      if (state.currentStep == 0) {
        if (!state.isOtpSent) {
          return _phoneController.text.trim().length >= 8;
        } else if (!state.isOtpVerified) {
          return _otpController.text.trim().length == 6;
        }
      }
      return true;
    }();

    ref.listen<RegistrationState>(registrationProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        if (next.currentStep == 0 && next.isOtpSent && !next.isOtpVerified) {
          _otpKey.currentState?.shake();
        }
      }
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleBack(state, notifier);
      },
      child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _getStepTitle(state.currentStep, state.request.driverType),
          style: AppTextStyles.titleMedium,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => _handleBack(state, notifier),
        ),
      ),
      body: Column(
        children: [
          // Step progress indicator bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Step ${state.currentStep + 1} of $totalSteps', style: AppTextStyles.titleSmall.copyWith(color: AppColors.primaryGold)),
                    Text(
                      _getStepTitle(state.currentStep, state.request.driverType),
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(totalSteps, (index) {
                    return Expanded(
                      child: Container(
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: index <= state.currentStep 
                            ? AppColors.primaryGold 
                            : AppColors.textMuted.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStep(state.currentStep, state, notifier),
              ),
            ),
          ),
          
          // Bottom Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: isButtonEnabled ? AppColors.primaryGold : AppColors.primaryGold.withOpacity(0.3),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: isButtonEnabled ? () => _handleContinue(state, notifier) : null,
                    child: state.isLoading 
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          _getButtonText(state, totalSteps),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  String _getButtonText(RegistrationState state, int totalSteps) {
    if (state.currentStep == 0) {
      if (!state.isOtpSent) return 'Send Verification Code';
      if (!state.isOtpVerified) return 'Verify Code';
      return 'Continue';
    }
    return state.currentStep < totalSteps - 1 ? 'Continue' : 'Submit Registration';
  }

  Future<void> _handleContinue(RegistrationState state, RegistrationNotifier notifier) async {
    // 1. Validation and action for Step 0 (OTP)
    if (state.currentStep == 0) {
      if (_phoneController.text.trim().isEmpty) {
        _showError('Please enter your phone number');
        return;
      }
      if (!state.isOtpSent) {
        final phone = _selectedCountry.dialCode + _phoneController.text.trim();
        final success = await notifier.sendRegisterOtp(phone);
        if (success && mounted) {
          SnackbarUtils.showSuccess(context, 'OTP sent successfully!');
        } else if (!success && mounted) {
          final errorMsg = ref.read(registrationProvider).errorMessage ?? 'Failed to send OTP';
          final isAlreadyRegistered = errorMsg.toLowerCase().contains('already registered') ||
              errorMsg.toLowerCase().contains('pending approval');
          if (isAlreadyRegistered) {
            _showAlreadyRegisteredDialog();
          } else {
            _showError(errorMsg);
          }
        }
        return;
      } else if (!state.isOtpVerified) {
        if (_otpController.text.trim().length < 6) {
          _showError('Please enter a valid 6-digit code');
          return;
        }
        final phone = _selectedCountry.dialCode + _phoneController.text.trim();
        final success = await notifier.verifyRegisterOtp(phone, _otpController.text.trim());
        if (success && mounted) {
          SnackbarUtils.showSuccess(context, 'Phone number verified!');
          notifier.setStep(1);
        } else if (!success && mounted) {
          _showError(ref.read(registrationProvider).errorMessage ?? 'Invalid OTP');
        }
        return;
      } else {
        notifier.setStep(1);
        return;
      }
    }

    // 2. Common step validation
    final error = _validateStep(state.currentStep, state);
    if (error != null) {
      _showError(error);
      return;
    }

    // 3. Move forward or submit
    final totalSteps = _totalSteps;
    if (state.currentStep < totalSteps - 1) {
      notifier.setStep(state.currentStep + 1);
    } else {
      final success = await notifier.register();
      if (success && mounted) {
        context.go(
          RouteNames.registrationStatus,
          extra: {
            'isFleet': state.request.driverType == 'FLEET',
            'phone': _selectedCountry.dialCode + _phoneController.text.trim(),
          },
        );
      } else if (!success && mounted) {
        final errorMsg = ref.read(registrationProvider).errorMessage ?? 'Registration failed';
        final isAlreadyRegistered = errorMsg.toLowerCase().contains('already registered') ||
            errorMsg.toLowerCase().contains('pending approval');
        if (isAlreadyRegistered) {
          _showAlreadyRegisteredDialog();
        }
      }
    }
  }

  void _showAlreadyRegisteredDialog() {
    ref.read(registrationProvider.notifier).clearError();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Color(0xFFFFC107), size: 28),
            SizedBox(width: 10),
            Text('Already Registered', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: const Text(
          'You have already registered as a driver.\n\nPlease wait for your supplier to approve your account. You will receive a notification once approved.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(RouteNames.welcome);
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit Registration?'),
        content: const Text(
          'Are you sure you want to go back? Your OTP verification code will expire and you will need to request a new one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Exit', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    SnackbarUtils.showError(context, message);
  }

  String? _validateStep(int step, RegistrationState state) {
    final isFleet = state.request.driverType == 'FLEET';
    switch (step) {
      case 0:
        if (!state.isOtpVerified) return 'Please verify your phone number via OTP first';
        break;
      case 1: // Identity & Contact Details
        if (state.request.fullName.trim().isEmpty) return 'Please enter your full legal name';
        if (state.request.dateOfBirth == null || state.request.dateOfBirth!.isEmpty) return 'Please select your Date of Birth';
        if (state.request.nationality == null || state.request.nationality!.isEmpty) return 'Please enter your Nationality';
        if (state.request.nationalId == null || state.request.nationalId!.isEmpty) return 'Please enter your Passport/National ID';
        if (!isFleet) {
          if (state.request.password == null || state.request.password!.trim().isEmpty) return 'Please enter a Password';
          if (state.request.password!.length < 6) return 'Password must be at least 6 characters';
        }
        if (state.request.profileImagePath?.isEmpty ?? true) return 'Please upload your verification Profile Photo (Selfie)';
        if (state.request.email.trim().isEmpty) return 'Please enter your email address';
        if (state.request.homeAddress == null || state.request.homeAddress!.isEmpty) return 'Please enter your home address';
        if (state.request.emergencyContactName == null || state.request.emergencyContactName!.isEmpty) return 'Emergency contact name is required';
        if (state.request.emergencyContactPhone == null || state.request.emergencyContactPhone!.isEmpty) return 'Emergency contact phone number is required';
        break;
      case 2: // Credentials
        if (state.request.licenseNumber == null || state.request.licenseNumber!.isEmpty) return 'Please enter your driver licence number';
        if (state.request.licenseCategory == null || state.request.licenseCategory!.isEmpty) return 'Please select licence category';
        if (state.request.licenseIssueDate == null || state.request.licenseIssueDate!.isEmpty) return 'Please select licence issue date';
        if (state.request.licenseExpiryDate == null || state.request.licenseExpiryDate!.isEmpty) return 'Please select licence expiry date';
        if (state.request.licenseIssuingCountry == null || state.request.licenseIssuingCountry!.isEmpty) return 'Please enter licence issuing country';
        if (state.request.cpcCertificateNumber == null || state.request.cpcCertificateNumber!.isEmpty) return 'CPC Certificate number is required';
        if (state.request.cpcDocumentPath?.isEmpty ?? true) return 'Please upload scan of your CPC Certificate card';
        if (state.request.drivingLicensePath?.isEmpty ?? true) return 'Please upload your primary Driving License scan';
        if (state.request.drivingLicenseBackPath?.isEmpty ?? true) return 'Please upload your Driving License (Back) scan';
        break;
      case 4: // Vehicle details (Self-Owned only)
        if (!isFleet) {
          if (state.request.vehicleType == null || state.request.vehicleType!.trim().isEmpty) return 'Please select a Vehicle Type';
          if (state.request.vehicleNumber == null || state.request.vehicleNumber!.trim().isEmpty) return 'Please enter your vehicle plate number';
          if (state.request.insurancePolicyNumber == null || state.request.insurancePolicyNumber!.isEmpty) return 'Insurance policy number is required';
          if (state.request.insuranceDocumentPath?.isEmpty ?? true) return 'Please upload your third-party vehicle insurance document';
        }
        break;
    }
    return null;
  }

  Widget _buildStep(int step, RegistrationState state, RegistrationNotifier notifier) {
    switch (step) {
      case 0: return _buildOtpStep(state, notifier);
      case 1: return _buildIdentityContactStep(state, notifier);
      case 2: return _buildCredentialsStep(state, notifier);
      default: return const SizedBox();
    }
  }

  Widget _buildOtpStep(RegistrationState state, RegistrationNotifier notifier) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phone Verification', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 8),
        const Text('Enter your mobile number to receive a verification OTP. This verifies your device identity.', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 24),
        
        // Phone number input
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mobile number', style: AppTextStyles.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              enabled: !state.isOtpSent,
              onChanged: (v) {
                notifier.setPhoneNumber(_selectedCountry.dialCode + v);
              },
              keyboardType: TextInputType.phone,
              maxLength: 10,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Enter Mobile Number',
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: GestureDetector(
                  onTap: state.isOtpSent ? null : _showCountryPicker,
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
                        if (!state.isOtpSent) const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        if (state.isOtpSent) ...[
          const SizedBox(height: 24),
          const SizedBox(height: 16),
          const Text('Enter 6-Digit Verification Code', style: AppTextStyles.titleSmall),
          const SizedBox(height: 8),
          OtpInputField(
            key: _otpKey,
            length: 6,
            enabled: !state.isOtpVerified,
            hasError: state.errorMessage != null,
            initialValue: _otpController.text,
            onChanged: (otp) {
              _otpController.text = otp;
              setState(() {});
            },
            onCompleted: (otp) {
              _otpController.text = otp;
              setState(() {});
            },
          ),

        ],

        if (state.isOtpVerified) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Phone number verified successfully!',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }


  Widget _buildIdentityContactStep(RegistrationState state, RegistrationNotifier notifier) {
    final isFleet = state.request.driverType == 'FLEET';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Personal details', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 8),
        
        // Profile photo card
        _buildSelfieUploadCard('Profile Photo', state.request.profileImagePath, () {
          _showUploadSourceSheet(
            title: 'Upload Selfie Photo',
            allowFiles: false,
            onPicked: (path) => notifier.setProfileImage(path),
          );
        }),
        const SizedBox(height: 24),
        
        _buildTextField('Full Legal Name', _fullNameController, (v) => notifier.setFullName(v), hintText: 'Enter name exactly as on passport'),
        const SizedBox(height: 16),
        
        // Date of birth
        _buildDatePickerField('Date of Birth', _dobController, () => _selectDate(context, 'dob')),
        const SizedBox(height: 16),
        
        _buildTextField('Nationality / Country of Residence', _nationalityController, (v) {
          notifier.setNationality(v);
          notifier.setCountryOfResidence(v);
        }, hintText: 'e.g. Malta'),
        const SizedBox(height: 16),
        
        _buildTextField('National ID or Passport number', _nationalIdController, (v) {
          notifier.setNationalId(v);
          notifier.setAadhaar(v);
        }, hintText: 'e.g. MT984210A'),
        const SizedBox(height: 16),

        if (!isFleet) ...[
          _buildTextField('Account Password', _passwordController, (v) => notifier.setPassword(v), obscureText: true, hintText: 'Minimum 6 characters'),
          const SizedBox(height: 16),
        ],

        _buildTextField('Email Address', _emailController, (v) => notifier.setEmail(v), keyboardType: TextInputType.emailAddress, hintText: 'name@example.com'),
        const SizedBox(height: 16),

        _buildTextField('Home address', _homeAddressController, (v) => notifier.setHomeAddress(v), maxLines: 2, hintText: 'Complete residential address'),
        const SizedBox(height: 24),
        
        
        _buildTextField('Emergency contact name', _emergencyContactNameController, (v) => notifier.setEmergencyContactName(v), hintText: 'e.g. Spouse/Parent Name'),
        const SizedBox(height: 16),
        
        _buildTextField(
          'Emergency contact phone number',
          _emergencyContactPhoneController,
          (v) => notifier.setEmergencyContactPhone(_selectedEmergencyCountry.dialCode + v),
          keyboardType: TextInputType.phone,
          hintText: 'Enter Mobile Number',
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          prefixIcon: GestureDetector(
            onTap: _showEmergencyCountryPicker,
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
                  Text(_selectedEmergencyCountry.flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 4),
                  Text(_selectedEmergencyCountry.dialCode, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCredentialsStep(RegistrationState state, RegistrationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Driver Credentials', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 8),
        const Text('Please verify your professional transport credentials.', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 24),
        
        _buildTextField("Driver's licence number", _licenseNumberController, (v) => notifier.setLicenseNumber(v), hintText: 'e.g. DL-123456-MT'),
        const SizedBox(height: 16),
        
        _buildTextField("Licence category (B/B+E/D etc.)", _licenseCategoryController, (v) => notifier.setLicenseCategory(v), hintText: 'e.g. B (Manual/Automatic)'),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(child: _buildDatePickerField('Licence Issue Date', _licenseIssueDateController, () => _selectDate(context, 'licenseIssue'))),
            const SizedBox(width: 16),
            Expanded(child: _buildDatePickerField('Licence Expiry Date', _licenseExpiryDateController, () => _selectDate(context, 'licenseExpiry'))),
          ],
        ),
        const SizedBox(height: 16),
        
        _buildTextField("Licence issuing country", _licenseIssuingCountryController, (v) => notifier.setLicenseIssuingCountry(v), hintText: 'e.g. Malta'),
        const SizedBox(height: 24),
        
        const SizedBox(height: 12),
        
        _buildTextField("Professional Competence Certificate (CPC)", _cpcNumberController, (v) => notifier.setCpcCertificateNumber(v), hintText: 'CPC Card Cardholder Number'),
        const SizedBox(height: 16),
        
        _buildTextField("Taxi/PHV licence number (if applicable)", _taxiPhvLicenseController, (v) => notifier.setTaxiPhvLicenseNumber(v), hintText: 'e.g. PHV-MT-9042', isRequired: false),
        const SizedBox(height: 24),
        
        _buildUploadCard('Passport / National ID Card', state.request.idCardDocumentPath, () {
          _showUploadSourceSheet(
            title: 'Upload Passport / ID Card',
            onPicked: (path) => notifier.setIdCardDocumentPath(path),
          );
        }, onRemove: () => notifier.setIdCardDocumentPath("")),
        const SizedBox(height: 16),
        
        _buildUploadCard("Driving License (Front)", state.request.drivingLicensePath, () {
          _showUploadSourceSheet(
            title: "Upload Driving License (Front)",
            onPicked: (path) => notifier.setLicensePath(path),
          );
        }, onRemove: () => notifier.setLicensePath("")),
        const SizedBox(height: 16),
        
        _buildUploadCard("Driving License (Back)", state.request.drivingLicenseBackPath, () {
          _showUploadSourceSheet(
            title: "Upload Driving License (Back)",
            onPicked: (path) => notifier.setLicenseBackPath(path),
          );
        }, onRemove: () => notifier.setLicenseBackPath("")),
        const SizedBox(height: 16),
        
        _buildUploadCard('Passenger Transport Driver Permit / Taxi Driver Permit', state.request.cpcDocumentPath, () {
          _showUploadSourceSheet(
            title: 'Upload Transport/Taxi Permit',
            onPicked: (path) => notifier.setCpcDocumentPath(path),
          );
        }, onRemove: () => notifier.setCpcDocumentPath("")),
        const SizedBox(height: 16),
        
        _buildUploadCard('Police Conduct Certificate', state.request.policeConductDocumentPath, () {
          _showUploadSourceSheet(
            title: 'Upload Police Conduct',
            onPicked: (path) => notifier.setPoliceConductDocumentPath(path),
          );
        }, onRemove: () => notifier.setPoliceConductDocumentPath("")),
        const SizedBox(height: 16),
        
        _buildUploadCard('Proof of Address (Utility Bill / Bank Statement)', state.request.proofOfAddressDocumentPath, () {
          _showUploadSourceSheet(
            title: 'Upload Proof of Address',
            onPicked: (path) => notifier.setProofOfAddressDocumentPath(path),
          );
        }, onRemove: () => notifier.setProofOfAddressDocumentPath("")),
        const SizedBox(height: 16),
        
        _buildUploadCard('Medical Fitness Certificate', state.request.medicalCertificateDocumentPath, () {
          _showUploadSourceSheet(
            title: 'Upload Medical Certificate',
            onPicked: (path) => notifier.setMedicalCertificateDocumentPath(path),
          );
        }, onRemove: () => notifier.setMedicalCertificateDocumentPath("")),
        const SizedBox(height: 16),
        
        _buildUploadCard('Work Permit / Residence Permit (Only for Non-EU Drivers)', state.request.workPermitDocumentPath, () {
          _showUploadSourceSheet(
            title: 'Upload Work/Residence Permit',
            onPicked: (path) => notifier.setWorkPermitDocumentPath(path),
          );
        }, isRequired: false, onRemove: () => notifier.setWorkPermitDocumentPath("")),
        const SizedBox(height: 16),
        // --- Extra Documents ---
        const Text('Additional Documents (Optional)', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        ...state.request.extraDocuments.asMap().entries.map((entry) {
          final int idx = entry.key;
          final Map<String, String> doc = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: doc['name'],
                        onChanged: (v) => notifier.updateExtraDocumentName(idx, v),
                        decoration: InputDecoration(
                          hintText: 'Document Name',
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () => notifier.removeExtraDocument(idx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildUploadCard('Upload scan', doc['path']?.isEmpty == true ? null : doc['path'], () {
                  _showUploadSourceSheet(
                    title: 'Upload ${doc['name']?.isEmpty == true ? "Document" : doc['name']}',
                    onPicked: (path) => notifier.updateExtraDocumentPath(idx, path),
                  );
                }, isRequired: false, onRemove: () => notifier.updateExtraDocumentPath(idx, "")),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => notifier.addExtraDocument(),
          icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryGold),
          label: const Text('Add Document', style: TextStyle(color: AppColors.primaryGold)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }



  Widget _buildTextField(
    String label,
    TextEditingController controller,
    Function(String) onChanged, {
    TextInputType? keyboardType,
    bool obscureText = false,
    String? hintText,
    int maxLines = 1,
    bool isRequired = true,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.titleSmall.copyWith(color: isDark ? Colors.white : Colors.black87),
            children: [
              if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: ValueKey(label),
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller, VoidCallback onTap, {bool isRequired = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.titleSmall.copyWith(color: isDark ? Colors.white : Colors.black87),
            children: [
              if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'YYYY-MM-DD',
            hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.black38),
            filled: true,
            fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: const Icon(Icons.calendar_today_rounded, color: AppColors.primaryGold, size: 20),
          ),
        ),
      ],
    );
  }

  bool _isImageFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.png') || ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.webp') || ext.endsWith('.gif');
  }

  Widget _buildSelfieUploadCard(String label, String? path, VoidCallback onTap, {bool isRequired = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.titleSmall.copyWith(color: isDark ? Colors.white : Colors.black87),
            children: [
              if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(55),
            child: Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryGold, width: 2),
              ),
              child: path == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.face_retouching_natural_rounded, color: AppColors.primaryGold, size: 32),
                        SizedBox(height: 4),
                        Text('Selfie', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : ClipOval(
                      child: Image.file(File(path), width: 110, height: 110, fit: BoxFit.cover),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard(String label, String? path, VoidCallback onTap, {VoidCallback? onRemove, bool isRequired = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isEmpty = path == null || path.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.titleSmall.copyWith(color: isDark ? Colors.white : Colors.black87),
            children: [
              if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isEmpty ? onTap : null,
          child: Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGold.withOpacity(0.3), style: BorderStyle.solid),
            ),
            child: isEmpty 
              ? InkWell(
                  onTap: onTap,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, color: AppColors.primaryGold, size: 28),
                      SizedBox(height: 8),
                      Text('Tap to upload document scan'),
                    ],
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    _isImageFile(path)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(File(path), width: double.infinity, height: 110, fit: BoxFit.cover),
                          )
                        : Container(
                            width: double.infinity,
                            height: 110,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    path.toLowerCase().endsWith('.pdf') 
                                        ? Icons.picture_as_pdf_rounded 
                                        : Icons.description_rounded,
                                    color: AppColors.primaryGold,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        path.split('/').last,
                                        style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Document uploaded',
                                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 32),
                              ],
                            ),
                          ),
                    if (_isImageFile(path))
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                          ),
                          child: Text(
                            path.split('/').last,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    Positioned(
                      right: 8, top: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 14,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.close, size: 16, color: Colors.white),
                          onPressed: onRemove ?? onTap,
                        ),
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ],
    );
  }
}
