import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/recipe.dart';
import '../models/food_item.dart';
import '../services/storage_service.dart';
import '../services/premium_service.dart';
import 'paywall_screen.dart';

class RecipeBuilderScreen extends StatefulWidget {
  const RecipeBuilderScreen({super.key});

  @override
  State<RecipeBuilderScreen> createState() => _RecipeBuilderScreenState();
}

class _RecipeBuilderScreenState extends State<RecipeBuilderScreen> {
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() {
    setState(() {
      _recipes = StorageService.getAllRecipes();
    });
  }

  Future<void> _createRecipe() async {
    final isPremium = await PremiumService.isPremium();
    if (!isPremium && _recipes.length >= 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PaywallScreen()),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _RecipeEditorScreen()),
    );

    if (result == true) {
      _loadRecipes();
    }
  }

  Future<void> _editRecipe(Recipe recipe) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _RecipeEditorScreen(recipe: recipe),
      ),
    );

    if (result == true) {
      _loadRecipes();
    }
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "${recipe.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.deleteRecipe(recipe.id);
      _loadRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Builder')),
      body: _recipes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recipes yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first recipe!',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recipes.length,
              itemBuilder: (context, index) {
                final recipe = _recipes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: const Icon(Icons.restaurant, color: Colors.white),
                    ),
                    title: Text(recipe.name),
                    subtitle: Text(
                      '${recipe.ingredients.length} ingredients • ${recipe.totalCalories.toStringAsFixed(0)} cal',
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editRecipe(recipe);
                        } else if (value == 'delete') {
                          _deleteRecipe(recipe);
                        }
                      },
                    ),
                    onTap: () => _editRecipe(recipe),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createRecipe,
        icon: const Icon(Icons.add),
        label: const Text('New Recipe'),
      ),
    );
  }
}

class _RecipeEditorScreen extends StatefulWidget {
  final Recipe? recipe;

  const _RecipeEditorScreen({this.recipe});

  @override
  State<_RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends State<_RecipeEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  final List<RecipeIngredient> _ingredients = [];

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _nameController.text = widget.recipe!.name;
      _instructionsController.text = widget.recipe!.instructions ?? '';
      _ingredients.addAll(widget.recipe!.ingredients);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _addIngredient() async {
    final foodItem = await showDialog<FoodItem>(
      context: context,
      builder: (context) => _FoodItemSelector(),
    );

    if (foodItem != null && mounted) {
      final servings = await showDialog<double>(
        context: context,
        builder: (context) => _ServingSizeDialog(foodItem: foodItem),
      );

      if (servings != null && mounted) {
        setState(() {
          _ingredients.add(
            RecipeIngredient(
              foodItemId: foodItem.id,
              foodName: foodItem.name,
              servings: servings,
              calories: foodItem.calories * servings,
              protein: foodItem.protein * servings,
              carbs: foodItem.carbs * servings,
              fat: foodItem.fats * servings,
            ),
          );
        });
      }
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    final recipe = Recipe(
      id: widget.recipe?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      ingredients: _ingredients,
      instructions: _instructionsController.text.trim().isEmpty
          ? null
          : _instructionsController.text.trim(),
      createdAt: widget.recipe?.createdAt ?? DateTime.now(),
      isPremium: widget.recipe?.isPremium ?? false,
    );

    await StorageService.saveRecipe(recipe);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCalories = _ingredients.fold<double>(
      0,
      (sum, i) => sum + i.calories,
    );
    final totalProtein = _ingredients.fold<double>(
      0,
      (sum, i) => sum + i.protein,
    );
    final totalCarbs = _ingredients.fold<double>(0, (sum, i) => sum + i.carbs);
    final totalFat = _ingredients.fold<double>(0, (sum, i) => sum + i.fat);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? 'New Recipe' : 'Edit Recipe'),
        actions: [
          TextButton(
            onPressed: _saveRecipe,
            child: const Text('SAVE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Recipe Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.trim().isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_ingredients.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No ingredients added yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ...List.generate(_ingredients.length, (index) {
                final ingredient = _ingredients[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(ingredient.foodName),
                    subtitle: Text(
                      '${ingredient.servings.toStringAsFixed(1)} servings • ${ingredient.calories.toStringAsFixed(0)} cal',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _removeIngredient(index),
                    ),
                  ),
                );
              }),
            if (_ingredients.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.orange.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Nutrition',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Calories: ${totalCalories.toStringAsFixed(0)} cal'),
                      Text('Protein: ${totalProtein.toStringAsFixed(1)}g'),
                      Text('Carbs: ${totalCarbs.toStringAsFixed(1)}g'),
                      Text('Fat: ${totalFat.toStringAsFixed(1)}g'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FoodItemSelector extends StatefulWidget {
  @override
  State<_FoodItemSelector> createState() => _FoodItemSelectorState();
}

class _FoodItemSelectorState extends State<_FoodItemSelector> {
  final _searchController = TextEditingController();
  List<FoodItem> _results = [];

  @override
  void initState() {
    super.initState();
    _results = StorageService.getAllFoodItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _results = StorageService.getAllFoodItems();
      } else {
        _results = StorageService.searchFoodItems(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Food Item'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search foods...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _search,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('No foods found'))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final food = _results[index];
                        return ListTile(
                          title: Text(food.name),
                          subtitle: Text(
                            '${food.calories.toStringAsFixed(0)} cal per serving',
                          ),
                          onTap: () => Navigator.pop(context, food),
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

class _ServingSizeDialog extends StatefulWidget {
  final FoodItem foodItem;

  const _ServingSizeDialog({required this.foodItem});

  @override
  State<_ServingSizeDialog> createState() => _ServingSizeDialogState();
}

class _ServingSizeDialogState extends State<_ServingSizeDialog> {
  final _controller = TextEditingController(text: '1.0');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Serving Size for ${widget.foodItem.name}'),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Number of servings',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final servings = double.tryParse(_controller.text);
            if (servings != null && servings > 0) {
              Navigator.pop(context, servings);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
