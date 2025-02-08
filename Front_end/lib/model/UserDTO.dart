import 'package:flutter_application_1/model/BookingDTO.dart';

class UserDTO {
  final int? id;
  final String username;
 // final String password;
  final String cognome;
  final String nome;
  final String? email;

  final List<BookingDTO>? bookingDTOList;

  // Costruttore
  UserDTO({
    this.id,
   // required this.password,
    required this.username,
    required this.cognome,
    required this.nome,
    this.email,
    this.bookingDTOList,
  });

  // Funzione per la conversione da Map (utile per JSON)
  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'] ?? null,
      //password: json['password'],
      username: json['username'],
      cognome: json['cognome'],
      nome: json['nome'],
      email: json['email'] ?? '',
      bookingDTOList: json['bookingDTOList'] != null
          ? (json['bookingDTOList'] as List)
              .map((item) => BookingDTO.fromJson(item))
              .toList()
          : [], // Se è null, ritorna una lista vuota
    );
  }

  // Funzione per la conversione in Map (utile per inviare a un back-end)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      //'password': password,
      'username': username,
      'cognome': cognome,
      'nome': nome,
      'email': email,
      'bookingDTOList': bookingDTOList!.map((item) => item.toJson()).toList(),
    };
  }
}
