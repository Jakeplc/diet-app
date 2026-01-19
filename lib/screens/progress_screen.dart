import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';
import '../models/weight_log.dart';
import '../models/food_log.dart';
import '../services/storage_service.dart';
import '../services/premium_service.dart';
import 'paywall_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<WeightLog> _weightLogs = [];
  bool _isPremium = false;
  int _selectedDays = 7; // 7, 30, 90 days

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final logs = StorageService.getAllWeightLogs();
    final premium = await PremiumService.isPremium();
    setState(() {
      _weightLogs = logs;
      _isPremium = premium;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addWeightLog),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Weight Chart
            _buildWeightChart(),
            const SizedBox(height: 30),

            // Time Range Selector
            _buildTimeRangeSelector(),
            const SizedBox(height: 20),

            // Statistics Cards
            _buildStatisticsCards(),
            const SizedBox(height: 30),

            // Advanced Analytics (Premium)
            if (!_isPremium) _buildPremiumTeaser(),

            if (_isPremium) ...[
              _buildAdvancedAnalytics(),
              const SizedBox(height: 30),
            ],

            // Weight History List
            const Text(
              'Weight History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildWeightHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart() {
    if (_weightLogs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.show_chart, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 15),
              const Text(
                'No weight data yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _addWeightLog,
                child: const Text('Log Your Weight'),
              ),
            ],
          ),
        ),
      );
    }

    // Filter logs based on selected days
    final now = DateTime.now();
    final filteredLogs = _weightLogs.where((log) {
      return now.difference(log.timestamp).inDays <= _selectedDays;
    }).toList();

    if (filteredLogs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('No data for this time range'),
        ),
      );
    }

    // Create chart data
    final spots = filteredLogs.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    final minWeight = filteredLogs
        .map((l) => l.weight)
        .reduce((a, b) => a < b ? a : b);
    final maxWeight = filteredLogs
        .map((l) => l.weight)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weight Trend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: (minWeight - 5).floorToDouble(),
                  maxY: (maxWeight + 5).ceilToDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeRangeChip(7, '7 Days'),
        const SizedBox(width: 10),
        _buildTimeRangeChip(30, '30 Days'),
        const SizedBox(width: 10),
        _buildTimeRangeChip(90, '90 Days'),
      ],
    );
  }

  Widget _buildTimeRangeChip(int days, String label) {
    final isSelected = _selectedDays == days;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedDays = days);
      },
      selectedColor: Colors.green,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }

  Widget _buildStatisticsCards() {
    if (_weightLogs.isEmpty) return const SizedBox();

    final currentWeight = _weightLogs.last.weight;
    final firstWeight = _weightLogs.first.weight;
    final totalChange = currentWeight - firstWeight;
    final avgWeeklyChange =
        totalChange / (_weightLogs.length / 7).clamp(1, double.infinity);

    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const Text('Current', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text(
                    '${currentWeight.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Card(
            color: totalChange < 0
                ? Colors.green.shade50
                : Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const Text(
                    'Total Change',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${totalChange > 0 ? '+' : ''}${totalChange.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: totalChange < 0 ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumTeaser() {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
      },
      child: Card(
        color: Colors.purple.shade50,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_graph,
                  color: Colors.purple,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock Advanced Analytics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Get detailed insights, body composition tracking, and more!',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.purple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedAnalytics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_graph, color: Colors.purple),
                SizedBox(width: 10),
                Text(
                  'Advanced Analytics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Text('• Calorie deficit/surplus trends'),
            const Text('• Macro balance insights'),
            const Text('• Body composition estimates'),
            const Text('• Predicted goal achievement date'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Export data functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export feature coming soon!')),
                );
              },
              child: const Text('Export Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightHistory() {
    if (_weightLogs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Text(
            'No weight logs yet',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: _weightLogs.reversed.map((log) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                '${log.weight.toInt()}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            title: Text('${log.weight.toStringAsFixed(1)} kg'),
            subtitle: Text(
              '${log.timestamp.day}/${log.timestamp.month}/${log.timestamp.year}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteWeightLog(log),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _addWeightLog() async {
    final weightController = TextEditingController();

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Weight'),
        content: TextField(
          controller: weightController,
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              Navigator.pop(context, weight);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      final log = WeightLog(
        id: const Uuid().v4(),
        weight: result,
        timestamp: DateTime.now(),
      );

      await StorageService.saveWeightLog(log);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weight logged successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteWeightLog(WeightLog log) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Log'),
        content: const Text('Are you sure you want to delete this weight log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      StorageService.deleteWeightLog(log.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Weight log deleted')));
      }
    }
  }
}
