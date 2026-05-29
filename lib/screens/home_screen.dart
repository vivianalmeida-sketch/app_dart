import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? user;
  List<Map<String, dynamic>> transfers = [];

  bool loadedArgs = false;

  final moneyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (loadedArgs) return;

    loadedArgs = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is Map<String, dynamic>) {
      user = args;
    }

    loadData();
  }

  Future<Map<String, dynamic>?> getUpdatedUser() async {
    if (user != null && user?['id'] != null) {
      final users = await DbHelper.instance.getUsers();

      for (final item in users) {
        if (item['id'] == user?['id']) {
          return item;
        }
      }
    }

    return await DbHelper.instance.getUser();
  }

  Future<void> loadData() async {
    final updatedUser = await getUpdatedUser();

    if (updatedUser == null) {
      if (!mounted) return;

      setState(() {
        user = null;
        transfers = [];
      });

      return;
    }

    final dbTransfers = await DbHelper.instance.getTransfers(
      updatedUser['id'] ?? 0,
    );

    if (!mounted) return;

    setState(() {
      user = updatedUser;
      transfers = dbTransfers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = user?['name'] ?? 'Cliente';
    final balance = user?['balance'] ?? 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('NewPay'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Olá, $name',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo disponível',
                    style: TextStyle(color: AppColors.muted, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    moneyFormat.format(balance),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Conta digital ativa',
                    style: TextStyle(color: AppColors.primary, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.attach_money,
                    title: 'Cotação',
                    onTap: () {
                      Navigator.pushNamed(context, '/quotation');
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.pix,
                    title: 'Transferir',
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        '/transfer',
                        arguments: {
                          'userId': user?['id'],
                          'currentBalance': user?['balance'] ?? 0.0,
                          'userName': user?['name'] ?? 'Cliente',
                        },
                      );

                      await loadData();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Últimas transferências',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (transfers.isEmpty)
              const Text(
                'Nenhuma transferência registrada ainda.',
                style: TextStyle(color: AppColors.muted),
              )
            else
              ...transfers.map((transfer) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.arrow_upward, color: Colors.black),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transfer['receiverName'] ?? 'Recebedor',
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              transfer['description'] ?? 'Transferência NewPay',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '- ${moneyFormat.format(transfer['amount'] ?? 0)}',
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
