import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../theme/app_colors.dart';
import '../widgets/newpay_button.dart';
import '../widgets/newpay_input.dart';

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
      showMessage('As senhas não coincidem.');
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

      setState(() {
        loading = false;
      });

      Navigator.pushReplacementNamed(
        context,
        '/loading',
        arguments: {
          'user': user,
          'message': 'Conta criada com sucesso.',
          'nextRoute': '/login',
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void goToLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goToLogin,
        ),
      ),
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
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Preencha os dados para se cadastrar.',
                    style: TextStyle(color: AppColors.muted, fontSize: 16),
                  ),

                  const SizedBox(height: 40),

                  NewPayInput(
                    controller: nameController,
                    label: 'Nome completo',
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 16),

                  NewPayInput(
                    controller: confirmPasswordController,
                    label: 'Confirmar senha',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),

                  const SizedBox(height: 28),

                  NewPayButton(
                    text: loading ? 'Cadastrando...' : 'Criar conta',
                    onPressed: loading ? () {} : handleRegister,
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed: goToLogin,
                      child: const Text(
                        'Já tenho uma conta',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
