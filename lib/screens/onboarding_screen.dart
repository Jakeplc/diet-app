import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/calorie_calculator_service.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // User data
  String _name = '';
  int _age = 25;
  double _height = 170; // cm
  double _weight = 70; // kg
  String _gender = 'male';
  String _activityLevel = 'moderate';
  String _goal = 'maintain';
  String _dietType = 'standard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildWelcomePage(),
                  _buildPersonalInfoPage(),
                  _buildPhysicalStatsPage(),
                  _buildGoalsPage(),
                  _buildDietPreferencesPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 5,
                    effect: WormEffect(
                      activeDotColor: Theme.of(context).primaryColor,
                      dotHeight: 10,
                      dotWidth: 10,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text('Back'),
                        )
                      else
                        const SizedBox(width: 80),
                      ElevatedButton(
                        onPressed: _currentPage == 4
                            ? _finishOnboarding
                            : () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        child: Text(_currentPage == 4 ? 'Get Started' : 'Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 100, color: Colors.green),
          const SizedBox(height: 30),
          const Text(
            'Welcome to Diet Tracker',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Your personal nutrition companion for achieving your health goals',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildFeatureItem(Icons.restaurant, 'Track your meals effortlessly'),
          _buildFeatureItem(Icons.insights, 'Get personalized insights'),
          _buildFeatureItem(Icons.trending_up, 'Reach your goals faster'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            onChanged: (value) => _name = value,
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.cake),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _age = int.tryParse(value) ?? 25,
          ),
          const SizedBox(height: 20),
          const Text('Gender', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'male', label: Text('Male')),
              ButtonSegment(value: 'female', label: Text('Female')),
              ButtonSegment(value: 'other', label: Text('Other')),
            ],
            selected: {_gender},
            onSelectionChanged: (Set<String> selected) {
              setState(() => _gender = selected.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalStatsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Physical Stats',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          const Text('Height (cm)', style: TextStyle(fontSize: 16)),
          Slider(
            value: _height,
            min: 130,
            max: 220,
            divisions: 90,
            label: '${_height.toInt()} cm',
            onChanged: (value) => setState(() => _height = value),
          ),
          Text(
            '${_height.toInt()} cm',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          const Text('Weight (kg)', style: TextStyle(fontSize: 16)),
          Slider(
            value: _weight,
            min: 40,
            max: 150,
            divisions: 110,
            label: '${_weight.toInt()} kg',
            onChanged: (value) => setState(() => _weight = value),
          ),
          Text(
            '${_weight.toInt()} kg',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          const Text('Activity Level', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _activityLevel,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.directions_run),
            ),
            items: const [
              DropdownMenuItem(
                value: 'sedentary',
                child: Text('Sedentary (little exercise)'),
              ),
              DropdownMenuItem(
                value: 'light',
                child: Text('Light (1-3 days/week)'),
              ),
              DropdownMenuItem(
                value: 'moderate',
                child: Text('Moderate (3-5 days/week)'),
              ),
              DropdownMenuItem(
                value: 'active',
                child: Text('Active (6-7 days/week)'),
              ),
              DropdownMenuItem(
                value: 'very_active',
                child: Text('Very Active (athlete)'),
              ),
            ],
            onChanged: (value) => setState(() => _activityLevel = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your goal?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          _buildGoalCard(
            'lose_weight',
            'Lose Weight',
            'Burn fat and get lean',
            Icons.trending_down,
            Colors.orange,
          ),
          const SizedBox(height: 15),
          _buildGoalCard(
            'maintain',
            'Maintain Weight',
            'Stay healthy and balanced',
            Icons.favorite,
            Colors.blue,
          ),
          const SizedBox(height: 15),
          _buildGoalCard(
            'gain_weight',
            'Gain Weight',
            'Build muscle and strength',
            Icons.trending_up,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    String value,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _goal == value;
    return GestureDetector(
      onTap: () => setState(() => _goal = value),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildDietPreferencesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diet Preferences',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          const Text('Diet Type', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildDietChip('standard', 'Standard'),
              _buildDietChip('vegetarian', 'Vegetarian'),
              _buildDietChip('vegan', 'Vegan'),
              _buildDietChip('keto', 'Keto'),
              _buildDietChip('paleo', 'Paleo'),
              _buildDietChip('mediterranean', 'Mediterranean'),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You can change these settings anytime in your profile',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietChip(String value, String label) {
    final isSelected = _dietType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => setState(() => _dietType = value),
      selectedColor: Colors.green.shade100,
    );
  }

  Future<void> _finishOnboarding() async {
    if (_name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    // Calculate targets
    final dailyCalories = CalorieCalculatorService.calculateDailyCalorieTarget(
      UserProfile(
        name: _name,
        age: _age,
        height: _height,
        weight: _weight,
        gender: _gender,
        activityLevel: _activityLevel,
        goal: _goal,
        dietType: _dietType,
      ),
    );

    final macros = CalorieCalculatorService.calculateMacroTargets(
      dailyCalories,
    );
    final water = CalorieCalculatorService.calculateWaterTarget(_weight);

    // Create and save profile
    final profile = UserProfile(
      name: _name,
      age: _age,
      height: _height,
      weight: _weight,
      gender: _gender,
      activityLevel: _activityLevel,
      goal: _goal,
      dietType: _dietType,
      dailyCalorieTarget: dailyCalories,
      proteinTarget: macros['protein']!,
      carbsTarget: macros['carbs']!,
      fatsTarget: macros['fats']!,
      waterTarget: water,
    );

    await StorageService.saveUserProfile(profile);

    // Navigate to dashboard
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
