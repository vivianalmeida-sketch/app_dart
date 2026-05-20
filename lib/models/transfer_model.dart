class TransferModel {
  final int? id;
  final String receiverName;
  final String receiverKey;
  final double amount;
  final String description;
  final String createdAt;

  TransferModel({
    this.id,
    required this.receiverName,
    required this.receiverKey,
    required this.amount,
    required this.description,
    required this.createdAt,
  });
}