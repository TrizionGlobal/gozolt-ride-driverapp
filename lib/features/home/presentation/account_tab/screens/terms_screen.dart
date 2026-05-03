import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                        color: AppColors.backgroundPrimary.withValues(alpha: 0.2),
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
                    'Terms & Conditions',
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
                    _SectionTitle('1. Acceptance of Terms'),
                    const SizedBox(height: 8),
                    _BodyText(
                      'By accessing and using the Gozolt Driver Application, you accept and agree '
                      'to be bound by the terms and provision of this agreement. If you do not agree '
                      'to abide by the above, please do not use this service.',
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('2. Driver Eligibility'),
                    const SizedBox(height: 8),
                    _BulletPoint('Must hold a valid driving license issued in Malta'),
                    _BulletPoint('Must be at least 21 years of age'),
                    _BulletPoint('Must pass background and vehicle checks'),
                    _BulletPoint('Must maintain valid insurance coverage'),
                    const SizedBox(height: 20),
                    _SectionTitle('3. Use of the Platform'),
                    const SizedBox(height: 8),
                    _BodyText(
                      'Drivers agree to use the platform solely for the purpose of providing '
                      'ride-hailing services to passengers. Any misuse of the platform, including '
                      'fraudulent activity, will result in immediate account deactivation.',
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('4. Earnings & Payments'),
                    const SizedBox(height: 8),
                    _BulletPoint('Earnings are calculated based on distance, time, and base fare'),
                    _BulletPoint('Cash ride payments must be collected directly from passengers'),
                    _BulletPoint('Card payments are processed through the platform'),
                    _BulletPoint('Weekly settlements are processed every Monday'),
                    const SizedBox(height: 20),
                    _SectionTitle('5. Driver Conduct'),
                    const SizedBox(height: 8),
                    _BulletPoint('Maintain a professional and courteous demeanor'),
                    _BulletPoint('Keep your vehicle clean and well-maintained'),
                    _BulletPoint('Follow all traffic laws and regulations'),
                    _BulletPoint('Do not use your phone while driving'),
                    const SizedBox(height: 20),
                    _SectionTitle('6. Cancellation Policy'),
                    const SizedBox(height: 8),
                    _BodyText(
                      'Excessive ride cancellations may affect your acceptance rate and could '
                      'result in temporary suspension of your account. Please only accept rides '
                      'you intend to complete.',
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('7. Limitation of Liability'),
                    const SizedBox(height: 8),
                    _BodyText(
                      'Gozolt shall not be liable for any indirect, incidental, special, '
                      'consequential, or punitive damages resulting from the use of or inability '
                      'to use the service.',
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle('8. Changes to Terms'),
                    const SizedBox(height: 8),
                    _BodyText(
                      'Gozolt reserves the right to modify these terms at any time. Continued use '
                      'of the platform after changes constitutes acceptance of the new terms.',
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
