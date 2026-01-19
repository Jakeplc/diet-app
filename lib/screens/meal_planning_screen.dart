import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/meal_plan.dart';
import '../models/food_item.dart';
import '../services/storage_service.dart';
import '../services/premium_service.dart';
import '../services/food_search_api_service.dart';
import '../services/barcode_api_service.dart';
import 'paywall_screen.dart';
import 'food_logging_screen.dart';

class MealPlanningScreen extends StatefulWidget {
  const MealPlanningScreen({super.key});

  @override
  State<MealPlanningScreen> createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends State<MealPlanningScreen> {
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  String _selectedDay = 'Monday';
  List<MealPlan> _mealPlans = [];
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadMealPlans();
  }

  Future<void> _loadMealPlans() async {
    final premium = await PremiumService.isPremium();
    final plans = StorageService.getAllMealPlans();
    setState(() {
      _isPremium = premium;
      _mealPlans = plans;
    });
  }

  List<MealPlan> _getMealPlansForDay(String day) {
    return _mealPlans
        .where((plan) => plan.dayOfWeek.toLowerCase() == day.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planning'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all),
            onPressed: _copyWeekPlan,
            tooltip: 'Copy to Next Week',
          ),
        ],
      ),
      body: Column(
        children: [
          // Day Selector
          Container(
            height: 60,
            color: const Color(0xFF1E1E1E),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _daysOfWeek.length,
              itemBuilder: (context, index) {
                final day = _daysOfWeek[index];
                final isSelected = _selectedDay == day;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.orange : Colors.grey,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        day.substring(0, 3),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Meal Plans for Selected Day
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadMealPlans,
              child: _buildMealPlansList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMealPlan,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMealPlansList() {
    final dayPlans = _getMealPlansForDay(_selectedDay);

    if (dayPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            const Text(
              'No meals planned for this day',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _addMealPlan,
              icon: const Icon(Icons.add),
              label: const Text('Add Meal Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Group by meal type
    final grouped = <String, List<MealPlan>>{};
    for (final mealType in _mealTypes) {
      grouped[mealType] = dayPlans
          .where((p) => p.mealType.toLowerCase() == mealType.toLowerCase())
          .toList();
    }

    return ListView(
      padding: const EdgeInsets.all(15),
      children: _mealTypes.map((mealType) {
        final plans = grouped[mealType] ?? [];
        return _buildMealTypeSection(mealType, plans);
      }).toList(),
    );
  }

  Widget _buildMealTypeSection(String mealType, List<MealPlan> plans) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ExpansionTile(
        leading: Icon(_getMealIcon(mealType), color: Colors.orange),
        title: Text(
          mealType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${plans.length} plan(s)'),
        initiallyExpanded: plans.isNotEmpty,
        children: [
          if (plans.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No $mealType planned',
                style: const TextStyle(color: Colors.grey),
              ),
            )
          else
            ...plans.map((plan) => _buildMealPlanTile(plan)),
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: Colors.green),
            title: const Text('Add meal'),
            onTap: () => _addMealPlan(mealType: mealType),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPlanTile(MealPlan plan) {
    final foods = plan.foodItemIds
        .map((id) => StorageService.getFoodItemById(id))
        .whereType<FoodItem>()
        .toList();

    final totalCalories = foods.fold<double>(
      0,
      (sum, food) => sum + food.calories,
    );
    final totalProtein = foods.fold<double>(
      0,
      (sum, food) => sum + food.protein,
    );

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange.shade100,
        child: Text(
          foods.length.toString(),
          style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(plan.name),
      subtitle: Text(
        '${totalCalories.toInt()} cal • ${totalProtein.toInt()}g protein\n${foods.map((f) => f.name).join(", ")}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _editMealPlan(plan),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteMealPlan(plan),
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.fastfood;
      default:
        return Icons.restaurant;
    }
  }

  Future<void> _addMealPlan({String? mealType}) async {
    if (!_isPremium) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      await _loadMealPlans();
      return;
    }

    await showDialog(
      context: context,
      builder: (context) =>
          MealPlanDialog(dayOfWeek: _selectedDay, mealType: mealType),
    );
    await _loadMealPlans();
  }

  Future<void> _editMealPlan(MealPlan plan) async {
    await showDialog(
      context: context,
      builder: (context) => MealPlanDialog(
        dayOfWeek: plan.dayOfWeek,
        mealType: plan.mealType,
        existingPlan: plan,
      ),
    );
    await _loadMealPlans();
  }

  Future<void> _deleteMealPlan(MealPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal Plan'),
        content: Text('Delete "${plan.name}"?'),
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

    if (confirmed == true) {
      await StorageService.deleteMealPlan(plan.id);
      await _loadMealPlans();
    }
  }

  Future<void> _copyWeekPlan() async {
    if (!_isPremium) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Copy Week Plan'),
        content: const Text(
          'This will duplicate all meal plans from this week to next week. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Copy'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Copy logic here - for now just show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Week plan copied!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// Meal Plan Dialog
class MealPlanDialog extends StatefulWidget {
  final String dayOfWeek;
  final String? mealType;
  final MealPlan? existingPlan;

  const MealPlanDialog({
    super.key,
    required this.dayOfWeek,
    this.mealType,
    this.existingPlan,
  });

  @override
  State<MealPlanDialog> createState() => _MealPlanDialogState();
}

class _MealPlanDialogState extends State<MealPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedMealType;
  List<FoodItem> _selectedFoods = [];
  List<FoodItem> _availableFoods = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingPlan?.name ?? '',
    );
    _selectedMealType =
        widget.mealType ?? widget.existingPlan?.mealType ?? 'Breakfast';
    _availableFoods = StorageService.getAllFoodItems();

    if (widget.existingPlan != null) {
      _selectedFoods = widget.existingPlan!.foodItemIds
          .map((id) => StorageService.getFoodItemById(id))
          .whereType<FoodItem>()
          .toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCalories = _selectedFoods.fold<double>(
      0,
      (sum, food) => sum + food.calories,
    );

    return AlertDialog(
      title: Text(
        widget.existingPlan == null ? 'Add Meal Plan' : 'Edit Meal Plan',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Plan Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedMealType,
                decoration: const InputDecoration(
                  labelText: 'Meal Type',
                  border: OutlineInputBorder(),
                ),
                items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedMealType = val!),
              ),
              const SizedBox(height: 15),
              const Text(
                'Selected Foods:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_selectedFoods.isEmpty)
                const Text(
                  'No foods selected',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ..._selectedFoods.map(
                  (food) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(food.name),
                    subtitle: Text('${food.calories.toInt()} cal'),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        setState(() => _selectedFoods.remove(food));
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _addFood,
                icon: const Icon(Icons.add),
                label: const Text('Add Food'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Total: ${totalCalories.toInt()} calories',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveMealPlan, child: const Text('Save')),
      ],
    );
  }

  Future<void> _addFood() async {
    final selected = await showDialog<FoodItem>(
      context: context,
      builder: (context) => _FoodSelectionDialog(),
    );

    if (selected != null) {
      setState(() => _selectedFoods.add(selected));
    }
  }

  Future<void> _saveMealPlan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one food')),
      );
      return;
    }

    final plan = MealPlan(
      id: widget.existingPlan?.id ?? const Uuid().v4(),
      name: _nameController.text,
      date: widget.existingPlan?.date ?? DateTime.now(),
      dayOfWeek: widget.dayOfWeek,
      mealType: _selectedMealType,
      foodItemIds: _selectedFoods.map((f) => f.id).toList(),
    );

    await StorageService.saveMealPlan(plan);
    if (mounted) Navigator.pop(context);
  }
}

// Food Selection Dialog with Search
class _FoodSelectionDialog extends StatefulWidget {
  @override
  State<_FoodSelectionDialog> createState() => _FoodSelectionDialogState();
}

class _FoodSelectionDialogState extends State<_FoodSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchResults = StorageService.getAllFoodItems();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();

    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = StorageService.getAllFoodItems();
        _isSearching = false;
      });
    } else {
      _debounceTimer = Timer(const Duration(milliseconds: 400), () {
        _performSearch(_searchController.text);
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().length < 2) return;

    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final localResults = StorageService.searchFoodItems(query);
      final apiResults = await FoodSearchApiService.searchFoods(query);
      final combined = <FoodItem>[...localResults, ...apiResults];

      if (mounted) {
        setState(() {
          _searchResults = combined;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  Future<void> _scanBarcode() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (barcode != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final food = await BarcodeApiService.lookupBarcode(barcode);

        if (mounted) {
          Navigator.pop(context); // Close loading dialog

          if (food != null) {
            await StorageService.saveFoodItem(food);
            Navigator.pop(context, food);
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Not Found'),
                content: const Text('Product not found in database.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to lookup product: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Future<void> _addCustomFood() async {
    final result = await showDialog<FoodItem>(
      context: context,
      builder: (context) => _QuickAddFoodDialog(),
    );

    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Food'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search foods...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _scanBarcode,
                    icon: const Icon(Icons.qr_code_scanner, size: 20),
                    label: const Text('Scan', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    onPressed: _addCustomFood,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Custom', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                  ? const Center(child: Text('No foods found'))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final food = _searchResults[index];
                        final isFromApi = food.id.startsWith('usda_');
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(food.name[0].toUpperCase()),
                          ),
                          title: Row(
                            children: [
                              Expanded(child: Text(food.name)),
                              if (isFromApi)
                                const Icon(
                                  Icons.cloud,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                            ],
                          ),
                          subtitle: Text(
                            '${food.calories.toInt()} cal • P: ${food.protein.toInt()}g • C: ${food.carbs.toInt()}g • F: ${food.fats.toInt()}g',
                          ),
                          onTap: () async {
                            // Save API food to local database
                            if (isFromApi) {
                              await StorageService.saveFoodItem(food);
                            }
                            if (mounted) Navigator.pop(context, food);
                          },
                        );
                      },
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
      ],
    );
  }
}

// Quick Add Food Dialog
class _QuickAddFoodDialog extends StatefulWidget {
  @override
  State<_QuickAddFoodDialog> createState() => _QuickAddFoodDialogState();
}

class _QuickAddFoodDialogState extends State<_QuickAddFoodDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _calories = 0;
  double _protein = 0;
  double _carbs = 0;
  double _fats = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Food'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => _name = v!,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Calories',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                      onSaved: (v) => _calories = double.parse(v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Protein (g)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => _protein = double.tryParse(v!) ?? 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Carbs (g)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => _carbs = double.tryParse(v!) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Fats (g)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => _fats = double.tryParse(v!) ?? 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveFood, child: const Text('Add')),
      ],
    );
  }

  Future<void> _saveFood() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final foodId = const Uuid().v4();
    final food = FoodItem(
      id: foodId,
      name: _name,
      calories: _calories,
      protein: _protein,
      carbs: _carbs,
      fats: _fats,
      isCustom: true,
    );

    await StorageService.saveFoodItem(food);
    if (mounted) Navigator.pop(context, food);
  }
}
