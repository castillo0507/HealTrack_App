import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo
              _buildLogo().animate().fadeIn(duration: 500.ms).scale(delay: 200.ms),
              const SizedBox(height: 16),
              // App Name
              Text(
                'HealTrack',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF3366FF),
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 8),
              Text(
                'Privacy-first health tracking',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 32),
              // Security Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your credentials are stored securely. We never access your health data.',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 32),
              // Login/Sign Up Form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Tab Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isLogin = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isLogin ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: _isLogin
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    'Log In',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: _isLogin ? FontWeight.w600 : FontWeight.normal,
                                      color: _isLogin ? Colors.grey[800] : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isLogin = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isLogin ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: !_isLogin
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    'Sign Up',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: !_isLogin ? FontWeight.w600 : FontWeight.normal,
                                      color: !_isLogin ? Colors.grey[800] : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Email Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'your.email@example.com',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF3366FF),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF3366FF),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey[500],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      // Confirm Password (Sign Up only)
                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Confirm Password',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Confirm your password',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF3366FF),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3366FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _isLogin ? 'Log In' : 'Sign Up',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (_isLogin) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            // Handle forgot password
                            _showForgotPasswordDialog();
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: Color(0xFF3366FF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
              const SizedBox(height: 32),
              // Security Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSecurityIndicator(
                    Icons.lock_outline,
                    'End-to-end encrypted',
                  ),
                ],
              ).animate().fadeIn(delay: 800.ms),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSecurityIndicator(
                    Icons.storage_outlined,
                    'Local data storage only',
                  ),
                ],
              ).animate().fadeIn(delay: 900.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3366FF).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(50, 50),
          painter: StethoscopePainter(),
        ),
      ),
    );
  }

  Widget _buildSecurityIndicator(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (_isLogin) {
        authProvider.login(_emailController.text, _passwordController.text);
      } else {
        authProvider.signUp(_emailController.text, _passwordController.text);
      }
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address and we\'ll send you instructions to reset your password.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Password reset email sent!'),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

// Custom painter for stethoscope icon
class StethoscopePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw the tube part
    final tubePaint = Paint()
      ..color = const Color(0xFF3366FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Left ear piece
    path.moveTo(size.width * 0.3, size.height * 0.15);
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.3,
      size.width * 0.35, size.height * 0.45,
    );
    
    // Right ear piece
    path.moveTo(size.width * 0.7, size.height * 0.15);
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.3,
      size.width * 0.65, size.height * 0.45,
    );
    
    // Connect to main tube
    path.moveTo(size.width * 0.35, size.height * 0.45);
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.5,
      size.width * 0.65, size.height * 0.45,
    );
    
    // Main tube down
    path.moveTo(size.width * 0.5, size.height * 0.47);
    path.lineTo(size.width * 0.5, size.height * 0.7);
    
    canvas.drawPath(path, tubePaint);
    
    // Draw the chest piece (purple gradient effect)
    final chestPaint = Paint()
      ..color = const Color(0xFF7C4DFF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    // Curved part at bottom
    final chestPath = Path();
    chestPath.moveTo(size.width * 0.5, size.height * 0.7);
    chestPath.quadraticBezierTo(
      size.width * 0.3, size.height * 0.85,
      size.width * 0.5, size.height * 0.95,
    );
    chestPath.quadraticBezierTo(
      size.width * 0.7, size.height * 0.85,
      size.width * 0.5, size.height * 0.7,
    );
    
    canvas.drawPath(chestPath, chestPaint);
    
    // Ear tips
    final tipPaint = Paint()
      ..color = const Color(0xFF3366FF)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.12),
      4,
      tipPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.12),
      4,
      tipPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
