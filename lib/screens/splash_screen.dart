import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'main_shell.dart';
import 'login_screen.dart';

/// First screen: brand mark for ~1.6s while the stored session is restored.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final AuthProvider auth = context.read<AuthProvider>();
    await Future.wait<void>(<Future<void>>[
      auth.bootstrap(),
      Future<void>.delayed(const Duration(milliseconds: 1600)),
    ]);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => auth.status == AuthStatus.signedIn
            ? const MainShell()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: scheme.onPrimary,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.storefront_rounded,
                size: 52,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Kiosk',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: scheme.onPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'a small catalogue, done well',
              style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
