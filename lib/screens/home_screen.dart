import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/health_provider.dart';
import '../providers/auth_provider.dart';
import '../models/health_category.dart';
import '../widgets/health_metric_card.dart';
import '../widgets/live_background.dart';
import 'profile_screen.dart';
import 'add_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  
  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getDisplayName(String? email) {
    if (email == null || email.isEmpty) {
      return 'User';
    }
    final atIndex = email.indexOf('@');
    if (atIndex <= 0) {
      return email;
    }
    final namePart = email.substring(0, atIndex);
    if (namePart.isEmpty) return 'User';
    return namePart[0].toUpperCase() + namePart.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userEmail = authProvider.userEmail;
    final displayName = _getDisplayName(userEmail);

    return Consumer<HealthProvider>(
      builder: (context, healthProvider, child) {
        final summary = healthProvider.todaySummary;
        final enabledCategories = healthProvider.enabledCategories;
        final streak = healthProvider.streak;
        final progress = healthProvider.calculateOverallProgress();

        return Stack(
          children: [
            const LiveBackground(),
            CustomScrollView(
              slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF3366FF),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3366FF),
                          Color(0xFF5B8DEF),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const ProfileScreen(),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.person_outline,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Hello, $displayName!',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('EEEE, MMMM d, yyyy – HH:mm').format(_now),
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Stats Bar
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    'Active Categories',
                                    '${enabledCategories.length}',
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  _buildStatItem(
                                    'Today\'s Progress',
                                    '${(progress * 100).toInt()}%',
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  _buildStatItem(
                                    'Streak',
                                    '$streak days',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Today's Overview Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Today\'s Overview',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              if (widget.onNavigate != null) {
                                widget.onNavigate!(1); // Navigate to Insights tab
                              }
                            },
                            icon: const Icon(
                              Icons.trending_up,
                              size: 16,
                              color: Color(0xFF3366FF),
                            ),
                            label: const Text(
                              'View Insights',
                              style: TextStyle(
                                color: Color(0xFF3366FF),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 16),
                      // Metrics Grid
                      _buildMetricsGrid(context, healthProvider, summary),
                      const SizedBox(height: 24),
                      // Badges
                      Text(
                        'Badges',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ).animate().fadeIn(delay: 900.ms),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBadgeCard(
                              title: _getStreakBadgeTitle(streak),
                              subtitle: 'Login streak: $streak day${streak == 1 ? '' : 's'}',
                              icon: Icons.local_fire_department,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBadgeCard(
                              title: _getActivityBadgeTitle(progress),
                              subtitle: 'Today\'s activity ${(progress * 100).toInt()}%',
                              icon: Icons.emoji_events,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Quick Actions
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ).animate().fadeIn(delay: 800.ms),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickAction(
                              context,
                              icon: Icons.add,
                              label: 'Log Activity',
                              onTap: () {
                                if (widget.onNavigate != null) {
                                  widget.onNavigate!(2); // Navigate to Add Entry tab
                                }
                              },
                            ).animate().fadeIn(delay: 900.ms).slideX(begin: -0.1),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickAction(
                              context,
                              icon: Icons.trending_up,
                              label: 'View Trends',
                              onTap: () {
                                if (widget.onNavigate != null) {
                                  widget.onNavigate!(1); // Navigate to Insights tab
                                }
                              },
                            ).animate().fadeIn(delay: 950.ms).slideX(begin: 0.1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Second row of quick actions
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickAction(
                              context,
                              icon: Icons.water_drop,
                              label: '+1 Glass Water',
                              onTap: () async {
                                await healthProvider.quickAddWater(250);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Added 1 glass of water!'),
                                      backgroundColor: Colors.cyan[600],
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ).animate().fadeIn(delay: 1000.ms).slideX(begin: -0.1),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickAction(
                              context,
                              icon: Icons.directions_walk,
                              label: '+1000 Steps',
                              onTap: () async {
                                await healthProvider.quickAddSteps(1000);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Added 1000 steps!'),
                                      backgroundColor: Colors.blue[600],
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            ).animate().fadeIn(delay: 1050.ms).slideX(begin: 0.1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Third row - View Report
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickAction(
                              context,
                              icon: Icons.assessment,
                              label: 'View Report',
                              onTap: () {
                                if (widget.onNavigate != null) {
                                  widget.onNavigate!(3); // Navigate to Report tab
                                }
                              },
                            ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.1),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickAction(
                              context,
                              icon: Icons.undo,
                              label: 'Undo Activity',
                              onTap: () async {
                                final success = await healthProvider.undoLastActivity();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Last activity undone.'
                                          : 'Nothing to undo yet.',
                                    ),
                                    backgroundColor:
                                        success ? Colors.green[600] : Colors.grey[700],
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ).animate().fadeIn(delay: 1150.ms).slideY(begin: 0.1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Privacy Notice
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: Colors.orange[700],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.orange[900],
                                    fontSize: 13,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Privacy First: ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: 'All your health data is stored locally on your device. No data is sent to external servers.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 1000.ms),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(
    BuildContext context,
    HealthProvider provider,
    dynamic summary,
  ) {
    final enabledCategories = provider.enabledCategories;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: enabledCategories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        return _buildMetricCardForCategory(
          context,
          category,
          summary,
          index,
        );
      }).toList(),
    );
  }

  Widget _buildBadgeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container
    (
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStreakBadgeTitle(int streak) {
    if (streak >= 30) return 'Legendary Streak';
    if (streak >= 14) return 'Champion Streak';
    if (streak >= 7) return 'Golden Streak';
    if (streak >= 3) return 'Getting Consistent';
    if (streak >= 1) return 'Day One Hero';
    return 'Start Your Streak';
  }

  String _getActivityBadgeTitle(double progress) {
    final percent = (progress * 100).round();
    if (percent >= 90) return 'Activity Ace';
    if (percent >= 60) return 'Healthy Habit';
    if (percent >= 30) return 'On Your Way';
    if (percent > 0) return 'First Steps';
    return 'No Activity Yet';
  }

  void _openCategoryEntry(BuildContext context, HealthCategoryType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEntryScreen(initialCategory: type),
      ),
    );
  }

  Widget _buildMetricCardForCategory(
    BuildContext context,
    HealthCategory category,
    dynamic summary,
    int index,
  ) {
    // Get the provider for goals and progress calculation
    final provider = Provider.of<HealthProvider>(context, listen: false);
    final goals = provider.goals;
    
    String value = '';
    String subtitle = '';
    double progress = provider.getProgressForCategory(category.type);

    switch (category.type) {
      case HealthCategoryType.vitalSigns:
        final temp = summary?.temperature ?? 0.0;
        final systolic = summary?.systolicBP ?? 0;
        final diastolic = summary?.diastolicBP ?? 0;
        value = temp > 0 ? '${temp.toStringAsFixed(1)}°F' : '--°F';
        subtitle = systolic > 0 ? 'BP: $systolic/$diastolic' : 'No data yet';
        break;
      case HealthCategoryType.nutrition:
        final calories = summary?.nutritionCalories ?? 0;
        value = calories > 0 ? '$calories cal' : '0 cal';
        subtitle = '/ ${goals.caloriesGoal} cal goal';
        break;
      case HealthCategoryType.hydration:
        final water = summary?.waterIntake ?? 0.0;
        value = '${water.toStringAsFixed(1)} L';
        subtitle = '/ ${goals.waterGoal} L goal';
        break;
      case HealthCategoryType.heartHealth:
        final hr = summary?.heartRate ?? 0;
        final resting = summary?.restingHeartRate ?? 0;
        value = hr > 0 ? '$hr BPM' : '-- BPM';
        subtitle = resting > 0 ? 'Resting: $resting BPM' : 'No data yet';
        break;
      case HealthCategoryType.physicalActivity:
        final steps = summary?.steps ?? 0;
        value = '$steps';
        subtitle = '/ ${goals.stepsGoal} goal';
        break;
      case HealthCategoryType.sleepTracking:
        final sleep = summary?.sleepHours ?? 0.0;
        value = sleep > 0 ? '${sleep.toStringAsFixed(1)} hrs' : '-- hrs';
        subtitle = '/ ${goals.sleepGoal} hrs goal';
        break;
      case HealthCategoryType.mentalWellness:
        final mood = summary?.mood ?? 'Not tracked';
        final meditation = summary?.meditationMinutes ?? 0;
        value = mood;
        subtitle = meditation > 0 ? '$meditation min meditation' : 'Track your mood';
        break;
      case HealthCategoryType.exerciseWorkouts:
        final workout = summary?.workoutMinutes ?? 0;
        final type = summary?.workoutType ?? '';
        value = '$workout min';
        subtitle = type.isNotEmpty ? type : '/ ${goals.workoutMinutesGoal} min goal';
        break;
    }

    return HealthMetricCard(
      title: category.name == 'Physical Activity' ? 'Steps' : 
             category.name == 'Exercise & Workouts' ? 'Workout' : 
             category.name,
      value: value,
      subtitle: subtitle,
      icon: category.icon,
      color: category.color,
      progress: progress,
      onTap: () => _openCategoryEntry(context, category.type),
      onDetailsTap: () => _openCategoryEntry(context, category.type),
    ).animate().fadeIn(delay: Duration(milliseconds: 400 + (index * 100))).scale(
      begin: const Offset(0.95, 0.95),
      delay: Duration(milliseconds: 400 + (index * 100)),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
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
          children: [
            Icon(
              icon,
              color: const Color(0xFF3366FF),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
