enum PaymentState { pending, completed, failed } // Enum per lo stato del pagamento

class PaymentDTO {
  final int id;
  final int userId; // ID dell'utente (invece dell'oggetto User)
  final String transactionType;
  final PaymentState paymentState;
  final DateTime date;
  final int totalAmount;

  // Costruttore
  PaymentDTO({
    required this.id,
    required this.userId,
    required this.transactionType,
    required this.paymentState,
    required this.date,
    required this.totalAmount,
  });

  // Funzione per la conversione da Map (utile per JSON)
  factory PaymentDTO.fromJson(Map<String, dynamic> json) {
    return PaymentDTO(
      id: json['id'],
      userId: json['userId'],
      transactionType: json['transactionType'],
      paymentState: PaymentState.values.firstWhere(
          (e) => e.toString() == 'PaymentState.' + json['paymentState']),
      date: DateTime.parse(json['date']),
      totalAmount: json['totalAmount'],
    );
  }

  // Funzione per la conversione in Map (utile per inviare a un back-end)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'transactionType': transactionType,
      'paymentState': paymentState.toString().split('.').last, // Solo il nome dell'enum
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
    };
  }
}
