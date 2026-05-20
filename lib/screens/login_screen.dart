import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../theme/app_colors.dart';
import '../widgets/newpay_button.dart';
import '../widgets/newpay_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(text: 'newpay@teste.com');
  final passwordController = TextEditingController(text: '123456');

  bool loading = false;

  Future<void> handleLogin() async {
    setState(() {
      loading = true;
    });

    final user = await DbHelper.instance.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      loading = false;
    });

    if (user != null && mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: user,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail ou senha inválidos'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NewPay',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Seu banco digital simples, rápido e seguro.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),

                  NewPayInput(
                    controller: emailController,
                    label: 'E-mail',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  NewPayInput(
                    controller: passwordController,
                    label: 'Senha',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),

                  const SizedBox(height: 28),

                  NewPayButton(
                    text: loading ? 'Entrando...' : 'Entrar',
                    onPressed: loading ? () {} : handleLogin,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Acesso de teste: newpay@teste.com / 123456',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}