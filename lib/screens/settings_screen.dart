import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/calorie_calculator_service.dart';
import '../services/premium_service.dart';
import '../services/notification_service.dart';
import '../services/export_service.dart';
import 'package:share_plus/share_plus.dart';
import 'paywall_screen.dart';
import 'recipe_builder_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _profile;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = StorageService.getUserProfile();
    final premium = await PremiumService.isPremium();
    setState(() {
      _profile = profile;
      _isPremium = premium;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          // Premium Status Banner
          if (!_isPremium) _buildPremiumBanner(),

          // Profile Section
          _buildSection('Profile', [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(_profile!.name),
              subtitle: const Text('Name'),
              trailing: const Icon(Icons.edit),
              onTap: _editProfile,
            ),
            ListTile(
              leading: const Icon(Icons.monitor_weight),
              title: Text(_formatWeight(_profile!.weight)),
              subtitle: const Text('Current Weight'),
              trailing: const Icon(Icons.edit),
              onTap: _editWeight,
            ),
            ListTile(
              leading: const Icon(Icons.height),
              title: Text(_formatHeight(_profile!.height)),
              subtitle: const Text('Height'),
              trailing: const Icon(Icons.edit),
              onTap: _editHeight,
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: Text(_getGoalText(_profile!.goal)),
              subtitle: const Text('Goal'),
              trailing: const Icon(Icons.edit),
              onTap: _editGoal,
            ),
          ]),

          // Nutrition Targets
          _buildSection('Nutrition Targets', [
            ListTile(
              leading: const Icon(
                Icons.local_fire_department,
                color: Colors.orange,
              ),
              title: Text('${_profile!.dailyCalorieTarget.toInt()} cal'),
              subtitle: const Text('Daily Calories'),
              trailing: const Icon(Icons.edit),
              onTap: _editCalorieTarget,
            ),
            ListTile(
              leading: const Icon(Icons.restaurant, color: Colors.red),
              title: Text(
                '${_profile!.proteinTarget.toInt()}g / '
                '${_profile!.carbsTarget.toInt()}g / '
                '${_profile!.fatsTarget.toInt()}g',
              ),
              subtitle: const Text('Protein / Carbs / Fats'),
              trailing: _isPremium ? const Icon(Icons.edit) : null,
              onTap: _isPremium ? _editMacros : null,
            ),
            ListTile(
              leading: const Icon(Icons.water_drop, color: Colors.blue),
              title: Text(_formatWater(_profile!.waterTarget)),
              subtitle: const Text('Daily Water'),
              trailing: const Icon(Icons.edit),
              onTap: _editWaterTarget,
            ),
          ]),

          // App Settings
          _buildSection('App Settings', [
            ListTile(
              leading: const Icon(Icons.straighten),
              title: const Text('Measurement System'),
              subtitle: Text(
                _profile!.measurementSystem == 'metric'
                    ? 'Metric (kg, cm, ml)'
                    : 'Imperial (lbs, ft/in, oz)',
              ),
              trailing: Switch(
                value: _profile!.measurementSystem == 'imperial',
                onChanged: _toggleMeasurementSystem,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Meal Reminders'),
              subtitle: const Text('Daily notifications'),
              trailing: Switch(
                value: StorageService.getSetting(
                  'meal_reminders',
                  defaultValue: false,
                ),
                onChanged: _toggleMealReminders,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.water_drop),
              title: const Text('Water Reminders'),
              subtitle: const Text('Hydration alerts'),
              trailing: Switch(
                value: StorageService.getSetting(
                  'water_reminders',
                  defaultValue: false,
                ),
                onChanged: _toggleWaterReminders,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu, color: Colors.orange),
              title: const Text('Recipe Builder'),
              subtitle: const Text('Create and manage recipes'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecipeBuilderScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              subtitle: const Text('Light / Dark mode'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme settings coming soon!')),
                );
              },
            ),
          ]),

          // Premium Features
          if (_isPremium)
            _buildSection('Premium Features', [
              ListTile(
                leading: const Icon(Icons.cloud_upload, color: Colors.purple),
                title: const Text('Cloud Sync'),
                subtitle: const Text('Backup your data'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cloud sync coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.download, color: Colors.purple),
                title: const Text('Export Data'),
                subtitle: const Text('CSV export of your data'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showExportDialog,
              ),
            ]),

          // About
          _buildSection('About', [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Version'),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.gavel),
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ]),

          // Danger Zone
          _buildSection('Danger Zone', [
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Clear All Data',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _clearAllData,
            ),
          ]),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
      },
      child: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          children: [
            Icon(Icons.star, color: Colors.white, size: 40),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Unlock all features & remove ads',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  String _getGoalText(String goal) {
    switch (goal) {
      case 'lose_weight':
        return 'Lose Weight';
      case 'gain_weight':
        return 'Gain Weight';
      case 'maintain':
        return 'Maintain Weight';
      default:
        return goal;
    }
  }

  // Conversion helpers
  String _formatWeight(double weightKg) {
    if (_profile!.measurementSystem == 'imperial') {
      final lbs = weightKg * 2.20462;
      return '${lbs.toStringAsFixed(1)} lbs';
    }
    return '${weightKg.toStringAsFixed(1)} kg';
  }

  String _formatHeight(double heightCm) {
    if (_profile!.measurementSystem == 'imperial') {
      final totalInches = heightCm / 2.54;
      final feet = totalInches ~/ 12;
      final inches = (totalInches % 12).round();
      return '$feet\' $inches"';
    }
    return '${heightCm.toInt()} cm';
  }

  String _formatWater(double waterMl) {
    if (_profile!.measurementSystem == 'imperial') {
      final oz = waterMl / 29.5735;
      return '${oz.toStringAsFixed(0)} oz';
    }
    return '${waterMl.toInt()} ml';
  }

  Future<void> _toggleMeasurementSystem(bool useImperial) async {
    _profile!.measurementSystem = useImperial ? 'imperial' : 'metric';
    _profile!.updatedAt = DateTime.now();
    await StorageService.saveUserProfile(_profile!);

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Measurement system changed to ${useImperial ? 'Imperial' : 'Metric'}',
          ),
        ),
      );
    }
  }

  Future<void> _editProfile() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ProfileNameDialog(currentName: _profile!.name),
    );

    if (result != null && result.isNotEmpty) {
      _profile!.name = result;
      _profile!.updatedAt = DateTime.now();
      await StorageService.saveUserProfile(_profile!);

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Name updated!')));
      }
    }
  }

  Future<void> _editWeight() async {
    final result = await showDialog<double>(
      context: context,
      builder: (context) => WeightEditDialog(
        currentWeight: _profile!.weight,
        isImperial: _profile!.measurementSystem == 'imperial',
      ),
    );

    if (result != null) {
      _profile!.weight = result;
      _profile!.updatedAt = DateTime.now();
      await StorageService.saveUserProfile(_profile!);

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Weight updated!')));
      }
    }
  }

  Future<void> _editHeight() async {
    final result = await showDialog<double>(
      context: context,
      builder: (context) => HeightEditDialog(
        currentHeight: _profile!.height,
        isImperial: _profile!.measurementSystem == 'imperial',
      ),
    );

    if (result != null) {
      _profile!.height = result;
      _profile!.updatedAt = DateTime.now();
      await StorageService.saveUserProfile(_profile!);

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Height updated!')));
      }
    }
  }

  Future<void> _editGoal() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => GoalSelectionDialog(currentGoal: _profile!.goal),
    );

    if (result != null) {
      _profile!.goal = result;
      _profile!.updatedAt = DateTime.now();

      // Recalculate calorie target based on new goal
      _profile!.dailyCalorieTarget =
          CalorieCalculatorService.calculateDailyCalorieTarget(_profile!);

      await StorageService.saveUserProfile(_profile!);

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal updated! Calorie target recalculated.'),
          ),
        );
      }
    }
  }

  Future<void> _editCalorieTarget() async {
    final result = await showDialog<double>(
      context: context,
      builder: (context) =>
          CalorieTargetDialog(currentTarget: _profile!.dailyCalorieTarget),
    );

    if (result != null) {
      _profile!.dailyCalorieTarget = result;
      _profile!.updatedAt = DateTime.now();
      await StorageService.saveUserProfile(_profile!);

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calorie target updated!')),
        );
      }
    }
  }

  Future<void> _editMacros() async {
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (context) => MacroEditDialog(
        currentProtein: _profile!.proteinTarget,
        currentCarbs: _profile!.carbsTarget,
        currentFats: _profile!.fatsTarget,
      ),
    );

    if (result != null) {
      _profile!.proteinTarget = result['protein']!;
      _profile!.carbsTarget = result['carbs']!;
      _profile!.fatsTarget = result['fats']!;
      _profile!.updatedAt = DateTime.now();

      await StorageService.saveUserProfile(_profile!);

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Macro targets updated!')));
      }
    }
  }

  Future<void> _editWaterTarget() async {
    final result = await showDialog<double>(
      context: context,
      builder: (context) => WaterTargetDialog(
        currentTarget: _profile!.waterTarget,
        isImperial: _profile!.measurementSystem == 'imperial',
      ),
    );

    if (result != null) {
      _profile!.waterTarget = result;
      _profile!.updatedAt = DateTime.now();

      await StorageService.saveUserProfile(_profile!);

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Water target updated!')));
      }
    }
  }

  Future<void> _toggleMealReminders(bool value) async {
    try {
      await StorageService.saveSetting('meal_reminders', value);
      if (value) {
        await NotificationService.scheduleMealReminders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Meal reminders enabled! Make sure to allow notifications in system settings.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        await NotificationService.cancelAllNotifications();
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting reminders: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _toggleWaterReminders(bool value) async {
    try {
      await StorageService.saveSetting('water_reminders', value);
      if (value) {
        await NotificationService.scheduleMealReminders(water: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Water reminders enabled! Make sure to allow notifications in system settings.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting reminders: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your data including logs, weight history, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('All data cleared')));
        // Navigate back to onboarding
        // Navigator.of(context).pushReplacement(...);
      }
    }
  }
}

// Macro Edit Dialog
class MacroEditDialog extends StatefulWidget {
  final double currentProtein;
  final double currentCarbs;
  final double currentFats;

  const MacroEditDialog({
    super.key,
    required this.currentProtein,
    required this.currentCarbs,
    required this.currentFats,
  });

  @override
  State<MacroEditDialog> createState() => _MacroEditDialogState();
}

class _MacroEditDialogState extends State<MacroEditDialog> {
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;

  @override
  void initState() {
    super.initState();
    _proteinController = TextEditingController(
      text: widget.currentProtein.toInt().toString(),
    );
    _carbsController = TextEditingController(
      text: widget.currentCarbs.toInt().toString(),
    );
    _fatsController = TextEditingController(
      text: widget.currentFats.toInt().toString(),
    );
  }

  @override
  void dispose() {
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  int get totalCalories {
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fats = double.tryParse(_fatsController.text) ?? 0;
    return ((protein * 4) + (carbs * 4) + (fats * 9)).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Macro Targets'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set your daily macro targets in grams',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Protein
            TextField(
              controller: _proteinController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Protein (g)',
                prefixIcon: const Icon(Icons.fitness_center, color: Colors.red),
                suffixText: 'g',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText:
                    '${(double.tryParse(_proteinController.text) ?? 0) * 4} cal',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 15),

            // Carbs
            TextField(
              controller: _carbsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Carbs (g)',
                prefixIcon: const Icon(Icons.bakery_dining, color: Colors.blue),
                suffixText: 'g',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText:
                    '${(double.tryParse(_carbsController.text) ?? 0) * 4} cal',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 15),

            // Fats
            TextField(
              controller: _fatsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Fats (g)',
                prefixIcon: const Icon(Icons.opacity, color: Colors.amber),
                suffixText: 'g',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText:
                    '${(double.tryParse(_fatsController.text) ?? 0) * 9} cal',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // Total Calories
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Calories:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$totalCalories cal',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final protein = double.tryParse(_proteinController.text);
            final carbs = double.tryParse(_carbsController.text);
            final fats = double.tryParse(_fatsController.text);

            if (protein == null || carbs == null || fats == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter valid numbers')),
              );
              return;
            }

            if (protein < 0 || carbs < 0 || fats < 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Values must be positive')),
              );
              return;
            }

            Navigator.pop(context, {
              'protein': protein,
              'carbs': carbs,
              'fats': fats,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Calorie Target Dialog
class CalorieTargetDialog extends StatefulWidget {
  final double currentTarget;

  const CalorieTargetDialog({super.key, required this.currentTarget});

  @override
  State<CalorieTargetDialog> createState() => _CalorieTargetDialogState();
}

class _CalorieTargetDialogState extends State<CalorieTargetDialog> {
  late double _targetCalories;
  final List<int> _presetTargets = [1200, 1500, 1800, 2000, 2200, 2500, 3000];

  @override
  void initState() {
    super.initState();
    _targetCalories = widget.currentTarget;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Daily Calorie Target'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set your daily calorie goal',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Current selection display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_targetCalories.toInt()} cal',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'Per day',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Slider
            Slider(
              value: _targetCalories,
              min: 1000,
              max: 4000,
              divisions: 60,
              label: '${_targetCalories.toInt()} cal',
              onChanged: (value) {
                setState(() {
                  _targetCalories = value;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [Text('1000 cal'), Text('4000 cal')],
            ),
            const SizedBox(height: 10),

            // Preset buttons
            const Text(
              'Quick Select:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetTargets.map((target) {
                final isSelected = (_targetCalories - target).abs() < 50;
                return FilterChip(
                  label: Text('$target'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _targetCalories = target.toDouble();
                      });
                    }
                  },
                  selectedColor: Colors.orange.withOpacity(0.3),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _targetCalories);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Water Target Dialog
class WaterTargetDialog extends StatefulWidget {
  final double currentTarget;
  final bool isImperial;

  const WaterTargetDialog({
    super.key,
    required this.currentTarget,
    this.isImperial = false,
  });

  @override
  State<WaterTargetDialog> createState() => _WaterTargetDialogState();
}

class _WaterTargetDialogState extends State<WaterTargetDialog> {
  late double _targetMl; // Always stored in ml

  List<int> get _presetTargets {
    if (widget.isImperial) {
      // Presets in oz: 50, 64, 80, 100, 120, 135
      return [1480, 1892, 2366, 2957, 3546, 3992];
    }
    return [1500, 2000, 2500, 3000, 3500, 4000];
  }

  @override
  void initState() {
    super.initState();
    _targetMl = widget.currentTarget;
  }

  String _formatWater() {
    if (widget.isImperial) {
      final oz = _targetMl / 29.5735;
      return '${oz.toStringAsFixed(0)} oz';
    }
    return '${_targetMl.toInt()} ml';
  }

  String _formatWaterSecondary() {
    if (widget.isImperial) {
      final gallons = _targetMl / 3785.41;
      return '${gallons.toStringAsFixed(2)} gal';
    }
    return '${(_targetMl / 1000).toStringAsFixed(1)} L';
  }

  String _formatPreset(int ml) {
    if (widget.isImperial) {
      final oz = ml / 29.5735;
      return '${oz.toStringAsFixed(0)} oz';
    }
    return '${(ml / 1000).toStringAsFixed(1)} L';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Daily Water Target'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select or customize your daily water intake goal',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Current selection display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Column(
                children: [
                  const Icon(Icons.water_drop, color: Colors.blue, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    _formatWater(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    _formatWaterSecondary(),
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Slider
            Slider(
              value: _targetMl,
              min: 1000,
              max: 5000,
              divisions: 40,
              label: _formatWater(),
              onChanged: (value) {
                setState(() {
                  _targetMl = value;
                });
              },
            ),
            const SizedBox(height: 10),

            // Preset buttons
            const Text(
              'Quick Select:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetTargets.map((target) {
                final isSelected = (_targetMl - target).abs() < 50;
                return FilterChip(
                  label: Text(_formatPreset(target)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _targetMl = target.toDouble();
                      });
                    }
                  },
                  selectedColor: Colors.blue.withOpacity(0.3),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _targetMl);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Profile Name Dialog
class ProfileNameDialog extends StatefulWidget {
  final String currentName;

  const ProfileNameDialog({super.key, required this.currentName});

  @override
  State<ProfileNameDialog> createState() => _ProfileNameDialogState();
}

class _ProfileNameDialogState extends State<ProfileNameDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Name'),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Your Name',
          prefixIcon: const Icon(Icons.person),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textCapitalization: TextCapitalization.words,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a name')),
              );
              return;
            }
            Navigator.pop(context, name);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _showExportDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose what data to export:'),
            const SizedBox(height: 16),
            _buildExportOption(
              'Food Logs',
              'Export all your food entries',
              Icons.restaurant,
              () => _exportData('food_logs'),
            ),
            _buildExportOption(
              'Weight Logs',
              'Export your weight history',
              Icons.monitor_weight,
              () => _exportData('weight_logs'),
            ),
            _buildExportOption(
              'Meal Plans',
              'Export your meal plans',
              Icons.calendar_today,
              () => _exportData('meal_plans'),
            ),
            _buildExportOption(
              'Recipes',
              'Export your recipes',
              Icons.book,
              () => _exportData('recipes'),
            ),
            _buildExportOption(
              'Complete Export',
              'Export all data and statistics',
              Icons.cloud_download,
              () => _exportData('complete'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.download),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _exportData(String type) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      late final file;

      switch (type) {
        case 'food_logs':
          file = await ExportService.exportFoodLogs();
          break;
        case 'weight_logs':
          file = await ExportService.exportWeightLogs();
          break;
        case 'meal_plans':
          file = await ExportService.exportMealPlans();
          break;
        case 'recipes':
          file = await ExportService.exportRecipes();
          break;
        case 'complete':
          file = await ExportService.exportAllData();
          break;
        default:
          throw Exception('Unknown export type: \$type');
      }

      Navigator.pop(context); // Close loading dialog

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Diet App Data Export');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data exported successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: \$e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Weight Edit Dialog
class WeightEditDialog extends StatefulWidget {
  final double currentWeight;
  final bool isImperial;

  const WeightEditDialog({
    super.key,
    required this.currentWeight,
    this.isImperial = false,
  });

  @override
  State<WeightEditDialog> createState() => _WeightEditDialogState();
}

class _WeightEditDialogState extends State<WeightEditDialog> {
  late double _weight; // Always stored in kg

  @override
  void initState() {
    super.initState();
    _weight = widget.currentWeight;
  }

  String _formatWeight() {
    if (widget.isImperial) {
      final lbs = _weight * 2.20462;
      return '${lbs.toStringAsFixed(1)} lbs';
    }
    return '${_weight.toStringAsFixed(1)} kg';
  }

  @override
  Widget build(BuildContext context) {
    final double minWeight = widget.isImperial ? 66 : 30; // 66 lbs = ~30 kg
    final double maxWeight = widget.isImperial ? 440 : 200; // 440 lbs = ~200 kg
    final String minLabel = widget.isImperial ? '66 lbs' : '30 kg';
    final String maxLabel = widget.isImperial ? '440 lbs' : '200 kg';

    return AlertDialog(
      title: const Text('Update Weight'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Track your current weight',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Column(
              children: [
                const Icon(Icons.monitor_weight, color: Colors.green, size: 40),
                const SizedBox(height: 10),
                Text(
                  _formatWeight(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Slider(
            value: _weight,
            min: 30,
            max: 200,
            divisions: 340,
            label: _formatWeight(),
            onChanged: (value) {
              setState(() {
                _weight = value;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(minLabel), Text(maxLabel)],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _weight);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Height Edit Dialog
class HeightEditDialog extends StatefulWidget {
  final double currentHeight;
  final bool isImperial;

  const HeightEditDialog({
    super.key,
    required this.currentHeight,
    this.isImperial = false,
  });

  @override
  State<HeightEditDialog> createState() => _HeightEditDialogState();
}

class _HeightEditDialogState extends State<HeightEditDialog> {
  late double _height; // Always stored in cm

  @override
  void initState() {
    super.initState();
    _height = widget.currentHeight;
  }

  String _formatHeight() {
    if (widget.isImperial) {
      final totalInches = _height / 2.54;
      final feet = totalInches ~/ 12;
      final inches = (totalInches % 12).round();
      return '$feet\' $inches"';
    }
    return '${_height.toInt()} cm';
  }

  @override
  Widget build(BuildContext context) {
    final String minLabel = widget.isImperial ? '4\' 0"' : '120 cm';
    final String maxLabel = widget.isImperial ? '7\' 3"' : '220 cm';

    return AlertDialog(
      title: const Text('Update Height'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Set your height',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple, width: 2),
            ),
            child: Column(
              children: [
                const Icon(Icons.height, color: Colors.purple, size: 40),
                const SizedBox(height: 10),
                Text(
                  _formatHeight(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Slider(
            value: _height,
            min: 120,
            max: 220,
            divisions: 100,
            label: _formatHeight(),
            onChanged: (value) {
              setState(() {
                _height = value;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(minLabel), Text(maxLabel)],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _height);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Goal Selection Dialog
class GoalSelectionDialog extends StatefulWidget {
  final String currentGoal;

  const GoalSelectionDialog({super.key, required this.currentGoal});

  @override
  State<GoalSelectionDialog> createState() => _GoalSelectionDialogState();
}

class _GoalSelectionDialogState extends State<GoalSelectionDialog> {
  late String _selectedGoal;

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.currentGoal;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Your Goal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choose your fitness goal to adjust calorie targets',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _buildGoalOption(
            'lose_weight',
            'Lose Weight',
            Icons.trending_down,
            Colors.red,
            'Caloric deficit for weight loss',
          ),
          const SizedBox(height: 12),
          _buildGoalOption(
            'maintain',
            'Maintain Weight',
            Icons.trending_flat,
            Colors.blue,
            'Balanced calories to stay the same',
          ),
          const SizedBox(height: 12),
          _buildGoalOption(
            'gain_weight',
            'Gain Weight',
            Icons.trending_up,
            Colors.green,
            'Caloric surplus for muscle gain',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, _selectedGoal);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildGoalOption(
    String value,
    String title,
    IconData icon,
    Color color,
    String description,
  ) {
    final isSelected = _selectedGoal == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedGoal = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? color : null,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}
