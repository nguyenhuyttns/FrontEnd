// lib/main.dart
import 'package:flutter/material.dart';
import 'package:frontend/provider/cart_provider.dart';
import 'package:frontend/view_models/order_view_model.dart';
import 'package:frontend/view_models/user_view_model.dart';
import 'package:frontend/views/auth/forgot_password_screen.dart';
import 'package:frontend/views/auth/reset_password_screen.dart';
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
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
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
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
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

// Thêm class ResetPasswordWrapper vào cuối file
class ResetPasswordWrapper extends StatelessWidget {
  const ResetPasswordWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy token từ URL
    final uri = Uri.parse(ModalRoute.of(context)!.settings.name ?? '');
    final token = uri.queryParameters['token'] ?? '';

    if (token.isEmpty) {
      // Nếu không có token, chuyển hướng về trang đăng nhập
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ResetPasswordScreen(token: token);
  }
}
