import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/health_provider.dart';
import '../models/health_category.dart';
import '../widgets/live_background.dart';

class AddEntryScreen extends StatefulWidget {
  final HealthCategoryType? initialCategory;

  const AddEntryScreen({super.key, this.initialCategory});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  HealthCategoryType? _selectedCategory;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (context, healthProvider, child) {
        final enabledCategories = healthProvider.enabledCategories;

        return Stack(
          children: [
            const LiveBackground(),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: const Color(0xFF3366FF),
                title: const Text(
                  'Add Entry',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log Health Data',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 8),
                    Text(
                      'Select a category and enter your health metrics',
                      style: TextStyle(color: Colors.grey[600]),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 24),
                    Text(
                      'Select Category',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: enabledCategories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        final isSelected = _selectedCategory == category.type;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category.type;
                              _controllers.clear();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? category.color : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? category.color : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  category.icon,
                                  color: isSelected ? Colors.white : category.color,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(
                              delay: Duration(milliseconds: 300 + (index * 50)),
                            );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    if (_selectedCategory != null) ...[
                      _buildEntryForm(context, healthProvider),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Select a category above to start logging',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 500.ms),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEntryForm(BuildContext context, HealthProvider provider) {
    final fields = _getFieldsForCategory(_selectedCategory!);
    
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            ...fields.map((field) {
              if (!_controllers.containsKey(field['key'])) {
                _controllers[field['key']!] = TextEditingController();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _controllers[field['key']],
                  keyboardType: field['type'] == 'number'
                      ? TextInputType.number
                      : TextInputType.text,
                  decoration: InputDecoration(
                    labelText: field['label'],
                    hintText: field['hint'],
                    suffixText: field['suffix'],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF3366FF),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (field['required'] == 'true' && (value == null || value.isEmpty)) {
                      return 'Please enter ${field['label']?.toLowerCase()}';
                    }
                    return null;
                  },
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveEntry(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3366FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Entry',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  List<Map<String, String>> _getFieldsForCategory(HealthCategoryType type) {
    switch (type) {
      case HealthCategoryType.physicalActivity:
        return [
          {'key': 'steps', 'label': 'Steps', 'hint': 'Enter step count', 'type': 'number', 'suffix': 'steps', 'required': 'true'},
          {'key': 'distance', 'label': 'Distance (optional)', 'hint': 'Enter distance walked/ran', 'type': 'number', 'suffix': 'km', 'required': 'false'},
          {'key': 'weight', 'label': 'Your Weight (optional)', 'hint': 'For accurate calorie calculation', 'type': 'number', 'suffix': 'kg', 'required': 'false'},
        ];
      case HealthCategoryType.heartHealth:
        return [
          {'key': 'heartRate', 'label': 'Current Heart Rate', 'hint': 'Enter BPM', 'type': 'number', 'suffix': 'BPM', 'required': 'true'},
          {'key': 'restingRate', 'label': 'Resting Heart Rate (optional)', 'hint': 'Measured when relaxed', 'type': 'number', 'suffix': 'BPM', 'required': 'false'},
        ];
      case HealthCategoryType.sleepTracking:
        return [
          {'key': 'duration', 'label': 'Sleep Duration', 'hint': 'Hours of sleep', 'type': 'number', 'suffix': 'hours', 'required': 'true'},
          {'key': 'bedtime', 'label': 'Bedtime (optional)', 'hint': 'e.g., 22:30', 'type': 'text', 'suffix': '', 'required': 'false'},
          {'key': 'waketime', 'label': 'Wake Time (optional)', 'hint': 'e.g., 06:30', 'type': 'text', 'suffix': '', 'required': 'false'},
        ];
      case HealthCategoryType.hydration:
        return [
          {
            'key': 'water',
            'label': 'Water Intake',
            'hint': 'Number of glasses (1 glass ≈ 250 ml)',
            'type': 'number',
            'suffix': 'glasses',
            'required': 'true',
          },
        ];
      case HealthCategoryType.mentalWellness:
        return [
          {'key': 'mood', 'label': 'Current Mood', 'hint': 'Great, Good, Okay, Low, Bad', 'type': 'text', 'suffix': '', 'required': 'true'},
          {'key': 'stress', 'label': 'Stress Level', 'hint': 'Rate 1-10 (1=relaxed, 10=very stressed)', 'type': 'number', 'suffix': '/10', 'required': 'false'},
          {'key': 'meditation', 'label': 'Meditation (optional)', 'hint': 'Minutes meditated today', 'type': 'number', 'suffix': 'min', 'required': 'false'},
        ];
      case HealthCategoryType.nutrition:
        return [
          {'key': 'mealName', 'label': 'Meal Name', 'hint': 'e.g., Breakfast, Lunch, Snack', 'type': 'text', 'suffix': '', 'required': 'true'},
          {'key': 'protein', 'label': 'Protein', 'hint': 'Grams of protein', 'type': 'number', 'suffix': 'g', 'required': 'false'},
          {'key': 'carbs', 'label': 'Carbohydrates', 'hint': 'Grams of carbs', 'type': 'number', 'suffix': 'g', 'required': 'false'},
          {'key': 'fat', 'label': 'Fat', 'hint': 'Grams of fat', 'type': 'number', 'suffix': 'g', 'required': 'false'},
        ];
      case HealthCategoryType.exerciseWorkouts:
        return [
          {'key': 'type', 'label': 'Workout Type', 'hint': 'Running, Cycling, Strength, Yoga, Swimming', 'type': 'text', 'suffix': '', 'required': 'true'},
          {'key': 'duration', 'label': 'Duration', 'hint': 'Minutes of exercise', 'type': 'number', 'suffix': 'min', 'required': 'true'},
          {'key': 'intensity', 'label': 'Intensity', 'hint': '1-10 (1=light, 10=maximum effort)', 'type': 'number', 'suffix': '/10', 'required': 'false'},
          {'key': 'weight', 'label': 'Your Weight (optional)', 'hint': 'For accurate calorie calculation', 'type': 'number', 'suffix': 'kg', 'required': 'false'},
        ];
      case HealthCategoryType.vitalSigns:
        return [
          {'key': 'temperature', 'label': 'Body Temperature', 'hint': 'Enter temperature', 'type': 'number', 'suffix': '°F', 'required': 'false'},
          {'key': 'systolic', 'label': 'Systolic BP', 'hint': 'Upper number', 'type': 'number', 'suffix': 'mmHg', 'required': 'false'},
          {'key': 'diastolic', 'label': 'Diastolic BP', 'hint': 'Lower number', 'type': 'number', 'suffix': 'mmHg', 'required': 'false'},
          {'key': 'weight', 'label': 'Weight', 'hint': 'Your current weight', 'type': 'number', 'suffix': 'kg', 'required': 'false'},
          {'key': 'height', 'label': 'Height', 'hint': 'Your height', 'type': 'number', 'suffix': 'cm', 'required': 'false'},
        ];
    }
  }

  // Auto-compute calories from steps
  double _computeCaloriesFromSteps(int steps, {double? weightKg}) {
    // Formula: calories = steps * 0.04 (average)
    // More accurate with weight: calories = steps * 0.00057 * weight(kg)
    final weight = weightKg ?? 70; // default 70kg
    return steps * 0.00057 * weight;
  }

  // Auto-compute calories from workout
  double _computeCaloriesFromWorkout(String workoutType, int minutes, {int? intensity, double? weightKg}) {
    final weight = weightKg ?? 70;
    final intensityFactor = ((intensity ?? 5) / 10) + 0.5; // 0.5 to 1.5
    
    // MET values for different activities
    double met;
    switch (workoutType.toLowerCase()) {
      case 'running':
        met = 9.8;
        break;
      case 'cycling':
        met = 7.5;
        break;
      case 'swimming':
        met = 8.0;
        break;
      case 'strength':
      case 'weight training':
        met = 6.0;
        break;
      case 'yoga':
        met = 3.0;
        break;
      case 'walking':
        met = 3.5;
        break;
      case 'hiit':
        met = 12.0;
        break;
      default:
        met = 5.0; // General exercise
    }
    
    // Calories = MET * weight(kg) * duration(hours) * intensity factor
    return met * weight * (minutes / 60) * intensityFactor;
  }

  // Auto-compute calories from nutrition (macros)
  int _computeCaloriesFromMacros({int? protein, int? carbs, int? fat}) {
    // Protein: 4 cal/g, Carbs: 4 cal/g, Fat: 9 cal/g
    final proteinCal = (protein ?? 0) * 4;
    final carbsCal = (carbs ?? 0) * 4;
    final fatCal = (fat ?? 0) * 9;
    return proteinCal + carbsCal + fatCal;
  }

  // Compute sleep quality from duration
  int _computeSleepQuality(double hours) {
    if (hours >= 7 && hours <= 9) return 10; // Optimal
    if (hours >= 6 && hours < 7) return 7;
    if (hours > 9 && hours <= 10) return 7;
    if (hours >= 5 && hours < 6) return 5;
    if (hours > 10) return 5;
    return 3; // Less than 5 hours
  }

  // Get heart rate status
  String _getHeartRateStatus(int bpm) {
    if (bpm < 60) return 'Below normal (bradycardia)';
    if (bpm >= 60 && bpm <= 100) return 'Normal resting heart rate';
    if (bpm > 100 && bpm <= 120) return 'Elevated';
    return 'High (tachycardia)';
  }

  // Get BP status
  String _getBPStatus(int systolic, int diastolic) {
    if (systolic < 90 || diastolic < 60) return 'Low blood pressure';
    if (systolic < 120 && diastolic < 80) return 'Normal';
    if (systolic < 130 && diastolic < 80) return 'Elevated';
    if (systolic < 140 || diastolic < 90) return 'High BP Stage 1';
    return 'High BP Stage 2';
  }

  // Compute BMI
  double? _computeBMI(double? weightKg, double? heightCm) {
    if (weightKg == null || heightCm == null || heightCm == 0) return null;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  void _saveEntry(BuildContext context, HealthProvider provider) async {
    if (_formKey.currentState!.validate()) {
      try {
        Map<String, dynamic> computedResults = {};
        
        // Update the provider with real-time data based on category
        switch (_selectedCategory!) {
          case HealthCategoryType.physicalActivity:
            final steps = int.tryParse(_controllers['steps']?.text ?? '') ?? 0;
            final weightKg = double.tryParse(_controllers['weight']?.text ?? '');
            final calories = _computeCaloriesFromSteps(steps, weightKg: weightKg);
            await provider.updateSteps(steps, caloriesBurned: calories);
            computedResults = {
              'Calories Burned': '${calories.toStringAsFixed(0)} cal',
              'Distance (est.)': '${(steps * 0.0008).toStringAsFixed(2)} km',
            };
            break;
            
          case HealthCategoryType.heartHealth:
            final heartRate = int.tryParse(_controllers['heartRate']?.text ?? '') ?? 0;
            final restingRate = int.tryParse(_controllers['restingRate']?.text ?? '');
            await provider.updateHeartRate(heartRate, restingBpm: restingRate);
            computedResults = {
              'Status': _getHeartRateStatus(heartRate),
              if (restingRate != null) 'Resting Status': _getHeartRateStatus(restingRate),
            };
            break;
            
          case HealthCategoryType.sleepTracking:
            final duration = double.tryParse(_controllers['duration']?.text ?? '') ?? 0;
            final quality = _computeSleepQuality(duration);
            await provider.updateSleep(duration, quality: quality);
            computedResults = {
              'Sleep Quality': '$quality/10',
              'Status': duration >= 7 && duration <= 9 ? 'Optimal sleep duration' : 
                        duration < 7 ? 'Consider sleeping longer' : 'Slightly oversleeping',
            };
            break;
            
          case HealthCategoryType.hydration:
                final glasses = double.tryParse(_controllers['water']?.text ?? '') ?? 0;
                // 1 glass ≈ 250 ml = 0.25 L
                final waterLiters = glasses * 0.25;
            final dailyGoal = provider.goals.waterGoal;
            await provider.updateWaterIntake(waterLiters);
            final totalToday = provider.todaySummary?.waterIntake ?? waterLiters;
            computedResults = {
                  'Glasses Today': '${(totalToday / 0.25).toStringAsFixed(1)} glasses',
              'Total Today': '${totalToday.toStringAsFixed(1)} L',
              'Progress': '${((totalToday / dailyGoal) * 100).toStringAsFixed(0)}% of daily goal',
            };
            break;
            
          case HealthCategoryType.mentalWellness:
            final mood = _controllers['mood']?.text;
            final stress = int.tryParse(_controllers['stress']?.text ?? '');
            final meditation = int.tryParse(_controllers['meditation']?.text ?? '');
            await provider.updateMentalWellness(
              mood: mood,
              stressLevel: stress,
              meditationMinutes: meditation,
            );
            computedResults = {
              if (stress != null) 'Stress Level': stress <= 3 ? 'Low stress - Good!' : 
                                                  stress <= 6 ? 'Moderate stress' : 'High stress - Take a break',
              if (meditation != null && meditation > 0) 'Meditation Benefit': 'Great! Regular meditation reduces stress',
            };
            break;
            
          case HealthCategoryType.nutrition:
            final protein = int.tryParse(_controllers['protein']?.text ?? '');
            final carbs = int.tryParse(_controllers['carbs']?.text ?? '');
            final fat = int.tryParse(_controllers['fat']?.text ?? '');
            final calories = _computeCaloriesFromMacros(protein: protein, carbs: carbs, fat: fat);
            final mealName = _controllers['mealName']?.text ?? 'Meal';
            await provider.updateNutrition(calories, protein: protein, carbs: carbs);
            final totalCalories = provider.todaySummary?.nutritionCalories ?? calories;
            // Simple analysis based on meal type and macros
            final p = protein ?? 0;
            final c = carbs ?? 0;
            final f = fat ?? 0;
            String macroFocus;
            if (p == 0 && c == 0 && f == 0) {
              macroFocus = 'No macro details provided';
            } else if (p >= c && p >= f) {
              macroFocus = 'High protein meal';
            } else if (c >= p && c >= f) {
              macroFocus = 'High carbohydrate meal';
            } else {
              macroFocus = 'High fat meal';
            }

            String mealSize;
            final dailyCaloriesGoal = provider.goals.caloriesGoal;
            if (dailyCaloriesGoal <= 0) {
              mealSize = 'Meal size relative to day not set';
            } else {
              final ratio = calories / dailyCaloriesGoal;
              if (ratio < 0.25) {
                mealSize = 'Light meal';
              } else if (ratio < 0.5) {
                mealSize = 'Moderate meal';
              } else {
                mealSize = 'Heavy meal';
              }
            }

            computedResults = {
              'Meal': mealName,
              'Meal Calories': '$calories cal',
              'Total Today': '$totalCalories cal',
              'Breakdown': 'P:${protein ?? 0}g C:${carbs ?? 0}g F:${fat ?? 0}g',
              'Macro Focus': macroFocus,
              'Meal Size': mealSize,
            };
            break;
            
          case HealthCategoryType.exerciseWorkouts:
            final workoutType = _controllers['type']?.text ?? '';
            final duration = int.tryParse(_controllers['duration']?.text ?? '') ?? 0;
            final intensity = int.tryParse(_controllers['intensity']?.text ?? '');
            final weightKg = double.tryParse(_controllers['weight']?.text ?? '');
            final calories = _computeCaloriesFromWorkout(workoutType, duration, 
                intensity: intensity, weightKg: weightKg);
            await provider.updateWorkout(
              minutes: duration,
              workoutType: workoutType,
              intensity: intensity,
            );
            // Also add to calories burned
            final currentCalories = provider.todaySummary?.caloriesBurned ?? 0;
            await provider.updateSteps(provider.todaySummary?.steps ?? 0, 
                caloriesBurned: currentCalories + calories);
            computedResults = {
              'Calories Burned': '${calories.toStringAsFixed(0)} cal',
              'Intensity': intensity != null ? (intensity <= 3 ? 'Light' : 
                           intensity <= 6 ? 'Moderate' : 'Vigorous') : 'Moderate',
              'Total Workout Today': '${provider.todaySummary?.workoutMinutes ?? duration} min',
            };
            break;
            
          case HealthCategoryType.vitalSigns:
            final temp = double.tryParse(_controllers['temperature']?.text ?? '');
            final systolic = int.tryParse(_controllers['systolic']?.text ?? '');
            final diastolic = int.tryParse(_controllers['diastolic']?.text ?? '');
            final weight = double.tryParse(_controllers['weight']?.text ?? '');
            final height = double.tryParse(_controllers['height']?.text ?? '');
            await provider.updateVitalSigns(
              temperature: temp,
              systolicBP: systolic,
              diastolicBP: diastolic,
            );
            final bmi = _computeBMI(weight, height);
            computedResults = {
              if (temp != null) 'Temperature Status': temp >= 97 && temp <= 99 ? 'Normal' : 
                                temp < 97 ? 'Below normal' : 'Fever',
              if (systolic != null && diastolic != null) 'BP Status': _getBPStatus(systolic, diastolic),
              if (bmi != null) 'BMI': '${bmi.toStringAsFixed(1)} - ${_getBMICategory(bmi)}',
            };
            break;
        }

        if (mounted) {
          // Show computed results dialog
          _showComputedResultsDialog(context, computedResults);

          // Clear form
          setState(() {
            _selectedCategory = null;
            _controllers.clear();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving entry: $e'),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  void _showComputedResultsDialog(BuildContext context, Map<String, dynamic> results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 28),
            const SizedBox(width: 12),
            const Text('Entry Saved!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Computed Results:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...results.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_right, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey[800], fontSize: 14),
                        children: [
                          TextSpan(
                            text: '${entry.key}: ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: '${entry.value}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
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
