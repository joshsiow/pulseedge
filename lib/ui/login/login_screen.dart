// lib/ui/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../theme/app_theme.dart';
import '../../core/auth/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: 'admin123');

  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      final user =
          await auth.login(username, password).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (user != null) {
        context.go('/home');
      } else {
        setState(() => _error = 'Invalid username or password');
      }
    } catch (e) {
      setState(() {
        _error = 'Login failed. Please try again.';
        debugPrint('Login error: $e');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Keep your existing palette; just derive readable on-surface text tones.
    final onSurfaceStrong = AppTheme.darkPrimary;
    final onSurfaceMuted = AppTheme.darkPrimary.withOpacity(0.55);
    final outline = AppTheme.darkPrimary.withOpacity(0.28);
    final fieldFill = Colors.transparent; // keep schema (no new fill color)

    final localTheme = Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelStyle: TextStyle(
          color: onSurfaceMuted,
          fontWeight: FontWeight.w600,
        ),
        labelStyle: TextStyle(
          color: onSurfaceMuted,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: onSurfaceMuted),
        prefixIconColor: onSurfaceMuted,
        suffixIconColor: onSurfaceMuted,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: outline, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.9), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        fillColor: fieldFill,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppTheme.primary,
        selectionColor: AppTheme.primary.withOpacity(0.25),
        selectionHandleColor: AppTheme.primary,
      ),
    );

    return GestureDetector(
      onTap: _unfocus,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Theme(
          data: localTheme,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Give the scroll view a bottom padding so the heartbeat never sits on top of text.
              final bottomSafePad = MediaQuery.of(context).padding.bottom;
              const heartbeatHeight = 140.0;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Background grid
                  CustomPaint(painter: ECGGridPainter()),

                  // Decorative heartbeat (behind content, non-interactive)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 12 + bottomSafePad,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.9,
                        child: Center(
                          child: SizedBox(
                            height: heartbeatHeight,
                            child: Lottie.asset(
                              'assets/animations/heartbeat.lottie.json',
                              fit: BoxFit.contain,
                              delegates: LottieDelegates(
                                values: [
                                  ValueDelegate.color(['**'], value: AppTheme.primary),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(
                          top: 24,
                          bottom: heartbeatHeight + 28, // prevents overlap with footer art
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Card(
                            color: AppTheme.surface,
                            elevation: 14,
                            shadowColor: Colors.black.withOpacity(0.18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Logo
                                    Center(
                                      child: Image.asset(
                                        'assets/icons/pulseedge_logo_black.png',
                                        width: 220,
                                      ),
                                    ),
                                    const SizedBox(height: 18),

                                    Text(
                                      'Clinician Login',
                                      textAlign: TextAlign.center,
                                      style: textTheme.headlineMedium?.copyWith(
                                        color: onSurfaceStrong,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    TextFormField(
                                      controller: _usernameController,
                                      focusNode: _usernameFocus,
                                      enabled: !_loading,
                                      style: TextStyle(color: onSurfaceStrong),
                                      decoration: const InputDecoration(
                                        labelText: 'Username',
                                        prefixIcon: Icon(Icons.person),
                                      ),
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [AutofillHints.username],
                                      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                                      validator: (v) {
                                        final s = (v ?? '').trim();
                                        if (s.isEmpty) return 'Username is required';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    TextFormField(
                                      controller: _passwordController,
                                      focusNode: _passwordFocus,
                                      enabled: !_loading,
                                      style: TextStyle(color: onSurfaceStrong),
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: const Icon(Icons.lock),
                                        suffixIcon: IconButton(
                                          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                                          icon: Icon(
                                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                          ),
                                          onPressed: _loading
                                              ? null
                                              : () => setState(() => _obscurePassword = !_obscurePassword),
                                        ),
                                      ),
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [AutofillHints.password],
                                      onFieldSubmitted: (_) => _login(),
                                      validator: (v) {
                                        final s = v ?? '';
                                        if (s.isEmpty) return 'Password is required';
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 14),

                                    if (_error != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: Colors.red.withOpacity(0.35)),
                                        ),
                                        child: Text(
                                          _error!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                    const SizedBox(height: 18),

                                    SizedBox(
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: _loading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.darkPrimary,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              AppTheme.darkPrimary.withOpacity(0.55),
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: _loading
                                            ? const SizedBox(
                                                height: 22,
                                                width: 22,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.2,
                                                ),
                                              )
                                            : const Text(
                                                'Login',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                              ),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    Text(
                                      'Pilot default: admin / admin123\nChange password after first login',
                                      textAlign: TextAlign.center,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: onSurfaceMuted, // increased contrast vs secondary
                                        height: 1.3,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ECG grid painter (matches deck style)
class ECGGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final minor = Paint()
      ..color = AppTheme.primary.withOpacity(0.08)
      ..strokeWidth = 1.0;

    const gridSize = 20.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), minor);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), minor);
    }

    final major = Paint()
      ..color = AppTheme.primary.withOpacity(0.14)
      ..strokeWidth = 2.0;

    for (double x = 0; x < size.width; x += gridSize * 5) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), major);
    }
    for (double y = 0; y < size.height; y += gridSize * 5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), major);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}