import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardTypeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  late int bookingId;
  late int userId;
  late int roomId;
  late String startDate;
  late String endDate;
  late double totalPrice;
  late int nRooms;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bookingId = prefs.getInt('booking_id') ?? 0;
      userId = prefs.getInt('user_id') ?? 0;
      roomId = prefs.getInt('room_id') ?? 0;
      startDate = prefs.getString('start_date') ?? '';
      endDate = prefs.getString('end_date') ?? '';
      totalPrice = prefs.getDouble('total_price') ?? 0.0;
      nRooms = prefs.getInt('nRooms') ?? 0;
    });
  }

  Future<void> _processPayment() async {
    if (_formKey.currentState!.validate()) {
      String cardType = _cardTypeController.text;
      double amount = double.parse(_amountController.text);
      print("STANZEEE 2");
      print(nRooms);
      // Creazione della richiesta POST
      String url =
          "http://localhost:8080/api/payment/dopayment/$amount/$cardType/$nRooms";
      Map<String, dynamic> body = {
        "id": bookingId,
        "userId": userId,
        "roomId": roomId,
        "startDate": startDate,
        "endDate": endDate,
        "totalPrice": totalPrice,
        "status": "WAITING",
        "nRooms": nRooms,
        "paymentList": null,
      };

      try {
        // Recupero dell'access token dalle SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? accessToken = prefs.getString('access_token');

        if (accessToken == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Token di accesso non trovato.")),
          );
          return;
        }

        // Invio della richiesta HTTP POST con il token
        var response = await http.post(
          Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken",
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          // Successo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Pagamento effettuato con successo!")),
          );
          Navigator.pop(context); // Torna alla pagina precedente
        } else {
          // Errore
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Errore durante il pagamento.")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Errore di connessione: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pagamento"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cardTypeController,
                decoration: InputDecoration(
                  labelText: "Tipo di carta (es. MASTERCARD)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Inserisci il tipo di carta";
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: "Importo",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Inserisci l'importo";
                  }
                  double? amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return "Inserisci un importo valido";
                  }
                  if (amount > totalPrice) {
                    return "L'importo non può superare il totale (${totalPrice.toStringAsFixed(2)}€)";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _processPayment,
                child: Text("Paga"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
