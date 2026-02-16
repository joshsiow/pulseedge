// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'theme/app_theme.dart';
import 'core/app_bootstrap.dart';
import 'ui/login/login_screen.dart';
import 'ui/login/unit_select_screen.dart';
import 'ui/home_screen.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/unit/select', builder: (context, state) => const UnitSelectScreen()),
  ],
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: AppBootstrapGate(
        child: PulseEdgeApp(),
      ),
    ),
  );
}

class PulseEdgeApp extends StatelessWidget {
  const PulseEdgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PulseEdge',
      theme: AppTheme.light,        // Fixed
      darkTheme: AppTheme.dark,     // Fixed
      themeMode: ThemeMode.system,  // Auto-follows macOS dark mode
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

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

    Future.delayed(const Duration(seconds: 5), () {
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
          CustomPaint(painter: ECGGridPainter()),

          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/patek_logo.png', width: 100),
                  const SizedBox(height: 40),
                  Image.asset('assets/icons/pulseedge_logo_black.png', width: 220),
                  const SizedBox(height: 16),
                  Text(
                    'Vital care at the edge',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primary,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 60),
                  Text(
                    'AI-Assisted Offline Clinical Operations',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.darkPrimary),
                  ),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Lottie.asset(
                'assets/animations/heartbeat.lottie.json',
                width: 180,
                repeat: true,
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.color(['**'], value: AppTheme.primary),
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

class ECGGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withOpacity(0.08)
      ..strokeWidth = 1.0;

    const gridSize = 20.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

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