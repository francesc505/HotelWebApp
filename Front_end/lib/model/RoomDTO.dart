import 'package:flutter_application_1/model/BookingDTO.dart';

class RoomDTO {
  final int? id;
  final String? nome;
  final String? tipo;
  final String? descrizione;
  final double? prezzo;
  final String? imageName;
  final List<BookingDTO> bookingDTOList;

  RoomDTO({
    this.id,
    this.nome,
    this.tipo,
    this.descrizione,
    this.prezzo,
    this.imageName,
    List<BookingDTO>? bookingDTOList, // Optional and nullable
  }) : bookingDTOList = bookingDTOList ?? [];  // Se è null, assegna una lista vuota

  factory RoomDTO.fromJson(Map<String, dynamic> json) {
    return RoomDTO(
      id: json['id'] as int?,
      nome: json['nome'] as String?,
      tipo: json['tipo'] as String?,
      descrizione: json['descrizione'] as String?,
      prezzo: json['prezzo'] as double?,
      imageName: json['imageName'] as String?,
      bookingDTOList: json['bookingDTOList'] != null
          ? List<BookingDTO>.from(json['bookingDTOList'].map((x) => BookingDTO.fromJson(x)))
          : [], // Se bookingDTOList è null, assegna una lista vuota
    );
  }
}
