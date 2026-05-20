import 'package:flutter/material.dart';
import '../services/exchange_service.dart';
import '../theme/app_colors.dart';

class QuotationScreen extends StatefulWidget {
  const QuotationScreen({super.key});

  @override
  State<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> {
  final ExchangeService service = ExchangeService();

  bool loading = true;
  Map<String, dynamic>? data;
  String? error;

  @override
  void initState() {
    super.initState();
    loadQuotation();
  }

  Future<void> loadQuotation() async {
    try {
      final result = await service.getDollarQuotation();

      setState(() {
        data = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Não foi possível carregar as cotações.';
        loading = false;
      });
    }
  }

  Widget quotationCard(String title, String keyName) {
    final item = data?[keyName];

    if (item == null) {
      return const SizedBox();
    }

    final bid = item['bid'];
    final high = item['high'];
    final low = item['low'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Valor atual: R\$ $bid',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Máxima: R\$ $high | Mínima: R\$ $low',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Cotação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : error != null
                ? Center(
                    child: Text(
                      error!,
                      style: const TextStyle(color: AppColors.danger),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: loadQuotation,
                    child: ListView(
                      children: [
                        const Text(
                          'Mercado em tempo real',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Acompanhe moedas usadas em compras internacionais e investimentos.',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 24),

                        quotationCard('Dólar Comercial', 'USDBRL'),
                        quotationCard('Euro', 'EURBRL'),
                        quotationCard('Bitcoin', 'BTCBRL'),
                      ],
                    ),
                  ),
      ),
    );
  }
}