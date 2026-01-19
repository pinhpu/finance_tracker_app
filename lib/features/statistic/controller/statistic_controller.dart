import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/transaction_repository.dart';

class StatisticController {
  final TransactionRepository _repo = TransactionRepository();

  Future<Map<String, dynamic>> loadStats(String period, bool isExpense) async {
    final transactions = await _repo.getTransactions();

    final filteredForChart = transactions
        .where((t) => isExpense ? !t.isIncome : t.isIncome)
        .toList();

    List<FlSpot> spots = [];
    List<String> labels = [];

    final now = DateTime.now();

    switch (period) {
      case 'Day':
        final sevenDaysAgo = now.subtract(const Duration(days: 6));
        final Map<int, double> dailyTotals = {};
        final Map<int, String> dayLabels = {};

        for (int i = 0; i < 7; i++) {
          final date = sevenDaysAgo.add(Duration(days: i));
          dailyTotals[i] = 0;
          dayLabels[i] = DateFormat('EEE').format(date);
        }

        for (var t in filteredForChart) {
          if (t.date.isAfter(sevenDaysAgo.subtract(const Duration(days: 1)))) {
            final dayDiff = t.date.difference(sevenDaysAgo).inDays;
            if (dayDiff >= 0 && dayDiff < 7) {
              dailyTotals[dayDiff] = (dailyTotals[dayDiff] ?? 0) + t.amount;
            }
          }
        }

        spots = dailyTotals.entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList();
        labels = dayLabels.values.toList();
        break;

      case 'Week':
        final fourWeeksAgo = now.subtract(const Duration(days: 28));
        final Map<int, double> weeklyTotals = {};
        final Map<int, String> weekLabels = {};

        for (int i = 0; i < 4; i++) {
          final weekStart = fourWeeksAgo.add(Duration(days: i * 7));
          weeklyTotals[i] = 0;
          weekLabels[i] = DateFormat('MMM').format(weekStart);
        }

        for (var t in filteredForChart) {
          if (t.date.isAfter(fourWeeksAgo.subtract(const Duration(days: 1)))) {
            final weekDiff = t.date.difference(fourWeeksAgo).inDays ~/ 7;
            if (weekDiff >= 0 && weekDiff < 4) {
              weeklyTotals[weekDiff] = (weeklyTotals[weekDiff] ?? 0) + t.amount;
            }
          }
        }

        spots = weeklyTotals.entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList();
        labels = weekLabels.values.toList();
        break;

      case 'Month':
        final Map<int, double> monthlyTotals = {};
        final Map<int, String> monthLabels = {};

        for (int i = 0; i < 7; i++) {
          final monthDate = DateTime(now.year, now.month - 6 + i, 1);
          monthlyTotals[i] = 0;
          monthLabels[i] = DateFormat('MMM').format(monthDate);
        }

        for (var t in filteredForChart) {
          final tMonth = DateTime(t.date.year, t.date.month, 1);
          final nowMonth = DateTime(now.year, now.month, 1);
          final monthDiff = (nowMonth.year - tMonth.year) * 12 +
              (nowMonth.month - tMonth.month);

          if (monthDiff >= 0 && monthDiff < 7) {
            final index = 6 - monthDiff;
            if (index >= 0 && index < 7) {
              monthlyTotals[index] = (monthlyTotals[index] ?? 0) + t.amount;
            }
          }
        }

        spots = monthlyTotals.entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList();
        labels = monthLabels.values.toList();
        break;

      case 'Year':
        final Map<int, double> yearlyTotals = {};
        final Map<int, String> yearLabels = {};

        for (int i = 0; i < 5; i++) {
          final year = now.year - 4 + i;
          yearlyTotals[i] = 0;
          yearLabels[i] = year.toString();
        }

        for (var t in filteredForChart) {
          final yearDiff = now.year - t.date.year;
          if (yearDiff >= 0 && yearDiff < 5) {
            final index = 4 - yearDiff;
            if (index >= 0 && index < 5) {
              yearlyTotals[index] = (yearlyTotals[index] ?? 0) + t.amount;
            }
          }
        }

        spots = yearlyTotals.entries
            .map((e) => FlSpot(e.key.toDouble(), e.value))
            .toList();
        labels = yearLabels.values.toList();
        break;
    }
    
    // Filter for the list below chart (Top Spending logic)
    final filteredForList = transactions
        .where((t) => isExpense ? !t.isIncome : t.isIncome)
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return {
      'transactions': transactions,
      'filteredForList': filteredForList,
      'chartSpots': spots,
      'chartLabels': labels,
    };
  }
}
