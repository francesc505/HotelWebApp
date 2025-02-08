import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/Provider/UserProvider.dart'; // Importa il provider dell'utente
import 'package:flutter_application_1/PaymentPage.dart'; // Importa la pagina per il pagamento

class BookingRecap extends StatefulWidget {
  @override
  _BookingRecapState createState() => _BookingRecapState();
}

class _BookingRecapState extends State<BookingRecap> {
  bool isLoading = true;
  List<Map<String, dynamic>> bookingData = [];
  String errorMessage = '';
  Timer? _timer; // Aggiungi un Timer
  String start = " ";
  String fine = " ";

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();

    // Avvia il polling ogni 30 secondi
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _fetchBookingDetails();
    });
  }

  @override
  void dispose() {
    // Cancella il Timer quando il widget viene distrutto
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyBooking(BuildContext context, int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token') ?? '';

      final url =
          Uri.parse('http://localhost:8080/api/booking/$userId/noDeleted');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          // Mostra il dialogo con i dettagli della prenotazione non eliminabile
          final firstBooking = data.first;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Verifica Prenotazioni'),
                content: Text(
                  'Non è possibile rimuovere la prenotazione effettuata dal '
                  '${firstBooking['startDate']} fino a ${firstBooking['endDate']}.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          // Nessuna prenotazione non eliminabile
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Tutte richieste di eliminazione sono state effettuate.')),
          );
        }
      } else {
        // Errore nella richiesta
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante la verifica.')),
        );
      }
    } catch (e) {
      // Errore nella connessione
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nella connessione al server.')),
      );
    }
  }

  Future<void> _fetchBookingDetails() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user!.id;

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token') ?? '';

      final url =
          Uri.parse('http://localhost:8080/api/booking/$userId/viewMine');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            bookingData = List<Map<String, dynamic>>.from(data);
            print(bookingData.toString());
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Nessuna prenotazione trovata.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Nessuna prenotazione presente.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Errore nella connessione al server.';
        isLoading = false;
      });
    }
  }



  // Funzione per aprire il dialogo di modifica delle date
  void _showDateEditDialog(Map<String, dynamic> booking) async{
    showDialog(
      context: context,
      builder: (BuildContext context) {

              // Funzione per selezionare la data
      Future<void> _selectDate(BuildContext context, bool isStartDate) async {
        final DateTime today = DateTime.now();
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: today,
          firstDate: today, // Non permette di selezionare date precedenti a oggi
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          setState(() {
            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
            if (isStartDate) {
              start = formattedDate;
            } else {
              fine = formattedDate;
            }
          });
        }
      }
        return AlertDialog(
          title: Text('Modifica Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
                 children: [
            ListTile(
              title: Text('Data di inizio: ${start.isNotEmpty ? start : "Non selezionata"}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true), // Seleziona la data di inizio
            ),
            ListTile(
              title: Text('Data di fine: ${fine.isNotEmpty ? fine : "Non selezionata"}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false), // Seleziona la data di fine
            ),
          ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Chiudi il dialogo
              },
              child: Text('Annulla'),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final accessToken = prefs.getString('access_token') ?? '';
                final nRooms = booking['nrooms'];
                final url = Uri.parse(
                    'http://localhost:8080/api/booking/editBook/$start/$fine/$nRooms'); // Modifica l'endpoint

                final response = await http.put(
                  url,
                  headers: {
                    'Authorization': 'Bearer $accessToken',
                    'Content-Type': 'application/json',
                  },
                  body: json.encode({
                    'id': booking['id'], // ID della prenotazione esistente
                    'userId': booking['userId'], // ID dell'utente
                    'roomId': booking['roomId'], // ID della stanza
                    'startDate': booking['startDate'], // Nuova data di inizio
                    'endDate': booking['endDate'], // Nuova data di fine
                    'totalPrice': booking['totalPrice'], // Prezzo totale
                    'status': booking['status'], // Stato della prenotazione
                    'paymentList': booking[
                        'paymentList'], // Lista pagamenti (se necessaria)
                  }),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop(); // Chiudi il dialogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Prenotazione aggiornata!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore durante l\'aggiornamento.')),
                  );
                }
              },
              child: Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Riepilogo Prenotazione"),
        backgroundColor: Colors.blue[400],
        elevation: 4,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Torna alla pagina precedente
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Pulsante "Verifica" separato
                  ElevatedButton(
                    onPressed: () {
                      final userProvider =
                          Provider.of<UserProvider>(context, listen: false);
                      final userId = userProvider.user!.id;
                      _verifyBooking(context, userId!);
                    },
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      backgroundColor: Colors.orange[100],
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Verifica",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 20), // Spazio tra il pulsante e la lista
                  bookingData.isNotEmpty
                      ? Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: bookingData.map((booking) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Icona elimina posizionata in alto a destra
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.lightBlue),
                                              onPressed: () async {
                                                if (booking['status'] ==
                                                    "TERMINATED") {
                                                  // Se il flag è vero, esegui l'azione (navigazione)
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Operazione non permessa'),
                                                        content: Text(
                                                            'Impossibile rimuovere.'),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(); // Chiude il dialog
                                                            },
                                                            child: Text('OK'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  final prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  final accessToken =
                                                      prefs.getString(
                                                              'access_token') ??
                                                          '';

                                                  // Recupera l'id dell'utente
                                                  final userProvider =
                                                      Provider.of<UserProvider>(
                                                          context,
                                                          listen: false);
                                                  final userId =
                                                      userProvider.user!.id;

                                                  final url = Uri.parse(
                                                      'http://localhost:8080/api/booking/removeTry'); // Endpoint per eliminare la prenotazione
                                                  print(booking['roomId']);
                                                  print(booking['totalPrice']);
                                                  // Costruisci il payload JSON
                                                  final body = json.encode({
                                                    "roomId": booking[
                                                        'roomId'], // ID della stanza
                                                    "userId":
                                                        userId, // ID dell'utente
                                                    "startDate": booking[
                                                        'startDate'], // Data di inizio
                                                    "endDate": booking[
                                                        'endDate'], // Data di fine
                                                    "id": booking[
                                                        'id'], // ID della prenotazione
                                                    "status": booking['status'],
                                                    "nRooms": booking['nrooms'],
                                                    "totalPrice":
                                                        booking['totalPrice'],
                                                  });
                                                  try {
                                                    final request =
                                                        http.Request(
                                                            'POST', url)
                                                          ..headers.addAll({
                                                            'Authorization':
                                                                'Bearer $accessToken',
                                                            'Content-Type':
                                                                'application/json',
                                                          })
                                                          ..body = body;

                                                    // Invia la richiesta
                                                    final response =
                                                        await http.Client()
                                                            .send(request);

                                                    if (response.statusCode ==
                                                        200) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  'Richiesta di eliminazione inoltrata, le risponderemo al più presto!')));

                                                      // Rimuovi la prenotazione dalla lista
                                                      //  setState(() {
                                                      //  bookingData.remove(booking);
                                                      // });
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  'Non è possibile rimuovere la prenotazione il giorno stesso della prenotazione, contattare l\'hotel')));
                                                    }
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'Errore nella connessione al server.')));
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                          // Dati prenotazione
                                          Text(
                                            'Data di inizio: ${booking['startDate']}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(height: 15),
                                          Text(
                                            'Data di fine: ${booking['endDate']}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(height: 15),
                                          Text(
                                            'Totale: €${booking['totalPrice']}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(height: 15),
                                          Text(
                                            'Stanze Prenotate: ${booking['nrooms']}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(height: 15),
                                          Text(
                                            'Stato: ${booking['status']}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(
                                              height:
                                                  20), // Distanza tra i dati e i pulsanti
                                          // Colonna che contiene i pulsanti
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              // Pulsante "Modifica Prenotazione"
                                              ElevatedButton(
                                                onPressed: () {
                                                  _showDateEditDialog(booking);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 50,
                                                      vertical: 15),
                                                  backgroundColor:
                                                      Colors.blue[100],
                                                  elevation: 5,
                                                ),
                                                child: Text(
                                                  "Modifica Prenotazione",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                              ),
                                              SizedBox(
                                                  height:
                                                      20), // Spazio tra i pulsanti
                                              // Pulsante "Procedi al Pagamento" (visibile solo se lo stato è 'WAITING')
                                              if (booking['status'] ==
                                                  'WAITING')
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    SharedPreferences prefs =
                                                        await SharedPreferences
                                                            .getInstance();

                                                    // Salva i dettagli della prenotazione
                                                    await prefs.setInt(
                                                        'booking_id',
                                                        booking['id']);
                                                    await prefs.setInt(
                                                        'user_id',
                                                        booking['userId']);
                                                    await prefs.setInt(
                                                        'room_id',
                                                        booking['roomId']);
                                                    await prefs.setString(
                                                        'start_date',
                                                        booking['startDate']);
                                                    await prefs.setString(
                                                        'end_date',
                                                        booking['endDate']);
                                                    await prefs.setDouble(
                                                        'total_price',
                                                        booking['totalPrice']);
                                                    await prefs.setInt('nRooms',
                                                        booking['nrooms']);
                                                    print(
                                                        "STANZEEEEEEEEEEEEEEEE");
                                                    print(booking['nrooms']);
                                                    // Naviga verso la pagina di pagamento
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              PaymentPage()),
                                                    );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 50,
                                                            vertical: 15),
                                                    elevation: 5,
                                                  ),
                                                  child: Text(
                                                    "Procedi al Pagamento",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color:
                                                            Colors.blue[100]),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                ],
              ),
      ),
    );
  }
}
