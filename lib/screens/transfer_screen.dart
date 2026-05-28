import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../database/db_helper.dart';
import '../theme/app_colors.dart';
import '../widgets/newpay_button.dart';
import '../widgets/newpay_input.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final nameController = TextEditingController();
  final keyController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  double currentBalance = 0;
  String userName = 'Cliente';
  int userId = 1;

  final moneyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is Map<String, dynamic>) {
      userId = args['userId'] ?? 1;
      currentBalance = args['currentBalance'] ?? 0;
      userName = args['userName'] ?? 'Cliente';
    }
  }

  Future<void> makeTransfer() async {
    final receiverName = nameController.text.trim();
    final receiverKey = keyController.text.trim();
    final amountText = amountController.text.replaceAll(',', '.').trim();
    final description = descriptionController.text.trim();

    final amount = double.tryParse(amountText);

    if (receiverName.isEmpty ||
        receiverKey.isEmpty ||
        amount == null ||
        amount <= 0) {
      showMessage('Preencha os dados corretamente.');
      return;
    }

    if (amount > currentBalance) {
      showMessage('Saldo insuficiente para realizar a transferência.');
      return;
    }

    final newBalance = currentBalance - amount;

    await DbHelper.instance.saveTransfer(
      receiverName: receiverName,
      receiverKey: receiverKey,
      amount: amount,
      description: description.isEmpty ? 'Transferência NewPay' : description,
    );
    await DbHelper.instance.updateBalance(
      userId: userId,
      newBalance: newBalance,
    );

    final receipt =
        '''
NEWPAY - COMPROVANTE DE TRANSFERÊNCIA

Pagador: $userName
Recebedor: $receiverName
Chave: $receiverKey
Valor: ${moneyFormat.format(amount)}
Descrição: ${description.isEmpty ? 'Transferência NewPay' : description}
Data: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}

Transferência realizada com sucesso pelo app NewPay.
''';

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text(
            'Transferência realizada',
            style: TextStyle(color: AppColors.text),
          ),
          content: Text(
            receipt,
            style: const TextStyle(color: AppColors.muted),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Share.share(receipt);
              },
              child: const Text('Compartilhar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Concluir'),
            ),
          ],
        );
      },
    );
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Transferência'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldo disponível',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 6),
                Text(
                  moneyFormat.format(currentBalance),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          NewPayInput(
            controller: nameController,
            label: 'Nome do recebedor',
            icon: Icons.person_outline,
          ),

          const SizedBox(height: 14),

          NewPayInput(
            controller: keyController,
            label: 'Chave Pix',
            icon: Icons.vpn_key_outlined,
          ),

          const SizedBox(height: 14),

          NewPayInput(
            controller: amountController,
            label: 'Valor',
            icon: Icons.payments_outlined,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 14),

          NewPayInput(
            controller: descriptionController,
            label: 'Descrição',
            icon: Icons.description_outlined,
          ),

          const SizedBox(height: 28),

          NewPayButton(
            text: 'Confirmar transferência',
            onPressed: makeTransfer,
          ),
        ],
      ),
    );
  }
}
