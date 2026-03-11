import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/settings_provider.dart';
import '../providers/health_provider.dart';
import '../widgets/live_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, HealthProvider>(
      builder: (context, settingsProvider, healthProvider, child) {
        return Stack(
          children: [
            const LiveBackground(),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: const Color(0xFF1A237E),
                title: const Text(
                  'Settings',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage your preferences and data',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      context,
                      title: 'Data Collection Consent',
                      icon: Icons.toggle_on_outlined,
                      delay: 200,
                      children: [
                        Text(
                          'Control what health metrics you want to track. Disabling a feature will stop data collection immediately.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildConsentToggle(
                          context,
                          title: 'Step Counter',
                          subtitle: 'Track your daily steps',
                          value: settingsProvider.stepCounterEnabled,
                          onChanged: settingsProvider.toggleStepCounter,
                        ),
                        const Divider(height: 24),
                        _buildConsentToggle(
                          context,
                          title: 'Sleep Tracking',
                          subtitle: 'Monitor sleep patterns',
                          value: settingsProvider.sleepTrackingEnabled,
                          onChanged: settingsProvider.toggleSleepTracking,
                        ),
                        const Divider(height: 24),
                        _buildConsentToggle(
                          context,
                          title: 'Heart Rate Monitor',
                          subtitle: 'Track cardiovascular health',
                          value: settingsProvider.heartRateEnabled,
                          onChanged: settingsProvider.toggleHeartRate,
                        ),
                        const Divider(height: 24),
                        _buildConsentToggle(
                          context,
                          title: 'Hydration',
                          subtitle: 'Track your daily water intake',
                          value: settingsProvider.hydrationEnabled,
                          onChanged: settingsProvider.toggleHydration,
                        ),
                        const Divider(height: 24),
                        _buildConsentToggle(
                          context,
                          title: 'Nutrition',
                          subtitle: 'Track meals and calories',
                          value: settingsProvider.nutritionEnabled,
                          onChanged: settingsProvider.toggleNutrition,
                        ),
                        const Divider(height: 24),
                        _buildConsentToggle(
                          context,
                          title: 'Mental Wellness',
                          subtitle: 'Track mood and stress',
                          value: settingsProvider.mentalWellnessEnabled,
                          onChanged: settingsProvider.toggleMentalWellness,
                        ),
                        const Divider(height: 24),
                        _buildConsentToggle(
                          context,
                          title: 'Exercise & Workouts',
                          subtitle: 'Track your workout sessions',
                          value: settingsProvider.workoutEnabled,
                          onChanged: settingsProvider.toggleWorkout,
                        ),
                        const Divider(height: 24),
                        _buildConsentToggle(
                          context,
                          title: 'Vital Signs',
                          subtitle: 'Track blood pressure and more',
                          value: settingsProvider.vitalSignsEnabled,
                          onChanged: settingsProvider.toggleVitalSigns,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionCard(
                      context,
                      title: 'Data Management',
                      icon: Icons.folder_outlined,
                      delay: 400,
                      children: [
                        _buildActionButton(
                          context,
                          icon: Icons.download_outlined,
                          label: 'Export My Data',
                          subtitle: 'Download all your health data as a PDF',
                          onTap: () => _showExportDialog(context, settingsProvider),
                        ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          context,
                          icon: Icons.delete_outline,
                          label: 'Delete All My Data',
                          subtitle: 'Permanently remove all tracked health data',
                          isDestructive: true,
                          onTap: () => _showDeleteDialog(context, settingsProvider),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consent Withdrawal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You can withdraw your consent for any data collection at any time by toggling off the switches above. Data collection will stop immediately.',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'To completely remove all data, use the "Delete All My Data" option above.',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: Colors.amber[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Your Data is Safe',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSafetyItem('Stored only on your device'),
                          _buildSafetyItem('Never sent to external servers'),
                          _buildSafetyItem('Not shared with third parties'),
                          _buildSafetyItem('Not used for advertising'),
                          _buildSafetyItem('You have complete control'),
                        ],
                      ),
                    ).animate().fadeIn(delay: 800.ms),
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

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required int delay,
    required List<Widget> children,
  }) {
    return Container(
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
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF3366FF),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.1);
  }

  Widget _buildConsentToggle(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF3366FF),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDestructive ? Colors.red.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.grey[700],
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDestructive ? Colors.red[300] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.check,
            color: Colors.green[600],
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Your health data will be exported as a JSON file. This includes all your tracked metrics and history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.exportData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data exported successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'Are you sure you want to permanently delete all your health data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data has been deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
