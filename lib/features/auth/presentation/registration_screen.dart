import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gozolt_logo.dart';
import '../providers/registration_provider.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _picker = ImagePicker();

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
                  if (state.currentStep < 2) {
                    notifier.setStep(state.currentStep + 1);
                  } else {
                    final success = await notifier.register();
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registration submitted for approval!')),
                      );
                      context.pop();
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
        _buildTextField('Full Name', (v) => notifier.setFullName(v)),
        const SizedBox(height: 16),
        _buildTextField('Email Address', (v) => notifier.setEmail(v), keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildTextField('Phone Number', (v) => notifier.setPhoneNumber(v), keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _buildTextField('Password', (v) => notifier.setPassword(v), obscureText: true),
      ],
    );
  }

  Widget _buildVehicleInfo() {
    final state = ref.watch(registrationProvider);
    final notifier = ref.read(registrationProvider.notifier);
    final vehicles = [
      {'type': 'Car', 'icon': Icons.directions_car_rounded},
      {'type': 'Bike', 'icon': Icons.directions_bike_rounded},
      {'type': 'Scooter', 'icon': Icons.moped_rounded},
      {'type': 'Van', 'icon': Icons.airport_shuttle_rounded},
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
            childAspectRatio: 1.5,
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
                    Icon(
                      vehicle['icon'] as IconData,
                      color: isSelected ? AppColors.primaryGold : AppColors.textMuted,
                      size: 32,
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
        _buildTextField('Vehicle Number (Plate)', (v) => notifier.setVehicleNumber(v)),
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
        _buildTextField('Aadhaar / ID Number', (v) => ref.read(registrationProvider.notifier).setAadhaar(v)),
      ],
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged, {TextInputType? keyboardType, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        TextField(
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
