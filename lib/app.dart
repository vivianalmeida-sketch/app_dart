import 'package:flutter/material.dart';
import 'package:newpay/screens/lib/screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quotation_screen.dart';
import 'screens/transfer_screen.dart';
import 'screens/qr_scanner_screen.dart';

class NewPayApp extends StatelessWidget {
  const NewPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NewPay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E0A4),
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/loading': (context) => const LoadingScreen(),
        '/home': (context) => const HomeScreen(),
        '/quotation': (context) => const QuotationScreen(),
        '/transfer': (context) => const TransferScreen(),
        '/qr-scanner': (context) => const QrScannerScreen(),
      },
    );
  }
}
