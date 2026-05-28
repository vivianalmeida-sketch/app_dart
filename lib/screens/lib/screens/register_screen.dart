import 'package:flutter/material.dart';
import 'package:newpay/database/db_helper.dart';
import 'package:newpay/theme/app_colors.dart';
import 'package:newpay/widgets/newpay_button.dart';
import 'package:newpay/widgets/newpay_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;

  Future<void> handleRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage('Preencha todos os campos.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      showMessage('Informe um e-mail válido.');
      return;
    }

    if (password.length < 6) {
      showMessage('A senha precisa ter pelo menos 6 caracteres.');
      return;
    }

    if (password != confirmPassword) {
      showMessage('As senhas não conferem.');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final user = await DbHelper.instance.registerUser(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/loading',
        arguments: {'user': user, 'message': 'Criando sua conta digital...'},
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                    'Criar conta',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Abra sua conta NewPay em poucos segundos.',
                    style: TextStyle(color: AppColors.muted, fontSize: 16),
                  ),

                  const SizedBox(height: 34),

                  NewPayInput(
                    controller: nameController,
                    label: 'Nome completo',
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 14),

                  NewPayInput(
                    controller: emailController,
                    label: 'E-mail',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 14),

                  NewPayInput(
                    controller: passwordController,
                    label: 'Senha',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),

                  const SizedBox(height: 14),

                  NewPayInput(
                    controller: confirmPasswordController,
                    label: 'Confirmar senha',
                    icon: Icons.verified_user_outlined,
                    obscureText: true,
                  ),

                  const SizedBox(height: 28),

                  NewPayButton(
                    text: loading ? 'Criando conta...' : 'Criar conta',
                    onPressed: loading ? () {} : handleRegister,
                  ),

                  const SizedBox(height: 22),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'Já tenho uma conta',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Ao continuar, você inicia sua conta com saldo promocional de R\$ 50,00 para testes.',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.4,
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
