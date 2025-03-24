// lib/main.dart
import 'package:flutter/material.dart';
import 'package:frontend/provider/cart_provider.dart';
import 'package:provider/provider.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/home/home_screen.dart';
import 'view_models/product_view_model.dart';
import 'view_models/auth_view_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        // Thêm các provider khác nếu cần
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopEase',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Định nghĩa các routes
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

// Widget này kiểm tra trạng thái đăng nhập và điều hướng phù hợp
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    // Kiểm tra nếu người dùng đã đăng nhập
    if (authViewModel.isLoggedIn) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}
