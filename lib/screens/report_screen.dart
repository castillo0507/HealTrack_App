import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/health_provider.dart';
import '../models/health_entry.dart';
import '../widgets/live_background.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (context, provider, child) {
        final weeklyHistory = provider.weeklyHistory;
        final todaySummary = provider.todaySummary;
        final goals = provider.goals;
        
        // Calculate weekly stats
        final weeklyStats = _calculateWeeklyStats(weeklyHistory);
        final recommendations = _generateRecommendations(weeklyStats, goals);
        final healthScore = _calculateHealthScore(weeklyStats, goals);

        return Stack(
          children: [
            const LiveBackground(),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: const Color(0xFF3366FF),
                title: const Text(
                  'Health Report',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareReport(context, weeklyStats, healthScore),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Report Header
                    _buildReportHeader(context, healthScore, weeklyHistory),
                    const SizedBox(height: 24),

                    // Today's Summary
                    _buildSectionTitle(context, 'Today\'s Summary', Icons.today),
                    const SizedBox(height: 12),
                    _buildTodaySummaryCard(context, todaySummary, goals),
                    const SizedBox(height: 24),

                    // Weekly Analysis
                    _buildSectionTitle(context, 'Weekly Analysis', Icons.analytics),
                    const SizedBox(height: 12),
                    _buildWeeklyAnalysisCard(context, weeklyStats, goals),
                    const SizedBox(height: 24),

                    // Health Metrics Breakdown
                    _buildSectionTitle(context, 'Metrics Breakdown', Icons.pie_chart),
                    const SizedBox(height: 12),
                    _buildMetricsBreakdown(context, weeklyStats, goals),
                    const SizedBox(height: 24),

                    // Recommendations
                    _buildSectionTitle(context, 'Recommendations', Icons.lightbulb_outline),
                    const SizedBox(height: 12),
                    _buildRecommendationsCard(context, recommendations),
                    const SizedBox(height: 24),

                    // Trends
                    _buildSectionTitle(context, 'Trends & Patterns', Icons.trending_up),
                    const SizedBox(height: 12),
                    _buildTrendsCard(context, weeklyHistory),
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

  Map<String, dynamic> _calculateWeeklyStats(List<DailyHealthSummary> history) {
    int totalSteps = 0;
    double totalSleep = 0;
    double totalWater = 0;
    int totalCaloriesBurned = 0;
    int totalCaloriesConsumed = 0;
    int totalWorkoutMinutes = 0;
    int totalMeditation = 0;
    List<int> heartRates = [];
    int activeDays = 0;
    int daysWithData = 0;

    for (var day in history) {
      if (day.steps > 0 || day.sleepHours > 0 || day.waterIntake > 0) {
        daysWithData++;
      }
      if (day.steps > 0) {
        totalSteps += day.steps;
        activeDays++;
      }
      totalSleep += day.sleepHours;
      totalWater += day.waterIntake;
      totalCaloriesBurned += day.caloriesBurned.toInt();
      totalCaloriesConsumed += day.nutritionCalories;
      totalWorkoutMinutes += day.workoutMinutes;
      totalMeditation += day.meditationMinutes;
      if (day.heartRate > 0) {
        heartRates.add(day.heartRate);
      }
    }

    final avgHeartRate = heartRates.isNotEmpty 
        ? heartRates.reduce((a, b) => a + b) / heartRates.length 
        : 0.0;

    return {
      'totalSteps': totalSteps,
      'avgSteps': daysWithData > 0 ? totalSteps ~/ daysWithData : 0,
      'totalSleep': totalSleep,
      'avgSleep': daysWithData > 0 ? totalSleep / daysWithData : 0.0,
      'totalWater': totalWater,
      'avgWater': daysWithData > 0 ? totalWater / daysWithData : 0.0,
      'totalCaloriesBurned': totalCaloriesBurned,
      'totalCaloriesConsumed': totalCaloriesConsumed,
      'totalWorkoutMinutes': totalWorkoutMinutes,
      'avgWorkoutMinutes': daysWithData > 0 ? totalWorkoutMinutes ~/ daysWithData : 0,
      'totalMeditation': totalMeditation,
      'avgHeartRate': avgHeartRate,
      'activeDays': activeDays,
      'daysWithData': daysWithData,
    };
  }

  int _calculateHealthScore(Map<String, dynamic> stats, goals) {
    int score = 0;
    
    // Steps (25 points)
    final avgSteps = (stats['avgSteps'] as int).toDouble();
    final stepsGoalPercent = (avgSteps / goals.stepsGoal).clamp(0.0, 1.0);
    score += (stepsGoalPercent * 25).toInt();
    
    // Sleep (25 points)
    final sleepHours = stats['avgSleep'] as double;
    if (sleepHours >= 7 && sleepHours <= 9) {
      score += 25;
    } else if (sleepHours >= 6 || sleepHours <= 10) {
      score += 15;
    } else {
      score += 5;
    }
    
    // Water (20 points)
    final avgWater = stats['avgWater'] as double;
    final waterGoalPercent = (avgWater / goals.waterGoal).clamp(0.0, 1.0);
    score += (waterGoalPercent * 20).toInt();
    
    // Exercise (20 points)
    final avgWorkout = (stats['avgWorkoutMinutes'] as int).toDouble();
    final workoutGoalPercent = (avgWorkout / goals.workoutMinutesGoal).clamp(0.0, 1.0);
    score += (workoutGoalPercent * 20).toInt();
    
    // Active days bonus (10 points)
    final activeDays = (stats['activeDays'] as int).toDouble();
    final activeDaysPercent = (activeDays / 7).clamp(0.0, 1.0);
    score += (activeDaysPercent * 10).toInt();
    
    return score.clamp(0, 100);
  }

  List<Map<String, dynamic>> _generateRecommendations(Map<String, dynamic> stats, goals) {
    List<Map<String, dynamic>> recommendations = [];
    
    // Steps recommendation
    if (stats['avgSteps'] < goals.stepsGoal * 0.5) {
      recommendations.add({
        'icon': Icons.directions_walk,
        'color': Colors.blue,
        'title': 'Increase Daily Steps',
        'description': 'Try to reach at least ${(goals.stepsGoal * 0.7).toInt()} steps daily. Consider taking walking breaks every hour.',
        'priority': 'high',
      });
    } else if (stats['avgSteps'] < goals.stepsGoal) {
      recommendations.add({
        'icon': Icons.directions_walk,
        'color': Colors.blue,
        'title': 'Almost There!',
        'description': 'You\'re close to your step goal. Add a 15-minute walk to reach ${goals.stepsGoal} steps.',
        'priority': 'medium',
      });
    }
    
    // Sleep recommendation
    final avgSleep = stats['avgSleep'] as double;
    if (avgSleep < 6) {
      recommendations.add({
        'icon': Icons.bedtime,
        'color': Colors.purple,
        'title': 'Prioritize Sleep',
        'description': 'Your average sleep of ${avgSleep.toStringAsFixed(1)} hours is below recommended. Aim for 7-9 hours for optimal health.',
        'priority': 'high',
      });
    } else if (avgSleep > 9) {
      recommendations.add({
        'icon': Icons.bedtime,
        'color': Colors.purple,
        'title': 'Adjust Sleep Duration',
        'description': 'Sleeping more than 9 hours may indicate health issues. Consider consulting a doctor if persistent.',
        'priority': 'medium',
      });
    }
    
    // Water recommendation
    if (stats['avgWater'] < goals.waterGoal * 0.6) {
      recommendations.add({
        'icon': Icons.water_drop,
        'color': Colors.cyan,
        'title': 'Stay Hydrated',
        'description': 'Increase water intake to at least ${goals.waterGoal}L daily. Set reminders to drink water regularly.',
        'priority': 'high',
      });
    }
    
    // Exercise recommendation
    if (stats['avgWorkoutMinutes'] < goals.workoutMinutesGoal * 0.5) {
      recommendations.add({
        'icon': Icons.fitness_center,
        'color': Colors.orange,
        'title': 'More Exercise Needed',
        'description': 'Aim for at least ${goals.workoutMinutesGoal} minutes of exercise daily. Start with light activities like walking or yoga.',
        'priority': 'high',
      });
    }
    
    // Heart rate recommendation
    final avgHR = stats['avgHeartRate'] as double;
    if (avgHR > 100 && avgHR > 0) {
      recommendations.add({
        'icon': Icons.favorite,
        'color': Colors.red,
        'title': 'Monitor Heart Rate',
        'description': 'Your average heart rate is elevated. Consider reducing caffeine and stress, and consult a doctor if persistent.',
        'priority': 'high',
      });
    }
    
    // Good job messages
    if (recommendations.isEmpty) {
      recommendations.add({
        'icon': Icons.emoji_events,
        'color': Colors.amber,
        'title': 'Great Progress!',
        'description': 'You\'re meeting your health goals. Keep up the excellent work!',
        'priority': 'positive',
      });
    }
    
    return recommendations;
  }

  Widget _buildReportHeader(
    BuildContext context,
    int healthScore,
    List<DailyHealthSummary> weeklyHistory,
  ) {
    DateTime? startDate;
    DateTime? endDate;

    if (weeklyHistory.isNotEmpty) {
      startDate = weeklyHistory.first.date;
      endDate = weeklyHistory.last.date;
    } else {
      endDate = DateTime.now();
      startDate = endDate.subtract(const Duration(days: 6));
    }

    final dateRangeText =
        '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}';
    Color scoreColor;
    String scoreLabel;
    if (healthScore >= 80) {
      scoreColor = Colors.green;
      scoreLabel = 'Excellent';
    } else if (healthScore >= 60) {
      scoreColor = Colors.blue;
      scoreLabel = 'Good';
    } else if (healthScore >= 40) {
      scoreColor = Colors.orange;
      scoreLabel = 'Fair';
    } else {
      scoreColor = Colors.red;
      scoreLabel = 'Needs Improvement';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scoreColor.withValues(alpha: 0.8), scoreColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Health Report',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateRangeText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  scoreLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$healthScore',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Score',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF3366FF), size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySummaryCard(BuildContext context, DailyHealthSummary? summary, goals) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            Icons.directions_walk, 'Steps',
            '${summary?.steps ?? 0}', '/ ${goals.stepsGoal}',
            (summary?.steps ?? 0) / goals.stepsGoal,
            Colors.blue,
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            Icons.water_drop, 'Water',
            '${(summary?.waterIntake ?? 0).toStringAsFixed(1)}L', '/ ${goals.waterGoal}L',
            (summary?.waterIntake ?? 0) / goals.waterGoal,
            Colors.cyan,
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            Icons.bedtime, 'Sleep',
            '${(summary?.sleepHours ?? 0).toStringAsFixed(1)}h', '/ ${goals.sleepGoal}h',
            (summary?.sleepHours ?? 0) / goals.sleepGoal,
            Colors.purple,
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            Icons.local_fire_department, 'Calories Burned',
            '${(summary?.caloriesBurned ?? 0).toInt()}', 'cal',
            1.0,
            Colors.orange,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, String suffix, double progress, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(width: 4),
                  Text(suffix, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          width: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyAnalysisCard(BuildContext context, Map<String, dynamic> stats, goals) {
    final calorieBalance = stats['totalCaloriesBurned'] - stats['totalCaloriesConsumed'];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  'Total Steps',
                  '${stats['totalSteps']}',
                  'Avg: ${stats['avgSteps']}/day',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  'Total Sleep',
                  '${(stats['totalSleep'] as double).toStringAsFixed(1)}h',
                  'Avg: ${(stats['avgSleep'] as double).toStringAsFixed(1)}h/night',
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  'Calories Burned',
                  '${stats['totalCaloriesBurned']}',
                  '${calorieBalance >= 0 ? '+' : ''}$calorieBalance balance',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  'Workout Time',
                  '${stats['totalWorkoutMinutes']} min',
                  '${stats['activeDays']}/7 active days',
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildStatBox(String label, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMetricsBreakdown(BuildContext context, Map<String, dynamic> stats, goals) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMetricProgress('Steps Goal', stats['avgSteps'] / goals.stepsGoal, Colors.blue),
          const SizedBox(height: 16),
          _buildMetricProgress('Sleep Goal', (stats['avgSleep'] as double) / goals.sleepGoal, Colors.purple),
          const SizedBox(height: 16),
          _buildMetricProgress('Water Goal', (stats['avgWater'] as double) / goals.waterGoal, Colors.cyan),
          const SizedBox(height: 16),
          _buildMetricProgress('Exercise Goal', stats['avgWorkoutMinutes'] / goals.workoutMinutesGoal, Colors.orange),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildMetricProgress(String label, double progress, Color color) {
    final percentage = (progress * 100).clamp(0, 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('$percentage%', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsCard(BuildContext context, List<Map<String, dynamic>> recommendations) {
    return Column(
      children: recommendations.asMap().entries.map((entry) {
        final index = entry.key;
        final rec = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: index < recommendations.length - 1 ? 12 : 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (rec['color'] as Color).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (rec['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(rec['icon'] as IconData, color: rec['color'] as Color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            rec['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        if (rec['priority'] == 'high')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Priority',
                              style: TextStyle(color: Colors.red[700], fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rec['description'] as String,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 800 + (index * 100)));
      }).toList(),
    );
  }

  Widget _buildTrendsCard(BuildContext context, List<DailyHealthSummary> history) {
    // Calculate trends
    String stepsTrend = 'stable';
    String sleepTrend = 'stable';
    
    if (history.length >= 4) {
      final firstHalf = history.sublist(0, history.length ~/ 2);
      final secondHalf = history.sublist(history.length ~/ 2);
      
      final firstHalfSteps = firstHalf.map((d) => d.steps).reduce((a, b) => a + b) / firstHalf.length;
      final secondHalfSteps = secondHalf.map((d) => d.steps).reduce((a, b) => a + b) / secondHalf.length;
      
      if (secondHalfSteps > firstHalfSteps * 1.1) stepsTrend = 'improving';
      if (secondHalfSteps < firstHalfSteps * 0.9) stepsTrend = 'declining';
      
      final firstHalfSleep = firstHalf.map((d) => d.sleepHours).reduce((a, b) => a + b) / firstHalf.length;
      final secondHalfSleep = secondHalf.map((d) => d.sleepHours).reduce((a, b) => a + b) / secondHalf.length;
      
      if (secondHalfSleep > firstHalfSleep * 1.05) sleepTrend = 'improving';
      if (secondHalfSleep < firstHalfSleep * 0.95) sleepTrend = 'declining';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTrendRow('Physical Activity', stepsTrend, Icons.directions_walk, Colors.blue),
          const Divider(height: 24),
          _buildTrendRow('Sleep Quality', sleepTrend, Icons.bedtime, Colors.purple),
        ],
      ),
    ).animate().fadeIn(delay: 1000.ms);
  }

  Widget _buildTrendRow(String label, String trend, IconData icon, Color color) {
    IconData trendIcon;
    Color trendColor;
    String trendText;
    
    switch (trend) {
      case 'improving':
        trendIcon = Icons.trending_up;
        trendColor = Colors.green;
        trendText = 'Improving';
        break;
      case 'declining':
        trendIcon = Icons.trending_down;
        trendColor = Colors.red;
        trendText = 'Declining';
        break;
      default:
        trendIcon = Icons.trending_flat;
        trendColor = Colors.grey;
        trendText = 'Stable';
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Row(
          children: [
            Icon(trendIcon, color: trendColor, size: 20),
            const SizedBox(width: 4),
            Text(trendText, style: TextStyle(color: trendColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  void _shareReport(BuildContext context, Map<String, dynamic> stats, int healthScore) {
    final reportText = '''
📊 Weekly Health Report
━━━━━━━━━━━━━━━━━━━━

🏆 Health Score: $healthScore/100

📈 Weekly Summary:
• Total Steps: ${stats['totalSteps']}
• Average Steps/Day: ${stats['avgSteps']}
• Total Sleep: ${(stats['totalSleep'] as double).toStringAsFixed(1)} hours
• Average Sleep: ${(stats['avgSleep'] as double).toStringAsFixed(1)} hours/night
• Calories Burned: ${stats['totalCaloriesBurned']}
• Workout Time: ${stats['totalWorkoutMinutes']} minutes
• Active Days: ${stats['activeDays']}/7

Generated by HealTrack
''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Report copied! Ready to share.'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Report Preview'),
                content: SingleChildScrollView(child: Text(reportText)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
