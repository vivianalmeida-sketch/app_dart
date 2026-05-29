import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
  List<Map<String, dynamic>> contacts = [];
  bool transferDone = false;
  Map<String, dynamic>? receiptData;

  final moneyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  VoidCallback? get scanQrCode => null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is Map<String, dynamic>) {
      userId = args['userId'] ?? 1;
      currentBalance = args['currentBalance'] ?? 0;
      userName = args['userName'] ?? 'Cliente';
    }

    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final users = await DbHelper.instance.getUsers();
    setState(() {
      contacts = users.where((u) => u['id'] != userId).toList();
    });
  }

  Future<void> makeTransfer() async {
    final receiverName = nameController.text.trim();
    final receiverKey = keyController.text.trim();
    final amountText = amountController.text.replaceAll(',', '.').trim();
    final description = descriptionController.text.trim();
    final amount = double.tryParse(amountText);

    if (receiverName.isEmpty || receiverKey.isEmpty || amount == null || amount <= 0) {
      showMessage('Preencha os dados corretamente.');
      return;
    }

    if (amount > currentBalance) {
      showMessage('Saldo insuficiente para realizar a transferência.');
      return;
    }

    final newBalance = currentBalance - amount;

    await DbHelper.instance.saveTransfer(
      userId: userId,
      receiverName: receiverName,
      receiverKey: receiverKey,
      amount: amount,
      description: description.isEmpty ? 'Transferência NewPay' : description,
    );
    await DbHelper.instance.updateBalance(userId: userId, newBalance: newBalance);

    setState(() {
      transferDone = true;
      currentBalance = newBalance;
      receiptData = {
        'receiverName': receiverName,
        'receiverKey': receiverKey,
        'amount': amount,
        'description': description.isEmpty ? 'Transferência NewPay' : description,
        'date': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      };
    });
  }

  Future<void> sharePdf() async {
    if (receiptData == null) return;

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'NewPay - Comprovante de Transferência',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 12),
            pw.Text('Pagador: $userName'),
            pw.SizedBox(height: 8),
            pw.Text('Recebedor: ${receiptData!['receiverName']}'),
            pw.SizedBox(height: 8),
            pw.Text('Chave Pix: ${receiptData!['receiverKey']}'),
            pw.SizedBox(height: 8),
            pw.Text('Valor: ${moneyFormat.format(receiptData!['amount'])}'),
            pw.SizedBox(height: 8),
            pw.Text('Descrição: ${receiptData!['description']}'),
            pw.SizedBox(height: 8),
            pw.Text('Data: ${receiptData!['date']}'),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 12),
            pw.Text(
              'Transferência realizada com sucesso pelo app NewPay.',
              style: pw.TextStyle(color: PdfColors.grey),
            ),
          ],
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'comprovante_newpay.pdf',
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (transferDone && receiptData != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Comprovante'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Transferência realizada!',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      moneyFormat.format(receiptData!['amount']),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _receiptRow('Pagador', userName),
                    _receiptRow('Recebedor', receiptData!['receiverName']),
                    _receiptRow('Chave Pix', receiptData!['receiverKey']),
                    _receiptRow('Descrição', receiptData!['description']),
                    _receiptRow('Data', receiptData!['date']),
                    _receiptRow('Saldo restante', moneyFormat.format(currentBalance)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              NewPayButton(
                text: 'Compartilhar comprovante PDF',
                onPressed: sharePdf,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                const Text('Saldo disponível', style: TextStyle(color: AppColors.muted)),
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

          if (contacts.isNotEmpty) ...[
            const Text(
              'Contatos cadastrados',
              style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...contacts.map((contact) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    contact['name'][0],
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(contact['name'], style: const TextStyle(color: AppColors.text)),
                subtitle: Text(contact['email'], style: const TextStyle(color: AppColors.muted)),
                onTap: () {
                  setState(() {
                    nameController.text = contact['name'];
                    keyController.text = contact['email'];
                  });
                },
              );
            }),
            const SizedBox(height: 20),
          ],

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
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: scanQrCode,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Ler QR Code Pix'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
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

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}