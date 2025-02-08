class AvailableDTO {
  final int id;
  final String nome;
  final DateTime inizio;
  final DateTime fine;
  final int quantity;

  // Costruttore
  AvailableDTO({
    required this.id,
    required this.nome,
    required this.inizio,
    required this.fine,
    required this.quantity,
  });

  // Metodo per convertire un oggetto JSON in un AvailableDTO
  factory AvailableDTO.fromJson(Map<String, dynamic> json) {
    return AvailableDTO(
      id: json['id'],
      nome: json['nome'],
      inizio: DateTime.parse(json['inizio']),
      fine: DateTime.parse(json['fine']),
      quantity: json['quantity'],
    );
  }

  // Metodo per convertire un oggetto AvailableDTO in JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'inizio': inizio.toIso8601String(),
      'fine': fine.toIso8601String(),
      'quantity': quantity,
    };
  }
}
