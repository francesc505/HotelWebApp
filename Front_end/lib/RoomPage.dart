import 'package:flutter/material.dart';
import 'package:flutter_application_1/BookingPage.dart';
import 'package:intl/intl.dart'; // Per formattare la data
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RoomPage extends StatefulWidget {
  final int roomId;

  RoomPage({required this.roomId});

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late int roomId;
  String roomName = "";
  String roomDescription = "";
  String roomPrice = "";
  String roomType = "";
  String roomPeople = ""; // Numero di persone
  List<String> roomImages = []; // Lista dinamica di immagini
  int currentImageIndex = 0;
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  @override
  void initState() {
    super.initState();
    roomId = widget.roomId;
    _loadRoomDetails();
  }

  Future<void> _loadRoomDetails() async {
    List<Map<String, dynamic>> roomData = await getRoomData();
    Map<String, dynamic>? roomDetails = roomData.firstWhere(
      (room) => room['id'] == roomId,
      orElse: () => {
        'nome': 'Stanza non trovata',
        'info': 'Descrizione non disponibile',
        'prezzo': 'N/A',
        'tipo': 'N/A',
        'persone': '0', // Numero di persone
        'image': 'assets/images/default_room.jpeg' // Immagine di fallback
      },
    );

    setState(() {
      roomName = roomDetails['nome'];
      roomDescription = roomDetails['info'];
      roomPrice = roomDetails['prezzo'].toString();
      roomType = roomDetails['tipo'];
      roomPeople =
          roomDetails['persone'].toString(); // Salva il numero di persone

      // Gestisci le immagini in modo sicuro
      if (roomDetails['image'] != null && roomDetails['image'].isNotEmpty) {
        roomImages = [roomDetails['image']];
      } else {
        roomImages = ['assets/images/default_room.jpeg']; // Fallback immagine
      }

      // Se roomImages è vuota o non contiene immagini valide, aggiungi un'immagine di fallback
      if (roomImages.isEmpty) {
        roomImages = ['assets/images/default_room.jpeg'];
      }
    });
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedStartDate) {
      // Verifica se la data selezionata è precedente alla data odierna
      if (picked.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
        // Mostra un messaggio di errore o avviso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("La data selezionata non può essere nel passato")),
        );
      } else {
        setState(() {
          selectedStartDate = picked;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(
            'inizio', selectedStartDate.toString().substring(0, 10));
        print("dataInzio");
        print(selectedStartDate.toString().substring(0, 10));
      }
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedEndDate) {
      setState(() {
        selectedEndDate = picked;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('fine', selectedEndDate.toString().substring(0, 10));
    }
    print("dataFine");
    //print( selectedEndDate.toString().substring(0, 10));
  }

  void _changeImage(int change) {
    setState(() {
      if (roomImages.isNotEmpty) {
        currentImageIndex = (currentImageIndex + change) % roomImages.length;
        if (currentImageIndex < 0) {
          currentImageIndex = roomImages.length - 1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
        backgroundColor: Colors.deepPurple,
        elevation: 5,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        roomImages.isNotEmpty
                            ? roomImages[currentImageIndex]
                            : 'assets/images/default_room.jpeg',
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      )),
                  Positioned(
                    left: 10,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => _changeImage(-1),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onPressed: () => _changeImage(1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                roomName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 10),
              Text(
                roomDescription,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              Divider(height: 30, thickness: 1, color: Colors.grey[300]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _infoCard(Icons.attach_money, 'Prezzo', '€$roomPrice'),
                  _infoCard(Icons.people, 'Tipo', '$roomType'),
                  _infoCard(Icons.person, 'Persone',
                      '$roomPeople '), // Mostra il numero di persone
                ],
              ),
              Divider(height: 30, thickness: 1, color: Colors.grey[300]),
              _dateSelector(
                context,
                selectedStartDate,
                'Data inizio',
                _selectStartDate,
              ),
              SizedBox(height: 20),
              _dateSelector(
                context,
                selectedEndDate,
                'Data fine',
                _selectEndDate,
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();

                    // Verifica se entrambe le date sono selezionate
                    if (selectedStartDate == null || selectedEndDate == null) {
                      // Se una delle date non è selezionata, mostra un messaggio
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Errore'),
                          content: Text(
                              'Inserire le date di inizio e fine per prenotare.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Chiude il dialogo
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Calcola il numero di notti solo se entrambe le date sono selezionate
                      int numberOfNights = selectedEndDate!
                          .difference(selectedStartDate!)
                          .inDays;

                      // Salva il numero di notti nelle SharedPreferences
                      await sharedPreferences.setInt(
                          'numberOfNights', numberOfNights);

                      print("Numero di notti salvato: $numberOfNights");

                      // Naviga alla pagina di prenotazione
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingPage(
                            roomId:
                                roomId, // Passa l'ID della stanza alla BookingPage
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    'Prenota Stanza',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String convertDate(dynamic dateString) {
    try {
      // Se la data è già un oggetto DateTime, formattala direttamente
      if (dateString is DateTime) {
        DateFormat outputFormat = DateFormat('yyyy-MM-dd');
        return outputFormat
            .format(dateString); // Ritorna la data nel formato 'yyyy-MM-dd'
      }

      // Se la data è una stringa nel formato 'dd/MM/yyyy'
      if (dateString is String) {
        // Parso la data dal formato 'dd/MM/yyyy'
        DateFormat inputFormat = DateFormat('dd/MM/yyyy');
        DateTime parsedDate = inputFormat.parse(dateString);

        // Ritorno la data nel formato 'yyyy-MM-dd'
        DateFormat outputFormat = DateFormat('yyyy-MM-dd');
        return outputFormat.format(parsedDate);
      }

      return ""; // Se il tipo di dateString non è valido, restituisci una stringa vuota
    } catch (e) {
      print("Errore nella conversione della data: $e");
      return ""; // Restituisci una stringa vuota in caso di errore
    }
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.deepPurple.withOpacity(0.1),
          child: Icon(icon, color: Colors.deepPurple, size: 30),
        ),
        SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _dateSelector(BuildContext context, DateTime? date, String label,
      Future<void> Function(BuildContext) onSelect) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.calendar_today, color: Colors.deepPurple),
          onPressed: () => onSelect(context),
        ),
        SizedBox(width: 10),
        Text(
          date == null
              ? 'Seleziona $label'
              : '$label: ${DateFormat('dd/MM/yyyy').format(date)}',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }
}

Future<bool> verificaDisponibilita(
    String nomeStanza, String? inizio, String? fine) async {
  try {
    print(inizio);
    print(fine);
    // Recupera il token dalle SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) {
      print("Token non trovato.");
      return false;
    }

    // Crea il corpo della richiesta in formato JSON
    Map<String, dynamic> body = {
      "nome": nomeStanza,
      "inizio": inizio,
      "fine": fine,
    };

    // Esegui la chiamata HTTP
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/available/checkAvailable'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer $token', // Usa il token come Authorization header
      },
      body: json.encode(body),
    );

    // Controlla la risposta
    if (response.statusCode == 200) {
      // Se la risposta è OK (200), interpreta il corpo della risposta
      Map<String, dynamic> responseData = json.decode(response.body);

      // Supponiamo che il campo "disponibile" indichi se la stanza è disponibile
      bool disponibilita = responseData['disponibile'];

      return disponibilita;
    } else {
      print("Errore nella chiamata API: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("Errore nella chiamata HTTP: $e");
    return false;
  }
}

// Funzione per recuperare i dati salvati
Future<List<Map<String, dynamic>>> getRoomData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? roomDataJson = prefs.getString('roomData');

  if (roomDataJson != null) {
    List<dynamic> data = json.decode(roomDataJson);
    return List<Map<String, dynamic>>.from(data);
  } else {
    print('Nessun dato trovato in SharedPreferences.');
    return [];
  }
}
