import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

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
                    'Gozolt Go Partner (“Driver App”) is operated by Primooo Global Ltd., Malta.\n\n'
                    'This Privacy Policy explains how we collect, use, and protect driver and supplier '
                    'information while using the Gozolt Driver Platform.',
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),

                  // Information We Collect
                  _SectionTitle('Information We Collect'),
                  const SizedBox(height: 8),
                  _BodyText('We may collect:'),
                  const SizedBox(height: 10),
                  const _BulletPoint('Driver full name'),
                  const _BulletPoint('Phone number and email address'),
                  const _BulletPoint('Driving licence information'),
                  const _BulletPoint('Vehicle information and documents'),
                  const _BulletPoint('Insurance details'),
                  const _BulletPoint('Identity verification and selfie verification'),
                  const _BulletPoint('Live GPS location during active driver sessions'),
                  const _BulletPoint('Ride and earnings history'),
                  const _BulletPoint('Device and technical information'),
                  const _BulletPoint('Support communications'),
                  const SizedBox(height: 24),

                  // How We Use Driver Data
                  _SectionTitle('How We Use Driver Data'),
                  const SizedBox(height: 8),
                  _BodyText('We use collected information to:'),
                  const SizedBox(height: 10),
                  const _BulletPoint('Verify driver identity and eligibility'),
                  const _BulletPoint('Match drivers with ride requests'),
                  const _BulletPoint('Enable navigation and trip tracking'),
                  const _BulletPoint('Process payouts and earnings'),
                  const _BulletPoint('Prevent fraud and ensure passenger safety'),
                  const _BulletPoint('Improve app functionality and operational performance'),
                  const _BulletPoint('Comply with legal and regulatory obligations'),
                  const SizedBox(height: 24),

                  // Driver Location Tracking
                  _SectionTitle('Driver Location Tracking'),
                  const SizedBox(height: 8),
                  _BodyText(
                    'The Driver App may collect real-time location data while the driver is online '
                    'or actively using the Platform for ride services.',
                  ),
                  const SizedBox(height: 10),
                  _BodyText('Location data is used for:'),
                  const SizedBox(height: 8),
                  const _BulletPoint('Ride matching'),
                  const _BulletPoint('Navigation'),
                  const _BulletPoint('Passenger safety'),
                  const _BulletPoint('Operational monitoring'),
                  const SizedBox(height: 24),

                  // Payments & Earnings
                  _SectionTitle('Payments & Earnings'),
                  const SizedBox(height: 8),
                  _BodyText(
                    'Driver earnings and payouts may be processed through approved payment providers and financial partners.\n\n'
                    'Applicable taxes, commissions, or platform fees may apply depending on supplier agreements and local regulations.',
                  ),
                  const SizedBox(height: 24),

                  // App Permissions
                  _SectionTitle('App Permissions'),
                  const SizedBox(height: 8),
                  _BodyText(
                    'Depending on your device settings and app functionality, Gozolt may request access to:',
                  ),
                  const SizedBox(height: 10),
                  const _BulletPoint('Location services'),
                  const _BulletPoint('Camera'),
                  const _BulletPoint('Photos/media'),
                  const _BulletPoint('Notifications'),
                  const _BulletPoint('Phone/SMS verification'),
                  const SizedBox(height: 10),
                  _BodyText('Permissions can be managed through device settings.'),
                  const SizedBox(height: 24),

                  // Data Security
                  _SectionTitle('Data Security'),
                  const SizedBox(height: 8),
                  _BodyText(
                    'We implement appropriate technical and organisational security measures to protect driver information and Platform security.',
                  ),
                  const SizedBox(height: 24),

                  // GDPR Rights
                  _SectionTitle('GDPR Rights'),
                  const SizedBox(height: 8),
                  _BodyText('Drivers within the EU may have rights including:'),
                  const SizedBox(height: 10),
                  const _BulletPoint('Access to personal data'),
                  const _BulletPoint('Correction of inaccurate information'),
                  const _BulletPoint('Request deletion of personal data'),
                  const _BulletPoint('Restrict or object to processing'),
                  const _BulletPoint('Request data portability'),
                  const SizedBox(height: 24),

                  // Account Deletion
                  _SectionTitle('Account Deletion'),
                  const SizedBox(height: 8),
                  _BodyText(
                    'Drivers may request account deactivation or deletion by contacting support or their associated supplier/operator.',
                  ),
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
                    label: 'Full Privacy Policy: ',
                    linkText: 'https://sites.google.com/view/gozoltlegal-go-partner/privacy-policy',
                    launchUri: 'https://sites.google.com/view/gozoltlegal-go-partner/privacy-policy',
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
