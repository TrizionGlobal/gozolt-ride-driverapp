import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../driver/data/models/daily_earnings.dart';
import '../../../driver/presentation/providers/earnings_provider.dart';

class EarningTabScreen extends ConsumerStatefulWidget {
  const EarningTabScreen({super.key});

  @override
  ConsumerState<EarningTabScreen> createState() => _EarningTabScreenState();
}

class _EarningTabScreenState extends ConsumerState<EarningTabScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(earningsScreenProvider.notifier).fetchToday();
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      initialDateRange: ref.read(customDateRangeProvider),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGold,
              onPrimary: AppColors.backgroundPrimary,
              surface: AppColors.backgroundPrimary,
              onSurface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref.read(customDateRangeProvider.notifier).state = picked;
      ref.read(selectedEarningsPeriodProvider.notifier).state =
          EarningsPeriod.custom;
      ref.read(earningsScreenProvider.notifier).fetchCustomRange(picked);
    }
  }

  void _onPeriodChanged(EarningsPeriod period) {
    ref.read(selectedEarningsPeriodProvider.notifier).state = period;
    final notifier = ref.read(earningsScreenProvider.notifier);
    switch (period) {
      case EarningsPeriod.today:
        notifier.fetchToday();
      case EarningsPeriod.weekly:
        notifier.fetchWeekly();
      case EarningsPeriod.custom:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenState = ref.watch(earningsScreenProvider);
    final period = ref.watch(selectedEarningsPeriodProvider);
    final customRange = ref.watch(customDateRangeProvider);
    final summary = screenState.summary;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Earnings',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (period == EarningsPeriod.custom &&
                            customRange != null)
                          Text(
                            '${DateFormat('dd MMM').format(customRange.start)} – ${DateFormat('dd MMM').format(customRange.end)}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickDateRange,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primaryGold,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Period toggle ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _PeriodToggleButton(
                    label: 'Today',
                    isActive: period == EarningsPeriod.today,
                    onTap: () => _onPeriodChanged(EarningsPeriod.today),
                  ),
                  const SizedBox(width: 12),
                  _PeriodToggleButton(
                    label: 'Weekly',
                    isActive: period == EarningsPeriod.weekly,
                    onTap: () => _onPeriodChanged(EarningsPeriod.weekly),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Scrollable content ───────────────────────────────────
            Expanded(
              child: screenState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGold,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Stats row
                          Row(
                            children: [
                              _StatCard(
                                label: 'Trips',
                                value: '${summary.tripCount}',
                                icon: Icons.directions_car_rounded,
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                label: 'Card Trip',
                                value: '${summary.cardTripCount}',
                                icon: Icons.credit_card_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _StatCard(
                                label: 'Cash Trip',
                                value: '${summary.cashTripCount}',
                                icon: Icons.money_rounded,
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                label: 'Tips',
                                value: '${summary.tipCount}',
                                icon: Icons.volunteer_activism_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Total Earning
                          Text(
                            'Total Earning',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '€ ${summary.totalEarnings.toStringAsFixed(2)}',
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.primaryGold,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Breakdown card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _BreakdownRow(
                                  label: 'Rides',
                                  value: '${summary.tripCount}',
                                  icon: Icons.directions_car_rounded,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    color: AppColors.surfaceCard,
                                    height: 1,
                                  ),
                                ),
                                _BreakdownRow(
                                  label: 'Cash',
                                  value:
                                      '€ ${summary.cashEarnings.toStringAsFixed(2)}',
                                  icon: Icons.money_rounded,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    color: AppColors.surfaceCard,
                                    height: 1,
                                  ),
                                ),
                                _BreakdownRow(
                                  label: 'Card',
                                  value:
                                      '€ ${summary.cardEarnings.toStringAsFixed(2)}',
                                  icon: Icons.credit_card_rounded,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    color: AppColors.surfaceCard,
                                    height: 1,
                                  ),
                                ),
                                _BreakdownRow(
                                  label: 'Tips',
                                  value:
                                      '€ ${summary.tipEarnings.toStringAsFixed(2)}',
                                  icon: Icons.volunteer_activism_rounded,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Weekly daily breakdown
                          if (period == EarningsPeriod.weekly &&
                              screenState.dailyBreakdown.isNotEmpty) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Daily Breakdown',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...screenState.dailyBreakdown
                                .map((d) => _DailyRow(daily: d)),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
            ),

            // ── Bottom total bar ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Earnings',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.backgroundPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '€ ${summary.totalEarnings.toStringAsFixed(2)}',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.backgroundPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Period toggle button ─────────────────────────────────────────────────────

class _PeriodToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PeriodToggleButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGold : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: isActive
                ? null
                : Border.all(color: AppColors.surfaceDark, width: 1.5),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                color: isActive
                    ? AppColors.backgroundPrimary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryGold, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Breakdown row ────────────────────────────────────────────────────────────

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGold, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Daily row (weekly view) ──────────────────────────────────────────────────

class _DailyRow extends StatelessWidget {
  final DailyEarnings daily;

  const _DailyRow({required this.daily});

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat('EEE').format(daily.date);
    final dateStr = DateFormat('dd MMM').format(daily.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              dayName,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.primaryGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              dateStr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '${daily.tripCount} trips',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '€ ${daily.totalEarnings.toStringAsFixed(2)}',
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
