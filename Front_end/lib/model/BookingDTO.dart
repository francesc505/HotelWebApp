import 'package:flutter_application_1/model/PaymentDTO.dart';

enum BookEnum { pending, confirmed, cancelled }  // Enum per gli stati

class BookingDTO {
  final int? id;  // Rende id nullable
  final int? userId;  // Rende userId nullable
  final int? roomId;  // Rende roomId nullable
  final DateTime? startDate;  // Rende startDate nullable
  final DateTime? endDate;  // Rende endDate nullable
  final int? totalPrice;  // Rende totalPrice nullable
  final BookEnum? status;  // Rende status nullable
  final List<PaymentDTO>? paymentList;  // Rende paymentList nullable

  // Costruttore
  BookingDTO({
    this.id,
    this.userId,
    this.roomId,
    this.startDate,
    this.endDate,
    this.totalPrice,
    this.status,
    this.paymentList,
  });

  // Funzione per la conversione da Map (utile per JSON)
  factory BookingDTO.fromJson(Map<String, dynamic> json) {
    return BookingDTO(
      id: json['id'] as int?,  // Gestisce nullable
      userId: json['userId'] as int?,  // Gestisce nullable
      roomId: json['roomId'] as int?,  // Gestisce nullable
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,  // Gestisce nullable
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,  // Gestisce nullable
      totalPrice: json['totalPrice'] as int?,  // Gestisce nullable
      status: json['status'] != null
          ? BookEnum.values.firstWhere(
              (e) => e.toString() == 'BookEnum.' + json['status'])
          : null,  // Gestisce nullable
      paymentList: json['paymentList'] != null
          ? (json['paymentList'] as List)
              .map((item) => PaymentDTO.fromJson(item))
              .toList()
          : null,  // Gestisce nullable
    );
  }

  // Funzione per la conversione in Map (utile per inviare a un back-end)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'roomId': roomId,
      'startDate': startDate?.toIso8601String(),  // Gestisce nullable
      'endDate': endDate?.toIso8601String(),  // Gestisce nullable
      'totalPrice': totalPrice,
      'status': status?.toString().split('.').last,  // Gestisce nullable
      'paymentList': paymentList?.map((item) => item.toJson()).toList(),  // Gestisce nullable
    };
  }
}
