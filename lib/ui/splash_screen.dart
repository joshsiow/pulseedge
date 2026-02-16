import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();

    // Navigate to login after 4 seconds (adjust as needed)
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle ECG-inspired grid overlay (warm primary color)
          CustomPaint(
            painter: ECGGridPainter(),
          ),

          // Main content - centered branding (matches your deck cover slide)
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Patek Mega Enterprise logo (replace with your actual asset)
                  Image.asset(
                    'assets/icons/patek_logo.png', // Add your "PM" heartbeat logo here
                    width: 120,
                  ),
                  const SizedBox(height: 24),

                  // PulseEdge title
                  Text(
                    'PulseEdge',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppTheme.darkPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'AI-Assisted Offline Clinical Operations',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 48),

                  // Tagline from deck
                  Text(
                    'Vital care at the edge',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.secondary,
                        ),
                  ),
                  const SizedBox(height: 80),

                  // Optional: Tablet mockup or feature icons (add your asset)
                  // Image.asset('assets/icons/tablet_mockup.png', width: 200),
                ],
              ),
            ),
          ),

          // Bottom: Powered by heartbeat animation
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Lottie.asset(
                'assets/animations/heartbeat.lottie.json',
                width: 150,
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.color(
                      ['**'],
                      value: AppTheme.primary, // Tint heartbeat to brand color
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for subtle ECG grid background (matches deck's orange-red grid)
class ECGGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withOpacity(0.08)
      ..strokeWidth = 1.0;

    final gridSize = 20.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Thicker lines every 5 grids (classic ECG paper style)
    final boldPaint = Paint()
      ..color = AppTheme.primary.withOpacity(0.15)
      ..strokeWidth = 2.0;

    for (double x = 0; x < size.width; x += gridSize * 5) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), boldPaint);
    }
    for (double y = 0; y < size.height; y += gridSize * 5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), boldPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}