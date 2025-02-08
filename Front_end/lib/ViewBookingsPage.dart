import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ViewBookingsPage extends StatefulWidget {
  @override
  _ViewBookingsPageState createState() => _ViewBookingsPageState();
}

class _ViewBookingsPageState extends State<ViewBookingsPage> {
  Timer? _timer; // Timer per il polling periodico
  bool _isTodayChecked =
      false; // Stato del checkbox per visualizzare prenotazioni di oggi

  void initState() {
    super.initState();
    // Carica inizialmente le prenotazioni
    fetchBookings();
    fetchRemoveRequests();
    // Avvia il polling ogni 30 secondi (ad esempio)
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchBookings();
      fetchRemoveRequests();
    });
  }

  @override
  void dispose() {
    // Annulla il timer quando il widget viene distrutto
    _timer?.cancel();
    super.dispose();
  }

  // Metodo per inviare una notifica
  Future<void> sendNotification(BuildContext context, int bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final url = Uri.parse('http://localhost:8080/api/notification/send');
    final body = json.encode({
      "bookingId": bookingId,
      "message": "La tua prenotazione è stata aggiornata!"
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notifica inviata con successo!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nell\'invio della notifica')),
      );
    }
  }

  Future<bool> handleRemoveAction(BuildContext context,
      Map<String, dynamic> bookingData, String action) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      // Aggiungi il parametro "action" al corpo del JSON
      bookingData['action'] = action;

      final url = Uri.parse('http://localhost:8080/api/booking/removeBookRoom');

      // Creazione di una richiesta DELETE personalizzata
      final request = http.Request("DELETE", url)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        })
        ..body = json.encode(bookingData);

      // Invio della richiesta e ottenimento della risposta
      final response = await http.Client().send(request);

      // Gestione della risposta
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Azione completata con successo!')),
        );
        return true;
      } else {
        final responseBody = await response.stream.bytesToString();
        final errorMessage = json.decode(responseBody)['message'] ??
            'Errore nell\'esecuzione dell\'azione';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
      return false;
    }
  }

  // Metodo per recuperare informazioni dell'utente
  Future<Map<String, dynamic>> fetchUserInfo(int bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('http://localhost:8080/api/booking/$bookingId/userInfo'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Errore nel caricamento delle informazioni dell\'utente');
    }
  }

  // Metodo per gestire l'annullamento della prenotazione
  Future<void> handleCancelAction(
      BuildContext context,
      int bookingId,
      int userId,
      int roomId,
      String startDate,
      String endDate,
      double totalPrice,
      String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final url = Uri.parse(
        'http://localhost:8080/api/booking/impossible/delete'); // URL per l'annullamento della prenotazione

    // Crea il corpo del JSON
    final body = json.encode({
      "id": bookingId,
      "userId": userId, // ID dell'utente
      "roomId": roomId, // ID della stanza
      "startDate": startDate, // Data di inizio prenotazione
      "endDate": endDate, // Data di fine prenotazione
      "totalPrice": totalPrice, // Prezzo totale
      "status": status,
      "paymentList": null, // Lista dei pagamenti (null per il momento)
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prenotazione annullata con successo!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nell\'annullare la prenotazione')),
      );
    }
  }

  // Metodo per recuperare tutte le prenotazioni
  Future<List<dynamic>> fetchBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('http://localhost:8080/api/booking/viewAllBooks'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Errore nel caricamento delle prenotazioni');
    }
  }

  // Metodo per recuperare le prenotazioni del giorno
  Future<List<dynamic>> fetchTodayBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('http://localhost:8080/api/booking/view/today'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Errore nel caricamento delle prenotazioni del giorno');
    }
  }

  // Metodo per gestire le richieste di rimozione
  Future<List<dynamic>> fetchRemoveRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('http://localhost:8080/api/booking/seeAllRemoveRequests'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Errore nel caricamento delle richieste di rimozione');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visualizza Prenotazioni'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Column(
        children: [
          // Checkbox personalizzata per visualizzare prenotazioni di oggi
          ListTile(
            leading: Checkbox(
              value: _isTodayChecked,
              onChanged: (bool? value) {
                setState(() {
                  _isTodayChecked = value!;
                });
              },
              activeColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            title: Text(
              'Mostra prenotazioni di oggi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            tileColor: Colors.blue.shade50,
          ),
          ElevatedButton(
            onPressed: () async {
              final requests = await fetchRemoveRequests();
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text('Richiesta ID: ${request['id']}'),
                          subtitle: Text(
                              'Utente ID: ${request['userId']}\nData inizio: ${request['startDate']}\nData fine: ${request['endDate']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final bookingData = {
                                    "id": request['id'],
                                    "userId": request['userId'],
                                    "roomId": request['roomId'],
                                    "startDate": request['startDate'],
                                    "endDate": request['endDate'],
                                    "totalPrice": request['totalPrice'],
                                    "nRooms": request['nrooms'],
                                    "status": request['status'],
                                    "paymentList": null,
                                  };
                                  bool success = await handleRemoveAction(
                                      context, bookingData, 'confirm');
                                  if (success) {
                                    setState(() {
                                      // Ricarica la lista delle richieste dopo la rimozione
                                    });
                                  }
                                },
                                child: Text('Conferma'),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  handleCancelAction(
                                    context,
                                    request['id'],
                                    request['userId'],
                                    request['roomId'],
                                    request['startDate'],
                                    request['endDate'],
                                    request['totalPrice'],
                                    request['status'],
                                  );
                                },
                                child: Text('Annulla'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            child: Text('Richieste'),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _isTodayChecked ? fetchTodayBookings() : fetchBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Errore: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Nessuna prenotazione disponibile',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                } else {
                  final bookings = snapshot.data!;
                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return FutureBuilder<Map<String, dynamic>>(
                        future: fetchUserInfo(booking['id']),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (userSnapshot.hasError) {
                            return Center(
                              child: Text(
                                'Errore: ${userSnapshot.error}',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          } else if (!userSnapshot.hasData) {
                            return Center(
                              child: Text(
                                'Dati utente non disponibili',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            );
                          } else {
                            final user = userSnapshot.data!;
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              elevation: 5,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Prenotazione ID: ${booking['id']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                        'Data inizio: ${booking['startDate']}'),
                                    Text('Data fine: ${booking['endDate']}'),
                                    Text(
                                        'Prezzo totale: €${booking['totalPrice']}'),
                                    Text('Stato: ${booking['status']}'),
                                    SizedBox(height: 16),
                                    Text(
                                      _isTodayChecked
                                          ? 'Stanze prenotate: ${booking['nrooms']}'
                                          : 'Stanze prenotate: ${booking['nRooms']}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'Utente: ${user['nome']} ${user['cognome']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Email: ${user['email']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        sendNotification(
                                            context, booking['id']);
                                      },
                                      child: Text('Inserisci'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
