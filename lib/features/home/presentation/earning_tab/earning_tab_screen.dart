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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primaryGold,
                    onPrimary: AppColors.backgroundPrimary,
                    surface: AppColors.backgroundPrimary,
                    onSurface: AppColors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primaryGold,
                    onPrimary: AppColors.white,
                    surface: AppColors.white,
                    onSurface: AppColors.textPrimaryLight,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate maximum daily earnings to normalize visual progress bar representation
    double maxDailyEarnings = 1.0;
    for (final day in screenState.dailyBreakdown) {
      if (day.totalEarnings > maxDailyEarnings) {
        maxDailyEarnings = day.totalEarnings;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const SizedBox(width: 44), // Balanced width to offset calendar icon
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Earnings',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: isDark ? AppColors.white : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (period == EarningsPeriod.custom &&
                            customRange != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormat('dd MMM').format(customRange.start)} – ${DateFormat('dd MMM').format(customRange.end)}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ]
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickDateRange,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceCard : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceCard : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    _PeriodToggleButton(
                      label: 'Today',
                      isActive: period == EarningsPeriod.today,
                      onTap: () => _onPeriodChanged(EarningsPeriod.today),
                    ),
                    _PeriodToggleButton(
                      label: 'Weekly',
                      isActive: period == EarningsPeriod.weekly,
                      onTap: () => _onPeriodChanged(EarningsPeriod.weekly),
                    ),
                  ],
                ),
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
                          // ── Hero Earnings Card ───────────────────────
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [const Color(0xFF1B2838), const Color(0xFF0F1923)]
                                    : [Colors.white, const Color(0xFFF8F9FA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -20,
                                  bottom: -20,
                                  child: Icon(
                                    Icons.trending_up_rounded,
                                    size: 100,
                                    color: AppColors.primaryGold.withOpacity(0.04),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'TOTAL EARNINGS',
                                            style: AppTextStyles.labelSmall.copyWith(
                                              color: AppColors.primaryGold,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.success.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.arrow_upward_rounded,
                                                  color: AppColors.success,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Active',
                                                  style: AppTextStyles.labelSmall.copyWith(
                                                    color: AppColors.success,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '€ ${summary.totalEarnings.toStringAsFixed(2)}',
                                        style: AppTextStyles.displayMedium.copyWith(
                                          color: isDark ? AppColors.white : AppColors.textPrimaryLight,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 32,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        period == EarningsPeriod.today
                                            ? 'Earnings gathered today'
                                            : period == EarningsPeriod.weekly
                                                ? 'Earnings gathered this week'
                                                : 'Earnings for selected range',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Stats row
                          Row(
                            children: [
                              _StatCard(
                                label: 'Trips',
                                value: '${summary.tripCount}',
                                icon: Icons.directions_car_rounded,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                label: 'Card Trip',
                                value: '${summary.cardTripCount}',
                                icon: Icons.credit_card_rounded,
                                color: Colors.orange,
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
                                color: Colors.green,
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                label: 'Tips',
                                value: '${summary.tipCount}',
                                icon: Icons.volunteer_activism_rounded,
                                color: Colors.purple,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Breakdown card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceCard : AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _BreakdownRow(
                                  label: 'Rides',
                                  value: '${summary.tripCount}',
                                  icon: Icons.directions_car_rounded,
                                  badgeColor: Colors.blue,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(
                                    color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
                                    height: 1,
                                  ),
                                ),
                                _BreakdownRow(
                                  label: 'Cash',
                                  value: '€ ${summary.cashEarnings.toStringAsFixed(2)}',
                                  icon: Icons.money_rounded,
                                  badgeColor: Colors.green,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(
                                    color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
                                    height: 1,
                                  ),
                                ),
                                _BreakdownRow(
                                  label: 'Card',
                                  value: '€ ${summary.cardEarnings.toStringAsFixed(2)}',
                                  icon: Icons.credit_card_rounded,
                                  badgeColor: Colors.orange,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(
                                    color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
                                    height: 1,
                                  ),
                                ),
                                _BreakdownRow(
                                  label: 'Tips',
                                  value: '€ ${summary.tipEarnings.toStringAsFixed(2)}',
                                  icon: Icons.volunteer_activism_rounded,
                                  badgeColor: Colors.purple,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Weekly daily breakdown
                          if (period == EarningsPeriod.weekly &&
                              screenState.dailyBreakdown.isNotEmpty) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Daily Breakdown',
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: isDark ? AppColors.white : AppColors.textPrimaryLight,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...screenState.dailyBreakdown.map(
                              (d) => _DailyRow(
                                daily: d,
                                maxDailyEarnings: maxDailyEarnings,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            // ── Bottom total bar (floating card layout) ───────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryGold,
                    Color(0xFFE5B20D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Balance',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: const Color(0xFF0F1923),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '€ ${summary.totalEarnings.toStringAsFixed(2)}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: const Color(0xFF0F1923),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGold : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryGold.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                color: isActive
                    ? const Color(0xFF0F1923)
                    : (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight),
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13,
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
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceCard : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                color: isDark ? AppColors.white : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
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
  final Color badgeColor;

  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: badgeColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDark ? AppColors.white : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label == 'Rides' ? 'Completed rides count' : 'Collected balance',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: isDark ? AppColors.white : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily row (weekly view) ──────────────────────────────────────────────────

class _DailyRow extends StatelessWidget {
  final DailyEarnings daily;
  final double maxDailyEarnings;

  const _DailyRow({
    required this.daily,
    required this.maxDailyEarnings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayName = DateFormat('EEE').format(daily.date);
    final dateStr = DateFormat('dd MMM').format(daily.date);

    final percentage = maxDailyEarnings > 0 ? (daily.totalEarnings / maxDailyEarnings) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceCard : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    dayName,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w800,
                ),
              ),
            ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isDark ? AppColors.white : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${daily.tripCount} completed trips',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '€ ${daily.totalEarnings.toStringAsFixed(2)}',
                style: AppTextStyles.titleLarge.copyWith(
                  color: isDark ? AppColors.white : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 0.8
                    ? AppColors.primaryGold
                    : AppColors.primaryGold.withOpacity(0.6),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
