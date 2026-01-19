import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/food_item.dart';
import '../models/food_log.dart';
import '../services/storage_service.dart';
import '../services/premium_service.dart';
import '../services/barcode_api_service.dart';
import '../services/food_search_api_service.dart';
import 'paywall_screen.dart';

class FoodLoggingScreen extends StatefulWidget {
  const FoodLoggingScreen({super.key});

  @override
  State<FoodLoggingScreen> createState() => _FoodLoggingScreenState();
}

class _FoodLoggingScreenState extends State<FoodLoggingScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  String _selectedMealType = 'breakfast';
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    } else {
      // Optimal debounce: 400ms for responsive UX
      _debounceTimer = Timer(const Duration(milliseconds: 400), () {
        _performSearch(_searchController.text);
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().length < 2) return; // Minimum 2 characters

    setState(() {
      _isSearching = true;
      // Clear old results for better UX
      _searchResults = [];
    });

    try {
      // First search local database
      final localResults = StorageService.searchFoodItems(query);

      // Then search USDA API
      final apiResults = await FoodSearchApiService.searchFoods(query);

      // Combine results: local first, then API results
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Food'), elevation: 0),
      body: Column(
        children: [
          // Meal Type Selector
          Container(
            padding: const EdgeInsets.all(15),
            color: const Color(0xFF1E1E1E),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMealTypeChip(
                  'breakfast',
                  'Breakfast',
                  Icons.breakfast_dining,
                ),
                _buildMealTypeChip('lunch', 'Lunch', Icons.lunch_dining),
                _buildMealTypeChip('dinner', 'Dinner', Icons.dinner_dining),
                _buildMealTypeChip('snack', 'Snack', Icons.fastfood),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for food...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
              ),
            ),
          ),

          // Quick Actions
          if (!_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Scan Barcode',
                      Icons.qr_code_scanner,
                      Colors.blue,
                      _scanBarcode,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionButton(
                      'Take Photo',
                      Icons.camera_alt,
                      Colors.orange,
                      _takePhoto,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionButton(
                      'Custom',
                      Icons.add_circle,
                      Colors.green,
                      _addCustomFood,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Search Results
          Expanded(
            child: _isSearching
                ? _buildSearchResults()
                : _buildQuickAddSuggestions(),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeChip(String value, String label, IconData icon) {
    final isSelected = _selectedMealType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedMealType = value),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey.shade300,
              ),
            ),
            child: Icon(icon, color: isSelected ? Colors.white : Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching && _searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Searching...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            const Text(
              'No results found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _addCustomFood,
              child: const Text('Add as custom food'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        final isFromApi = food.id.startsWith('usda_');

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade800, width: 1),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getHealthScoreColor(food.healthScore),
              child: Text(
                food.healthScore[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    food.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isFromApi) ...[
                  const SizedBox(width: 8),
                  const Tooltip(
                    message: 'From USDA Database',
                    child: Icon(Icons.cloud, size: 18, color: Colors.blue),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              '${food.calories.toInt()} cal • P: ${food.protein.toInt()}g • C: ${food.carbs.toInt()}g • F: ${food.fats.toInt()}g',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: const Icon(Icons.add_circle, color: Colors.green),
            onTap: () => _addFoodLog(food),
          ),
        );
      },
    );
  }

  Widget _buildQuickAddSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: [
        const Text(
          'Popular Foods',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...StorageService.getAllFoodItems().take(10).map((food) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getHealthScoreColor(food.healthScore),
                child: Text(
                  food.healthScore[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(food.name),
              subtitle: Text('${food.calories.toInt()} cal • ${food.category}'),
              trailing: const Icon(Icons.add_circle, color: Colors.green),
              onTap: () => _addFoodLog(food),
            ),
          );
        }),
      ],
    );
  }

  Color _getHealthScoreColor(String score) {
    switch (score) {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.amber;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()));

    if (result != null && result is String) {
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 15),
                    Text('Looking up product...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // First check local database
      FoodItem? food = StorageService.getFoodItemByBarcode(result);

      // If not found locally, fetch from API
      if (food == null || food.id.isEmpty) {
        food = await BarcodeApiService.lookupBarcode(result);

        // Save to local database for future use
        if (food != null) {
          food = food.copyWith(id: const Uuid().v4());
          await StorageService.saveFoodItem(food);
        }
      }

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (food != null && mounted) {
        _addFoodLog(food);
      } else {
        if (mounted) {
          // Show dialog to add manually
          final shouldAdd = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Product Not Found'),
              content: const Text(
                'This product was not found in our database. Would you like to add it manually?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Add Manually'),
                ),
              ],
            ),
          );

          if (shouldAdd == true && mounted) {
            _addCustomFood();
          }
        }
      }
    }
  }

  Future<void> _takePhoto() async {
    final isPremium = await PremiumService.canUseFeature(
      'unlimited_photo_recognition',
    );

    if (!isPremium) {
      // Show paywall
      if (mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
      }
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image != null && mounted) {
      // In real app: Send to ML model for food recognition
      // For MVP: Show manual entry
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo saved! Premium AI recognition coming soon.'),
        ),
      );
      _addCustomFood();
    }
  }

  Future<void> _addCustomFood() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CustomFoodEntrySheet(mealType: _selectedMealType),
    );
  }

  Future<void> _addFoodLog(FoodItem food) async {
    // If this is from API, save it to local database for offline access
    if (food.id.startsWith('usda_')) {
      await StorageService.saveFoodItem(food);
    }

    // Show serving size dialog
    final servings = await showDialog<double>(
      context: context,
      builder: (context) => ServingSizeDialog(food: food),
    );

    if (servings == null) return;

    final log = FoodLog(
      id: const Uuid().v4(),
      foodItemId: food.id,
      foodName: food.name,
      servings: servings,
      timestamp: DateTime.now(),
      mealType: _selectedMealType,
      calories: food.calories * servings,
      protein: food.protein * servings,
      carbs: food.carbs * servings,
      fats: food.fats * servings,
    );

    await StorageService.saveFoodLog(log);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${food.name} logged successfully!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () {
              StorageService.deleteFoodLog(log.id);
            },
          ),
        ),
      );

      // Clear search and refresh to show updated Popular Foods
      _searchController.clear();
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }
}

