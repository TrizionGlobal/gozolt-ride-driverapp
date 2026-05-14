import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    'Privacy Policy',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.backgroundPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable content ───────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Information We Collect'),
                    const SizedBox(height: 8),
                    _BodyText(
                      'We collect information you provide directly to us, including your name, '
                      'email address, phone number, and driver documentation. We also collect '
                      'location data during active rides to provide our services.',
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('How We Use Your Information'),
                    const SizedBox(height: 8),
                    _BulletPoint('To provide and improve our ride-hailing services'),
                    _BulletPoint('To process payments and calculate earnings'),
                    _BulletPoint('To communicate with you about your account'),
                    _BulletPoint('To ensure safety and security of all users'),
                    _BulletPoint('To comply with legal obligations'),
                    const SizedBox(height: 20),
                    _SectionTitle('Location Data'),
                    const SizedBox(height: 8),
                    _BodyText(
                      'We collect your precise location data when you are online and accepting '
                      'rides. This data is essential for matching you with passengers, providing '
                      'navigation, and calculating fares. You can control location sharing by '
                      'going offline in the app.',
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('Data Sharing'),
                    const SizedBox(height: 8),
                    _BulletPoint('Passengers can see your name, vehicle details, and rating'),
                    _BulletPoint('Your supplier has access to your profile and ride history'),
                    _BulletPoint('We do not sell your personal data to third parties'),
                    _BulletPoint('We may share data with law enforcement when required'),
                    const SizedBox(height: 20),
                    _SectionTitle('Data Retention'),
                    const SizedBox(height: 8),
                    _BodyText(
                      'We retain your personal data for as long as your account is active or '
                      'as needed to provide you services. Ride history and earnings data is '
                      'retained for a period of 5 years for accounting purposes.',
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('Your Rights'),
                    const SizedBox(height: 8),
                    _BulletPoint('Access your personal data'),
                    _BulletPoint('Request correction of inaccurate data'),
                    _BulletPoint('Request deletion of your account and data'),
                    _BulletPoint('Object to processing of your data'),
                    _BulletPoint('Data portability'),
                    const SizedBox(height: 20),
                    _SectionTitle('Contact Us'),
                    const SizedBox(height: 8),
                    _BodyText(
                      'If you have any questions about this Privacy Policy, please contact us '
                      'at privacy@gozolt.com or through the Help Center in the app.',
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.titleMedium.copyWith(
        color: AppColors.backgroundPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textMuted,
        height: 1.6,
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.primaryGold,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

