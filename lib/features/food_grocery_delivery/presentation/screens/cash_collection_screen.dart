import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../partner_services/domain/models/partner_service_type.dart';
import '../providers/cash_collection_provider.dart';
import '../providers/food_grocery_delivery_session_provider.dart';

class CashCollectionScreen extends ConsumerStatefulWidget {
  const CashCollectionScreen({
    super.key,
    required this.serviceType,
    required this.onBack,
    required this.onCashCollected,
  });

  final PartnerServiceType serviceType;
  final VoidCallback onBack;
  final VoidCallback onCashCollected;

  @override
  ConsumerState<CashCollectionScreen> createState() =>
      _CashCollectionScreenState();
}

class _CashCollectionScreenState extends ConsumerState<CashCollectionScreen> {
  bool _exactAmountConfirmed = false;

  Future<void> _confirmCollection() async {
    final job = ref
        .read(
          foodGroceryDeliverySessionProvider(
            widget.serviceType,
          ),
        )
        .activeJob;

    if (job == null ||
        !job.paymentMethod.requiresCashCollection ||
        job.cashAmountToCollect == null) {
      ref
          .read(
            cashCollectionProvider(
              widget.serviceType,
            ).notifier,
          )
          .setError(
            'Cash collection details are not available.',
          );
      return;
    }

    final collected = await ref
        .read(
          cashCollectionProvider(
            widget.serviceType,
          ).notifier,
        )
        .confirmCashCollected(
          deliveryId: job.deliveryId,
          amount: job.cashAmountToCollect!,
        );

    if (!mounted || !collected) {
      return;
    }

    widget.onCashCollected();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final session = ref.watch(
      foodGroceryDeliverySessionProvider(
        widget.serviceType,
      ),
    );

    final collection = ref.watch(
      cashCollectionProvider(
        widget.serviceType,
      ),
    );

    final job = session.activeJob;

    if (job == null) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundSecondary : AppColors.backgroundLight,
        appBar: _buildAppBar(),
        body: _UnavailableView(
          isDark: isDark,
          message: 'No active delivery was found.',
          onBack: widget.onBack,
        ),
      );
    }

    if (!job.paymentMethod.requiresCashCollection ||
        job.cashAmountToCollect == null) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundSecondary : AppColors.backgroundLight,
        appBar: _buildAppBar(),
        body: _UnavailableView(
          isDark: isDark,
          message: 'This order was paid online. No cash collection is needed.',
          onBack: widget.onBack,
        ),
      );
    }

    final amount = job.cashAmountToCollect!;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundSecondary : AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            20,
            16,
            28,
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                18,
                24,
                18,
                24,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(
                  alpha: isDark ? 0.14 : 0.10,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGold.withValues(
                    alpha: 0.55,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(
                        alpha: 0.18,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.payments_outlined,
                      size: 34,
                      color: AppColors.primaryGold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Collect exact amount',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '\u20AC${amount.toStringAsFixed(2)}',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Collect this amount directly from the customer.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.textMuted.withValues(alpha: 0.22)
                      : AppColors.textMutedLight.withValues(alpha: 0.32),
                ),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    isDark: isDark,
                    label: 'Order reference',
                    value: job.orderId,
                    emphasize: true,
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    isDark: isDark,
                    label: 'Customer',
                    value: job.customerName,
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    isDark: isDark,
                    label: 'Payment method',
                    value: job.paymentMethod.displayName,
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    isDark: isDark,
                    label: 'Cash due',
                    value: '\u20AC${amount.toStringAsFixed(2)}',
                    emphasize: true,
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    isDark: isDark,
                    label: 'Your earning',
                    value: '\u20AC${job.estimatedEarning.toStringAsFixed(2)}',
                    valueColor: AppColors.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.40),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 21,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Cash collected is not your delivery earning. '
                      'It will be recorded separately for settlement '
                      'and reconciliation.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _exactAmountConfirmed
                      ? AppColors.success.withValues(alpha: 0.50)
                      : AppColors.primaryGold.withValues(alpha: 0.35),
                ),
              ),
              child: CheckboxListTile(
                value: _exactAmountConfirmed,
                onChanged: collection.isConfirming || collection.isCollected
                    ? null
                    : (value) {
                        setState(() {
                          _exactAmountConfirmed = value ?? false;
                        });
                      },
                activeColor: AppColors.success,
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  'I collected the exact amount',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '\u20AC${amount.toStringAsFixed(2)} received from the customer',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
            if (collection.errorMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  collection.errorMessage!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            12,
          ),
          color:
              isDark ? AppColors.backgroundSecondary : AppColors.surfaceLight,
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: !_exactAmountConfirmed ||
                      collection.isConfirming ||
                      collection.isCollected
                  ? null
                  : _confirmCollection,
              icon: collection.isConfirming
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF04213C),
                      ),
                    )
                  : Icon(
                      collection.isCollected
                          ? Icons.check_circle_rounded
                          : Icons.payments_outlined,
                      size: 20,
                    ),
              label: Text(
                collection.isCollected
                    ? 'Cash collection confirmed'
                    : collection.isConfirming
                        ? 'Confirming collection'
                        : 'Confirm cash collected',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: collection.isCollected
                    ? AppColors.success
                    : AppColors.primaryGold,
                foregroundColor: const Color(0xFF04213C),
                disabledBackgroundColor: collection.isCollected
                    ? AppColors.success
                    : AppColors.primaryGold.withValues(alpha: 0.45),
                disabledForegroundColor:
                    const Color(0xFF04213C).withValues(alpha: 0.70),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryGold,
      foregroundColor: const Color(0xFF04213C),
      elevation: 0,
      leading: IconButton(
        onPressed: widget.onBack,
        icon: const Icon(
          Icons.arrow_back_rounded,
        ),
      ),
      title: Text(
        'Cash Collection',
        style: AppTextStyles.titleMedium.copyWith(
          color: const Color(0xFF04213C),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.isDark,
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final bool isDark;
  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ??
                  (emphasize
                      ? AppColors.primaryGold
                      : isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight),
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _UnavailableView extends StatelessWidget {
  const _UnavailableView({
    required this.isDark,
    required this.message,
    required this.onBack,
  });

  final bool isDark;
  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.payments_outlined,
              size: 58,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onBack,
              child: const Text('Back to delivery verification'),
            ),
          ],
        ),
      ),
    );
  }
}