// Barcode Scanner Screen
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    switch (state) {
      case AppLifecycleState.paused:
        _controller.stop();
        break;
      case AppLifecycleState.resumed:
        _controller.start();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.black,
      ),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_hasScanned) return;

          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
            setState(() {
              _hasScanned = true;
            });
            Navigator.pop(context, barcodes.first.rawValue);
          }
        },
      ),
    );
  }
}

// Serving Size Dialog
class ServingSizeDialog extends StatefulWidget {
  final FoodItem food;

  const ServingSizeDialog({super.key, required this.food});

  @override
  State<ServingSizeDialog> createState() => _ServingSizeDialogState();
}

class _ServingSizeDialogState extends State<ServingSizeDialog> {
  double _servings = 1.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.food.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Serving size: ${widget.food.servingSize.toInt()}g'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (_servings > 0.25) {
                    setState(() => _servings -= 0.25);
                  }
                },
                icon: const Icon(Icons.remove_circle),
                iconSize: 30,
              ),
              Container(
                width: 80,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _servings.toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _servings += 0.25);
                },
                icon: const Icon(Icons.add_circle),
                iconSize: 30,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Calories: ${(widget.food.calories * _servings).toInt()}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _servings),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// Custom Food Entry Sheet
class CustomFoodEntrySheet extends StatefulWidget {
  final String mealType;

  const CustomFoodEntrySheet({super.key, required this.mealType});

  @override
  State<CustomFoodEntrySheet> createState() => _CustomFoodEntrySheetState();
}

class _CustomFoodEntrySheetState extends State<CustomFoodEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _calories = 0;
  double _protein = 0;
  double _carbs = 0;
  double _fats = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Custom Food',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCustomFood,
                  child: const Text('Add to Log'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCustomFood() async {
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

    final log = FoodLog(
      id: const Uuid().v4(),
      foodItemId: foodId,
      foodName: _name,
      servings: 1.0,
      timestamp: DateTime.now(),
      mealType: widget.mealType,
      calories: _calories,
      protein: _protein,
      carbs: _carbs,
      fats: _fats,
    );

    await StorageService.saveFoodLog(log);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Custom food added!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
