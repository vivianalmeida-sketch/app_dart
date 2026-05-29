import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool started = false;
  Map<String, dynamic>? user;
  String message = 'Preparando sua conta...';
  String nextRoute = '/home';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (started) return;

    started = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is Map<String, dynamic>) {
      user = args['user'];
      message = args['message'] ?? 'Preparando sua conta...';
      nextRoute = args['nextRoute'] ?? '/home';
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      if (nextRoute == '/login') {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        Navigator.pushReplacementNamed(context, nextRoute, arguments: user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = user?['name'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.45),
                    ),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.primary,
                    size: 46,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'NewPay',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  userName.isEmpty ? message : '$message\n$userName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 34),

                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Validando ambiente seguro',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
