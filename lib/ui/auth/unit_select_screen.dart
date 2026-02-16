// lib/ui/auth/unit_select_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../theme/app_theme.dart';
import '../../core/database/app_database.dart';
//import '../../core/auth/auth_service.dart';
//import '../../core/encounters/encounter_repo.dart';  // If needed for unit context

class UnitSelectScreen extends ConsumerStatefulWidget {
  const UnitSelectScreen({super.key});

  @override
  ConsumerState<UnitSelectScreen> createState() => _UnitSelectScreenState();
}

class _UnitSelectScreenState extends ConsumerState<UnitSelectScreen> {
  List<Unit> _units = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final db = AppDatabase.instance;
      _units = await db.select(db.units).get();
    } catch (e) {
      setState(() => _error = 'Failed to load units');
      debugPrint('Unit load error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // to do - Save selected unit to currentUser or session (e.g., update user.unitId)
  // For now, just navigate to home
  Future<void> _selectUnit(Unit unit) async {
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Subtle ECG grid background (matches deck style)
          CustomPaint(painter: ECGGridPainter()),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with logos
                  Row(
                    children: [
                      Image.asset('assets/icons/pulseedge_logo_black.png', width: 180),
                      const Spacer(),
                      Image.asset('assets/icons/patek_logo.png', width: 80),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Select Clinical Unit',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.darkPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose the unit for this session',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.secondary),
                  ),
                  const SizedBox(height: 40),

                  // Loading/Error/Units list
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    Center(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  else if (_units.isEmpty)
                    Center(
                      child: Text(
                        'No units available. Contact admin.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _units.length,
                        itemBuilder: (context, index) {
                          final unit = _units[index];
                          return Card(
                            color: AppTheme.surface,
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.location_on, color: AppTheme.primary, size: 40),
                              title: Text(
                                unit.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.darkPrimary),
                              ),
                              subtitle: Text(
                                'Code: ${unit.code}${unit.facility != null ? ' • ${unit.facility}' : ''}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _selectUnit(unit),
                            ),
                          );
                        },
                      ),
                    ),

                  // Bottom heartbeat animation
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Lottie.asset(
                      'assets/animations/heartbeat.lottie.json',
                      width: 200,
                      repeat: true,
                      delegates: LottieDelegates(
                        values: [
                          ValueDelegate.color(['**'], value: AppTheme.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ECG grid painter (matches deck style)
class ECGGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    const gridSize = 20.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final boldPaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.15)
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