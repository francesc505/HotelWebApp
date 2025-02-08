import 'package:flutter/material.dart';
import 'package:flutter_application_1/BookingRecap.dart';
import 'package:flutter_application_1/Provider/UserProvider.dart';
import 'package:flutter_application_1/RoomPage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BookingPage extends StatefulWidget {
  final int roomId; // Aggiungi roomId per identificare la stanza

  BookingPage({required this.roomId});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  String phoneNumber = '';
  String roomName = 'Stanza Deluxe'; // Nome della stanza predefinito
  String roomDescription = 'Descrizione non disponibile';
  String roomPrice = '100.0'; // Prezzo per persona predefinito
  String roomType = 'Stanza Standard';
  String roomPeople = '4'; // Numero massimo di persone predefinito
  double totalAmount = 0.0;
  int selectedPeople = 1; // Numero di persone selezionate, inizialmente 1
  bool isAvailable = false; // Variabile per verificare la disponibilità
  //bool isCheckingAvailability =
  //  false; // Per gestire il caricamento della verifica

  @override
  void initState() {
    super.initState();
    _loadRoomDetails();
  }

  Future<void> _loadRoomDetails() async {
    // Carica i dati della stanza usando roomId
    List<Map<String, dynamic>> roomData = await getRoomData();
    Map<String, dynamic>? roomDetails = roomData.firstWhere(
      (room) => room['id'] == widget.roomId,
      orElse: () => {
        'nome': 'Stanza non trovata',
        'info': 'Descrizione non disponibile',
        'prezzo': 'N/A',
        'tipo': 'N/A',
        'persone': '0', // Numero di persone
        'image': 'assets/images/default_room.jpg'
      },
    );

    setState(() {
      roomName = roomDetails['nome'];
      roomDescription = roomDetails['info'];
      roomPrice = roomDetails['prezzo'].toString();
      roomType = roomDetails['tipo'];
      roomPeople =
          roomDetails['persone'].toString(); // Salva il numero di persone
    });

    _calculateTotal(); // Ricalcola il totale appena i dati sono caricati
  }

  /* Future<void> _checkAvailability() async {
    setState(() {
      isCheckingAvailability = true;
    });

    try {
      // Recupera il token di autenticazione
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token') ?? '';

      if (accessToken.isEmpty) {
        throw Exception('Token di autenticazione non trovato.');
      }

      // Recupera le date salvate nel SharedPreferences
      final startDate = prefs.getString('inizio') ?? '';
      final endDate = prefs.getString('fine') ?? '';

      if (startDate.isEmpty || endDate.isEmpty) {
        throw Exception('Date non valide.');
      }

      // Recupera l'ID dell'utente dal provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId =
          userProvider.user!.id; // Supponendo che l'ID sia accessibile qui

      if (userId == null) {
        throw Exception('ID utente non trovato.');
      }

      // Corpo della richiesta
      final requestBody = json.encode({
        'nome': roomName, // Nome della stanza
        'inizio': startDate, // Usa la data di inizio
        'fine': endDate, // Usa la data di fine
      });

      final url = Uri.parse(
          'http://localhost:8080/api/available/checkAvailable/try/$userId');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      setState(() {
        isCheckingAvailability = false;
      });

      // Verifica lo stato della risposta
      if (response.statusCode == 200) {
        setState(() {
          isAvailable = true; // Stanza disponibile
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stanza disponibile per le date inserite.')),
        );
      } else {
        setState(() {
          isAvailable = false; // Stanza non disponibile
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Stanza non disponibile per le date inserite.')),
        );
      }
    } catch (e) {
      setState(() {
        isCheckingAvailability = false;
      });
      print('Errore durante la chiamata POST: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    // Recupera i dati dell'utente dal provider
    final userProvider = Provider.of<UserProvider>(context);
    String firstName = userProvider.user!.nome;
    String lastName = userProvider.user!.cognome;
    String? email = userProvider.user!.email;

    return Scaffold(
      appBar: AppBar(
        title: Text('Prenotazione'),
        backgroundColor: Colors.deepPurple,
        elevation: 5,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dettagli prenotazione',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField('Nome', firstName, TextInputType.name),
                    SizedBox(height: 12),
                    _buildTextField('Cognome', lastName, TextInputType.name),
                    SizedBox(height: 12),
                    _buildTextField(
                        'Email', email!, TextInputType.emailAddress),
                    SizedBox(height: 12),
                    _buildPhoneField(),
                    SizedBox(height: 12),
                    _buildRoomDetails(),
                    SizedBox(height: 12),
                    _buildPeopleDropdown(),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _submit();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          backgroundColor:
                              const Color.fromARGB(255, 180, 157, 219),
                          shadowColor: Colors.deepPurple.withOpacity(0.3),
                          elevation: 5,
                        ),
                        child: Text(
                          'Prenota Stanza',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Totale: €$totalAmount',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String initialValue, TextInputType keyboardType) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8),
        ],
      ),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.deepPurple),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        keyboardType: keyboardType,
        enabled: false,
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Telefono',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 8),
            ],
          ),
          child: TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: 'Inserisci il numero di telefono',
              labelStyle: TextStyle(color: Colors.deepPurple),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
            keyboardType: TextInputType.phone,
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildRoomDetails() {
    return Card(
      color: Colors.deepPurple.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              roomName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Descrizione: $roomDescription',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Prezzo per notte: €$roomPrice',
              style: TextStyle(color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Numero di persone',
            style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        DropdownButton<int>(
          value: selectedPeople,
          items: List.generate(
            int.parse(roomPeople),
            (index) => DropdownMenuItem(
              value: index + 1,
              child: Text((index + 1).toString()),
            ),
          ),
          onChanged: (value) {
            setState(() {
              selectedPeople = value!;
              _calculateTotal();
            });
          },
          iconEnabledColor: Colors.deepPurple,
          style:
              TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showPhoneNumber() {
    setState(() {
      phoneNumber = '+39 3913198130';
    });
    // Mostra un dialogo con il numero di telefono
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Numero di telefono'),
        content: Text(phoneNumber),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      // Recupera i dati necessari
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token') ?? '';
      final userId = prefs.get('user_id');
      ; // Questo è un esempio, recupera dinamicamente l'ID utente se necessario
      final roomId = widget.roomId; // Usa l'ID della stanza passato al widget
      final startDate = prefs.getString('inizio') ?? '';
      final endDate = prefs.getString('fine') ?? '';
      final totalPrice = totalAmount; // Usa l'importo totale calcolato

      if (accessToken.isEmpty || startDate.isEmpty || endDate.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: informazioni mancanti.')),
        );
        return;
      }
  
      // Recupera i dati salvati
    
      // Corpo della richiesta
      final requestBody = json.encode({
        'userId': userId,
        'roomId': roomId,
        'startDate': startDate,
        'endDate': endDate,
        'totalPrice': totalPrice,
        'paymentList':
            null, // Se necessario, aggiungi qui i dettagli del pagamento
      });
      try {
        final url =
            Uri.parse('http://localhost:8080/api/booking/finalBook/1');
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: requestBody,
        );

        if (response.statusCode == 200) {
          // final sharedPreferences =
          //      await SharedPreferences.getInstance();
          // La prenotazione è andata a buon fine, reindirizza alla pagina di riepilogo
          final bool result = bool.parse(response.body);
          if (!result) {
            // Mostra un messaggio di errore se il risultato è -1
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Errore nella prenotazione.Verifica le tue prenotazioni.'),
              ),
            );
          } else {
            // Mostra un messaggio di successo
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Prenotazione effettuata con successo!'),
              ),
            );

            // Chiudi il dialogo attuale
            Navigator.pop(context);

            // Navigazione verso la pagina Prenotazioni
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BookingRecap(), // Sostituisci con il nome della tua pagina Prenotazioni
              ),
            );
          }
        } else if (response.statusCode == 400) {
          // Gestisci errore nel caso la prenotazione non vada a buon fine
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Prenotazione già presente o possibile accavallamento tra le prenotazioni, controlla le tue prenotazioni.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore durante la prenotazione.')),
          );
        }
      } catch (e) {
        // Gestisci eventuali errori di rete
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    }
  }

  void _calculateTotal() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final nOn = sharedPreferences.getInt('numberOfNights');
    print("nOn" + nOn.toString());
    print(roomPrice);

    setState(() {
      totalAmount = (double.parse(roomPrice) * nOn!) * selectedPeople;
    });
  }
}
