import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gozolt_logo.dart';
import 'providers/registration_provider.dart';
import 'widgets/country_code_picker.dart';
import '../domain/models/country_code.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _picker = ImagePicker();

  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _vehicleNumberController;
  late final TextEditingController _aadhaarController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _vehicleNumberController = TextEditingController();
    _aadhaarController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _vehicleNumberController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  CountryCode _selectedCountry = supportedCountryCodes.first;

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

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final notifier = ref.read(registrationProvider.notifier);
      if (type == 'license') notifier.setLicensePath(image.path);
      if (type == 'profile') notifier.setProfileImage(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationProvider);
    final notifier = ref.read(registrationProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Driver Registration'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (state.currentStep > 0) {
              notifier.setStep(state.currentStep - 1);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index <= state.currentStep 
                        ? AppColors.primaryGold 
                        : AppColors.textMuted.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStep(state.currentStep),
            ),
          ),
          
          // Bottom button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : () async {
                  final error = _validateStep(state.currentStep, state);
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  if (state.currentStep < 2) {
                    notifier.setStep(state.currentStep + 1);
                  } else {
                    final success = await notifier.register();
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registration submitted for approval!')),
                      );
                      context.pop();
                    } else if (state.errorMessage != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage!),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
                child: state.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(state.currentStep < 2 ? 'Next' : 'Submit Registration'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateStep(int step, RegistrationState state) {
    if (step == 0) {
      if (state.request.fullName.trim().isEmpty) {
        return 'Please enter your Full Name';
      }
      if (state.request.email.trim().isEmpty) {
        return 'Please enter your Email Address';
      }
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(state.request.email.trim())) {
        return 'Please enter a valid Email Address';
      }
      if (state.request.phoneNumber.trim().isEmpty) {
        return 'Please enter your Phone Number';
      }
      if (state.request.password.trim().isEmpty) {
        return 'Please enter a Password';
      }
      if (state.request.password.length < 6) {
        return 'Password must be at least 6 characters long';
      }
    } else if (step == 1) {
      if (state.request.vehicleType.trim().isEmpty) {
        return 'Please select a Vehicle Type';
      }
      if (state.request.vehicleNumber.trim().isEmpty) {
        return 'Please enter your Vehicle Plate Number';
      }
    } else if (step == 2) {
      if (state.request.drivingLicensePath == null || state.request.drivingLicensePath!.isEmpty) {
        return 'Please upload your Driving License';
      }
      if (state.request.profileImagePath == null || state.request.profileImagePath!.isEmpty) {
        return 'Please upload your Profile Photo';
      }
      if (state.request.aadhaarNumber == null || state.request.aadhaarNumber!.trim().isEmpty) {
        return 'Please enter your Aadhaar / ID Number';
      }
    }
    return null;
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0: return _buildPersonalInfo();
      case 1: return _buildVehicleInfo();
      case 2: return _buildDocumentUploads();
      default: return const SizedBox();
    }
  }

  Widget _buildPersonalInfo() {
    final notifier = ref.read(registrationProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Personal Details', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 8),
        const Text('Tell us a bit about yourself', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 32),
        _buildTextField('Full Name', _fullNameController, (v) => notifier.setFullName(v)),
        const SizedBox(height: 16),
        _buildTextField('Email Address', _emailController, (v) => notifier.setEmail(v), keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Phone Number', style: AppTextStyles.titleSmall),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('Phone Number'),
              controller: _phoneController,
              onChanged: (v) {
                notifier.setPhoneNumber(_selectedCountry.dialCode + v);
              },
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '0000 0000',
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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
                        Text(
                          _selectedCountry.flag,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _selectedCountry.dialCode,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Password', _passwordController, (v) => notifier.setPassword(v), obscureText: true),
      ],
    );
  }

  Widget _buildVehicleInfo() {
    final state = ref.watch(registrationProvider);
    final notifier = ref.read(registrationProvider.notifier);
    final vehicles = [
      {'type': 'Economy', 'image': 'assets/images/icon_vehicle_standard.png'},
      {'type': 'Standard', 'image': 'assets/images/icon_vehicle_comfort.png'},
      {'type': 'Premium', 'image': 'assets/images/icon_vehicle_luxury.png'},
      {'type': 'XL', 'image': 'assets/images/icon_vehicle_xl.png'},
      {'type': 'Electric', 'image': 'assets/images/icon_vehicle_accessible.png'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vehicle Information', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 24),
        const Text('Select Vehicle Type', style: AppTextStyles.titleSmall),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.35,
          ),
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            final isSelected = state.request.vehicleType == vehicle['type'];
            return InkWell(
              onTap: () => notifier.setVehicleType(vehicle['type'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                    ? AppColors.primaryGold.withOpacity(0.1) 
                    : (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryGold : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      vehicle['image'] as String,
                      width: 60,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vehicle['type'] as String,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: isSelected ? AppColors.primaryGold : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        _buildTextField('Vehicle Number (Plate)', _vehicleNumberController, (v) => notifier.setVehicleNumber(v)),
      ],
    );
  }

  Widget _buildDocumentUploads() {
    final state = ref.watch(registrationProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Verification Documents', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 32),
        _buildUploadCard('Driving License', state.request.drivingLicensePath, () => _pickImage('license')),
        const SizedBox(height: 16),
        _buildUploadCard('Profile Photo', state.request.profileImagePath, () => _pickImage('profile')),
        const SizedBox(height: 16),
        _buildTextField('Aadhaar / ID Number', _aadhaarController, (v) => ref.read(registrationProvider.notifier).setAadhaar(v)),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    Function(String) onChanged, {
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        TextField(
          key: ValueKey(label),
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard(String label, String? path, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGold.withOpacity(0.3), style: BorderStyle.solid),
            ),
            child: path == null 
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, color: AppColors.primaryGold, size: 32),
                    SizedBox(height: 8),
                    Text('Tap to upload'),
                  ],
                )
              : Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(path), width: double.infinity, fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 8, top: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 14,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.close, size: 16, color: Colors.white),
                          onPressed: onTap,
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
