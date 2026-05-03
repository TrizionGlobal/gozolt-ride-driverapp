import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_result.dart';
import '../../data/models/daily_earnings.dart';
import '../../data/models/earnings_summary.dart';
import '../../domain/repositories/driver_repository.dart';
import 'driver_provider.dart';

// ── Period enum ──────────────────────────────────────────────────────────────

enum EarningsPeriod { today, weekly, custom }

// ── Today earnings (used by EarningsPill on home tab) ────────────────────────

final todayEarningsProvider =
    StateNotifierProvider<TodayEarningsNotifier, EarningsSummary>((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  return TodayEarningsNotifier(repository);
});

class TodayEarningsNotifier extends StateNotifier<EarningsSummary> {
  final DriverRepository _repository;

  TodayEarningsNotifier(this._repository)
      : super(const EarningsSummary.empty());

  Future<void> fetchTodayEarnings() async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final result = await _repository.getEarnings(from: from, to: to);
    switch (result) {
      case ApiSuccess(:final data):
        state = data;
      case ApiFailure():
        break;
    }
  }
}

// ── Earnings screen state ────────────────────────────────────────────────────

class EarningsScreenState {
  final EarningsSummary summary;
  final List<DailyEarnings> dailyBreakdown;
  final bool isLoading;

  const EarningsScreenState({
    this.summary = const EarningsSummary.empty(),
    this.dailyBreakdown = const [],
    this.isLoading = false,
  });

  EarningsScreenState copyWith({
    EarningsSummary? summary,
    List<DailyEarnings>? dailyBreakdown,
    bool? isLoading,
  }) {
    return EarningsScreenState(
      summary: summary ?? this.summary,
      dailyBreakdown: dailyBreakdown ?? this.dailyBreakdown,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ── Providers ────────────────────────────────────────────────────────────────

final selectedEarningsPeriodProvider =
    StateProvider<EarningsPeriod>((ref) => EarningsPeriod.today);

final customDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final earningsScreenProvider =
    StateNotifierProvider<EarningsScreenNotifier, EarningsScreenState>((ref) {
  final repository = ref.watch(driverRepositoryProvider);
  return EarningsScreenNotifier(repository);
});

class EarningsScreenNotifier extends StateNotifier<EarningsScreenState> {
  final DriverRepository _repository;

  EarningsScreenNotifier(this._repository)
      : super(const EarningsScreenState());

  Future<void> fetchToday() async {
    state = state.copyWith(isLoading: true, dailyBreakdown: []);
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final result = await _repository.getEarnings(from: from, to: to);
    switch (result) {
      case ApiSuccess(:final data):
        state = state.copyWith(summary: data, isLoading: false);
      case ApiFailure():
        state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchWeekly() async {
    state = state.copyWith(isLoading: true);
    // Fetch summary for the week
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final summaryResult = await _repository.getEarnings(from: from, to: to);
    final weeklyResult = await _repository.getWeeklyEarnings();

    EarningsSummary? summary;
    List<DailyEarnings>? daily;

    if (summaryResult case ApiSuccess(:final data)) {
      summary = data;
    }
    if (weeklyResult case ApiSuccess(:final data)) {
      daily = data;
      // If summary wasn't returned, compute from daily
      summary ??= EarningsSummary(
        totalEarnings: data.fold(0.0, (sum, d) => sum + d.totalEarnings),
        cashEarnings: data.fold(0.0, (sum, d) => sum + d.cashEarnings),
        cardEarnings: data.fold(0.0, (sum, d) => sum + d.cardEarnings),
        tripCount: data.fold(0, (sum, d) => sum + d.tripCount),
        cashTripCount: 0,
        cardTripCount: 0,
        tipEarnings: data.fold(0.0, (sum, d) => sum + d.tipEarnings),
        tipCount: 0,
      );
    }

    state = state.copyWith(
      summary: summary ?? state.summary,
      dailyBreakdown: daily ?? [],
      isLoading: false,
    );
  }

  Future<void> fetchCustomRange(DateTimeRange range) async {
    state = state.copyWith(isLoading: true, dailyBreakdown: []);
    final from = range.start;
    final to = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
    final result = await _repository.getEarnings(from: from, to: to);
    switch (result) {
      case ApiSuccess(:final data):
        state = state.copyWith(summary: data, isLoading: false);
      case ApiFailure():
        state = state.copyWith(isLoading: false);
    }
  }
}
