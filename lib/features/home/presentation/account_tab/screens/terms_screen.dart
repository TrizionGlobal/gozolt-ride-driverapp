import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? AppColors.white : AppColors.textPrimaryLight;
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
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Last Updated
                  Text(
                    'Last Updated: 23 May 2026',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _BodyText(
                    'By using the Gozolt Go Partner Driver App, you agree to these Terms of Service.\n\n'
                    'Gozolt is a technology platform connecting Riders with transportation services operated '
                    'by independent licensed Suppliers and authorised Drivers.\n\n'
                    'Drivers using the Platform are independent partners and are not employees of Gozolt.',
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Driver Eligibility
                  _SectionTitle('Driver Eligibility'),
                  const SizedBox(height: 8),
                  _BodyText('Drivers must:'),
                  const SizedBox(height: 10),
                  const _BulletPoint('Hold valid driving licences'),
                  const _BulletPoint('Maintain required vehicle permits and insurance'),
                  const _BulletPoint('Complete identity verification'),
                  const _BulletPoint('Comply with applicable transport regulations'),
                  const _BulletPoint('Operate safe and roadworthy vehicles'),
                  const SizedBox(height: 24),

                  // Driver Responsibilities
                  _SectionTitle('Driver Responsibilities'),
                  const SizedBox(height: 8),
                  _BodyText('Drivers agree to:'),
                  const SizedBox(height: 10),
                  const _BulletPoint('Provide accurate information'),
                  const _BulletPoint('Maintain professional conduct'),
                  const _BulletPoint('Follow traffic and safety laws'),
                  const _BulletPoint('Avoid fraudulent activity'),
                  const _BulletPoint('Complete rides responsibly'),
                  const _BulletPoint('Protect passenger privacy and safety'),
                  const SizedBox(height: 24),

                  // Platform Usage
                  _SectionTitle('Platform Usage'),
                  const SizedBox(height: 8),
                  _BodyText(
                    'Drivers may receive ride requests through the Driver App and may accept or '
                    'reject requests subject to Platform policies and supplier agreements.\n\n'
                    'Repeated misuse, fraudulent activity, fake rides, or policy violations may '
                    'result in suspension or permanent termination.',
                  ),
                  const SizedBox(height: 24),

                  // Earnings & Payments
                  _SectionTitle('Earnings & Payments'),
                  const SizedBox(height: 8),
                  _BodyText('Driver earnings may vary based on:'),
                  const SizedBox(height: 10),
                  const _BulletPoint('Completed rides'),
                  const _BulletPoint('Distance and duration'),
                  const _BulletPoint('Surge pricing where applicable'),
                  const _BulletPoint('Incentives and promotions'),
                  const SizedBox(height: 10),
                  _BodyText(
                    'Platform commissions or supplier deductions may apply according to operational agreements.',
                  ),
                  const SizedBox(height: 24),

                  // Ratings & Performance
                  _SectionTitle('Ratings & Performance'),
                  const SizedBox(height: 8),
                  _BodyText('Drivers may be subject to:'),
                  const SizedBox(height: 10),
                  const _BulletPoint('Rider ratings'),
                  const _BulletPoint('Performance monitoring'),
                  const _BulletPoint('Safety reviews'),
                  const _BulletPoint('Verification checks'),
                  const SizedBox(height: 10),
                  _BodyText(
                    'Low ratings, unsafe behaviour, or repeated complaints may result in restrictions or deactivation.',
                  ),
                  const SizedBox(height: 24),

                  // Privacy
                  _SectionTitle('Privacy'),
                  const SizedBox(height: 8),
                  _BodyText(
                    'Driver use of the Platform is also governed by the Gozolt Privacy Policy.',
                  ),
                  const SizedBox(height: 24),

                  // Limitation of Liability
                  _SectionTitle('Limitation of Liability'),
                  const SizedBox(height: 8),
                  _BodyText('Gozolt is not liable for:'),
                  const SizedBox(height: 10),
                  const _BulletPoint('Passenger misconduct'),
                  const _BulletPoint('Third-party actions'),
                  const _BulletPoint('Network/service interruptions'),
                  const _BulletPoint('Operational losses beyond applicable law'),
                  const SizedBox(height: 24),

                  // Suspension & Termination
                  _SectionTitle('Suspension & Termination'),
                  const SizedBox(height: 8),
                  _BodyText('Driver accounts may be suspended or terminated for:'),
                  const SizedBox(height: 10),
                  const _BulletPoint('Fraud'),
                  const _BulletPoint('Unsafe behaviour'),
                  const _BulletPoint('Regulatory violations'),
                  const _BulletPoint('Fake documentation'),
                  const _BulletPoint('Abuse of the Platform'),
                  const SizedBox(height: 24),

                  // Contact Us
                  _SectionTitle('Contact Us'),
                  const SizedBox(height: 8),
                  _BodyText('Primooo Global Ltd.'),
                  const SizedBox(height: 10),
                  const _ClickableBullet(
                    label: 'Support: ',
                    linkText: 'support@gozolt.com.mt',
                    launchUri: 'mailto:support@gozolt.com.mt',
                  ),
                  const _ClickableBullet(
                    label: 'Privacy & GDPR: ',
                    linkText: 'privacy@gozolt.com.mt',
                    launchUri: 'mailto:privacy@gozolt.com.mt',
                  ),
                  const _ClickableBullet(
                    label: 'Full Terms of Service: ',
                    linkText: 'https://sites.google.com/view/gozoltlegal-go-partner/terms-service',
                    launchUri: 'https://sites.google.com/view/gozoltlegal-go-partner/terms-service',
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
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
        color: Theme.of(context).textTheme.titleLarge?.color,
        fontWeight: FontWeight.w800,
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
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
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
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClickableBullet extends StatelessWidget {
  final String label;
  final String linkText;
  final String launchUri;

  const _ClickableBullet({
    required this.label,
    required this.linkText,
    required this.launchUri,
  });

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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(launchUri);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        linkText,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
