import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_data.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/transaction_model.dart';
import '../controller/statistic_controller.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'Day';
  String _selectedType = 'Expense';
  int _selectedIndex = -1; // -1: no selection

  // State variables
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  List<FlSpot> _chartSpots = [];
  List<String> _chartLabels = [];
  bool _isLoading = true;

  final StatisticController _controller = StatisticController();

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  // Public method to be called from MainScaffold
  Future<void> refreshData() async {
    setState(() => _isLoading = true);
    await _loadStats();
  }

  Future<void> _loadStats() async {
    final result = await _controller.loadStats(
      _selectedPeriod,
      _selectedType == 'Expense',
    );

    if (mounted) {
      setState(() {
        _allTransactions = result['transactions'];
        _chartSpots = result['chartSpots'];
        _chartLabels = result['chartLabels'];
        _filteredTransactions = result['filteredForList'];
        _isLoading = false;
      });
    }
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
      _isLoading = true;
    });
    _loadStats();
  }

  void _onTypeChanged(String? type) {
    if (type != null) {
      setState(() {
        _selectedType = type;
        _isLoading = true;
      });
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: 72,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Statistics",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildPeriodSelector(),
                    _buildChart(),
                    const SizedBox(height: 16),
                    _buildTopSpending(),
                    _buildSpendingList(_filteredTransactions),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['Day', 'Week', 'Month', 'Year'].map((period) {
            final isSelected = _selectedPeriod == period;
            return GestureDetector(
              onTap: () => _onPeriodChanged(period),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_buildTypeSelector()],
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isDense: true,
          items: ['Expense', 'Income'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: _onTypeChanged,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_chartSpots.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    final maxY = _chartSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final minY = 0.0;
    final maxX = (_chartLabels.length - 1).toDouble();

    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  return LineTooltipItem(
                    '\$${touchedSpot.y.toStringAsFixed(0)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  );
                }).toList();
              },
              tooltipBgColor: AppColors.primary,
              tooltipRoundedRadius: 8,
            ),
          ),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= _chartLabels.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _chartLabels[index],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                },
                interval: 1,
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: maxX,
          minY: minY,
          maxY: maxY * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: _chartSpots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSpending() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _selectedType == 'Expense' ? "Top Spending" : "Top Income",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.swap_vert)),
      ],
    );
  }

  Widget _buildSpendingList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'No transactions found',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];
        final isHighlighted = index == _selectedIndex;
        final isExpense = !t.isIncome;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedIndex == index) {
                _selectedIndex = -1;
              } else {
                _selectedIndex = index;
              }
            });
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 0,
            color: isHighlighted ? AppColors.primary : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading:
                  kCategoryAvatars[t.category] ??
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(
                      Icons.category,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
              title: Text(
                t.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isHighlighted ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  DateTimeFormat.formatDate(t.date),
                  style: TextStyle(
                    fontSize: 13,
                    color: isHighlighted
                        ? Colors.white70
                        : Colors.grey.shade600,
                  ),
                ),
              ),
              trailing: Text(
                "${isExpense ? '-' : '+'} \$${t.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isHighlighted
                      ? Colors.white
                      : (isExpense ? AppColors.expense : AppColors.income),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
