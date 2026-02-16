// lib/core/app_bootstrap.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'auth/auth_service.dart';

final bootstrapProvider = FutureProvider<void>((ref) async {
  // 1) DB init
  await AppDatabase.initialize();

  // 2) Auth init (seed admin)
  //await ref.read(authServiceProvider).initialize();
  final auth = ref.read(authServiceProvider);
  await auth.initialize();
});

class AppBootstrapGate extends ConsumerWidget {
  const AppBootstrapGate({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boot = ref.watch(bootstrapProvider);

    return boot.when(
      loading: () => const _BootstrapSplash(),
      error: (e, st) => _BootstrapError(error: e),
      data: (_) => child,
    );
  }
}

class _BootstrapSplash extends StatelessWidget {
  const _BootstrapSplash();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _BootstrapError extends StatelessWidget {
  const _BootstrapError({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Bootstrap failed:\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}