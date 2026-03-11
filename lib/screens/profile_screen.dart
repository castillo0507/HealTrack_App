import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/health_provider.dart';
import '../widgets/live_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
    return Consumer2<AuthProvider, HealthProvider>(
      builder: (context, auth, health, child) {
        final email = auth.userEmail;
        final displayName = _getDisplayName(email);
        final enabledCategories = health.enabledCategories.length;
        final streak = health.streak;

        return Stack(
          children: [
            const LiveBackground(),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text(
                  'Profile',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3366FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email ?? 'No email available',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(),
                  const SizedBox(height: 24),
                  Text(
                  'Account Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
                  const SizedBox(height: 12),
                  _buildInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: email ?? 'Not set',
                ),
                  const SizedBox(height: 8),
                  _buildInfoTile(
                  icon: Icons.favorite_outline,
                  label: 'Active Streak',
                  value: '$streak day${streak == 1 ? '' : 's'}',
                ),
                  const SizedBox(height: 8),
                  _buildInfoTile(
                  icon: Icons.category_outlined,
                  label: 'Active Categories',
                  value: '$enabledCategories',
                ),
                  const SizedBox(height: 24),
                  Text(
                  'Privacy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
                  const SizedBox(height: 12),
                  Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Your data stays on this device',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'HealTrack stores your health information only on your phone. You can manage or delete your data anytime from Settings.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 24),
                  Text(
                  'Account Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                ),
                  const SizedBox(height: 12),
                  Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Log out'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: Colors.red[700],
                          side: BorderSide(color: Colors.red[300] ?? Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await auth.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.switch_account),
                        label: const Text('Switch account'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF3366FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
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
          Icon(
            icon,
            color: const Color(0xFF3366FF),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
