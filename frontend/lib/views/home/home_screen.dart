// lib/views/home/home_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authViewModel.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the E-commerce App!',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Text(
              'Logged in as: ${authViewModel.userEmail}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            if (kDebugMode) ...[
              const Text(
                'Debug Information:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Token: ${authViewModel.token != null ? "${authViewModel.token!.substring(0, 20)}..." : "No token"}',
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  debugPrint(
                    '==================== STORED TOKEN ====================',
                  );
                  debugPrint('Token: ${authViewModel.token}');
                  debugPrint(
                    '=====================================================',
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Token printed to console'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Print Token to Console'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
