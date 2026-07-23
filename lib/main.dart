import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'services/session_service.dart';
import 'services/backend_warmup_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';
import 'config/config.dart';

void main() {
  unawaited(_wakeBackend());
  runApp(const ComplaintIQApp());
}

Future<void> _wakeBackend() async {
  try {
    await http
        .get(Uri.parse(Config.baseUrl))
        .timeout(const Duration(seconds: 15));
  } catch (_) {
    // The app remains usable while a cold backend starts or is unavailable.
  } finally {
    BackendWarmupService.markWarmupComplete();
  }
}

class ComplaintIQApp extends StatelessWidget {
  const ComplaintIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ComplaintIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: FutureBuilder<bool>(
        future: SessionService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              backgroundColor: AppTheme.background,
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            );
          }
          return (snapshot.data ?? false)
              ? const MainShell()
              : const LoginScreen();
        },
      ),
    );
  }
}