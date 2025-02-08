import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookingDetails extends StatefulWidget {
  final Map<String, dynamic> booking; // Dati della prenotazione da mostrare

  BookingDetails({required this.booking});

  @override
  _BookingDetailsState createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    // Inizializza i controller con i valori della prenotazione
    _startDateController = TextEditingController(text: widget.booking['startDate']);
    _endDateController = TextEditingController(text: widget.booking['endDate']);

  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _updateBooking() async {
    // Ottieni l'access token dalle SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token') ?? '';

    final url = Uri.parse('http://localhost:8080/api/booking/update/${widget.booking['id']}'); // Endpoint per aggiornare la prenotazione

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,       
      }),
    );

    if (response.statusCode == 200) {
      // Se la risposta è OK, naviga indietro
      Navigator.pop(context, 'Prenotazione aggiornata con successo!');
    } else {
      // Se la risposta non è OK, mostra un messaggio di errore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante l\'aggiornamento della prenotazione')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modifica Prenotazione"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data di inizio:', style: TextStyle(fontSize: 16)),
            TextFormField(
              controller: _startDateController,
              decoration: InputDecoration(
                hintText: 'Inserisci la data di inizio',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Text('Data di fine:', style: TextStyle(fontSize: 16)),
            TextFormField(
              controller: _endDateController,
              decoration: InputDecoration(
                hintText: 'Inserisci la data di fine',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _updateBooking,
              child: Text('Salva Modifiche'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
