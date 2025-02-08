import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/BookingRecap.dart';
import 'package:flutter_application_1/RoomPage.dart';
import 'package:flutter_application_1/editProfilePage.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/model/UserDTO.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Provider/UserProvider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> imageData = [];
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _numberOfRoomsController = TextEditingController();
  final _roomTypeController = TextEditingController();

  final TextEditingController _startDateController =
      TextEditingController(); // Controller per la data di inizio
  final TextEditingController _endDateController = TextEditingController();

  final TextEditingController _startDateController2 =
      TextEditingController(); // Controller per la data di inizio
  final TextEditingController _endDateController2 = TextEditingController();
  bool isVerified = false;
  Timer? _timer; // Variabile Timer
  int _pollingInterval = 30; // Intervallo di polling in secondi
  Map<String, int> nomi = {};

  void _showBookingDialog(data) {
    showDialog(
      context: context,
      builder: (context) {
        bool isVerified = false; // Stato locale per il bottone
        String stanza = _roomTypeController.text;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Dettagli prenotazione per la stanza $stanza'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _numberOfRoomsController,
                      decoration:
                          const InputDecoration(labelText: 'Numero di stanze'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.parse(value) < 1) {
                          return 'Inserisci il numero di stanze in maniera corretta';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _startDateController,
                      decoration: InputDecoration(labelText: 'Data di inizio'),
                      readOnly: true,
                      onTap: () => _selectDate(context, _startDateController),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Seleziona una data di inizio';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _endDateController,
                      decoration: InputDecoration(labelText: 'Data di fine'),
                      readOnly: true,
                      onTap: () => _selectDate(context, _endDateController),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Seleziona una data di fine';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Annulla'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (!isVerified) {
                        // Logica per verificare disponibilità
                        String numberOfRooms = _numberOfRoomsController.text;
                        //String roomType = _roomTypeController.text;
                        String startDate = _startDateController.text;
                        String endDate = _endDateController.text;

                        DateTime startDateParsed =
                            DateFormat('yyyy-MM-dd').parse(startDate);
                        DateTime endDateParsed =
                            DateFormat('yyyy-MM-dd').parse(endDate);
                        int numberOfNights =
                            endDateParsed.difference(startDateParsed).inDays;
                        int numberOfRoomsInt = int.parse(numberOfRooms);
                        int numberOfPeople = int.parse(data['persone']);

                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String? token = prefs.getString('access_token');
                        final userId = prefs.getInt('user_id');

                        if (token == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Token non trovato. Effettua il login.'),
                            ),
                          );
                          return;
                        }

                        final url = Uri.parse(
                            'http://localhost:8080/api/booking/newBook/$numberOfRoomsInt');

                        final requestBody = {
                          "userId": userId,
                          "roomId": data['id'],
                          "startDate": startDate,
                          "endDate": endDate,
                          //"nrooms":numberOfRoomsInt,
                          "totalPrice": (numberOfNights - 1) *
                              numberOfRoomsInt *
                              (numberOfPeople * data['prezzo']),
                          "paymentList": null
                        };

                        // Effettua la richiesta
                        try {
                          final response = await http.post(
                            url,
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization':
                                  'Bearer $token', // Passa il token come header
                            },
                            body: jsonEncode(requestBody),
                          );

                          if (response.statusCode == 200) {
                            setState(() {
                              isVerified = true; // Cambia il bottone
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Le stanze sono disponibili!'),
                              ),
                            );
                          } else if (response.statusCode == 400) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Hai già effettuato delle prenotazioni per queste date, o c\'è un accavallamento di date!. Verifica la sezione PRENOTAZIONI'),
                              ),
                            );
                          } else if (response.statusCode == 401) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Errore nella verifica della prenotazione.'),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Errore di connessione al server.'),
                            ),
                          );
                        }
                      } else {
                        String numberOfRooms = _numberOfRoomsController.text;

                        String startDate = _startDateController.text;
                        String endDate = _endDateController.text;
                        DateTime startDateParsed =
                            DateFormat('yyyy-MM-dd').parse(startDate);
                        DateTime endDateParsed =
                            DateFormat('yyyy-MM-dd').parse(endDate);
                        int numberOfNights =
                            endDateParsed.difference(startDateParsed).inDays;
                        // Esegui la chiamata HTTP per la prenotazione
                        final url = Uri.parse(
                            'http://localhost:8080/api/booking/finalBook/$numberOfRooms');

                        // Recupera il token dalle SharedPreferences
                        final sharedPreferences =
                            await SharedPreferences.getInstance();
                        final token =
                            sharedPreferences.getString('access_token');

                        final userId = sharedPreferences.getInt('user_id');
                        int numberOfRoomsInt = int.parse(numberOfRooms);
                        sharedPreferences.setInt('nRoooms', numberOfRoomsInt);

                        int numberOfPeople = int.parse(data['persone']);
                     /*   print((numberOfNights - 1) *
                            numberOfRoomsInt *
                            (numberOfPeople * data['prezzo']));
*/
                        //int prova = int.parse(data['prezzo']);
                        // Corpo della richiesta
                        final requestBody = {
                          "userId": userId,
                          "roomId": data['id'],
                          "startDate": startDate,
                          "endDate": endDate,
                          //"nrooms":numberOfRoomsInt,
                          "totalPrice": (numberOfNights - 1) *
                              numberOfRoomsInt *
                              (numberOfPeople * data['prezzo']),
                          "paymentList": null
                        };

                        // Effettua la richiesta
                        try {
                          final response = await http.post(
                            url,
                            headers: {
                              'Content-Type': 'application/json',
                              'Authorization':
                                  'Bearer $token', // Passa il token come header
                            },
                            body: jsonEncode(requestBody),
                          );
                          
                          if (response.statusCode == 200) {
                            // Converte il corpo della risposta in un intero
                            final bool result = bool.parse(response.body);

                            if (!result) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );
                            } else {
                              
                              // Mostra un messaggio di successo
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Prenotazione effettuata con successo!'),
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

                              // Ripristina lo stato iniziale
                              setState(() {
                                isVerified = false;
                              });
                            }
                          } else {
                            // Errore nella prenotazione
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Errore durante la prenotazione: ${response.body}'),
                              ),
                            );
                          }
                        } catch (e) {
                          // Gestione degli errori di connessione o altro
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Errore di connessione: $e'),
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isVerified ? Colors.green : Colors.blue,
                  ),
                  child: Text(isVerified ? 'Prenota' : 'Verifica'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Funzione per selezionare la data
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime
          .now(), // Impedisce di selezionare una data inferiore al giorno attuale
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = "${picked.toLocal()}".split(' ')[0]; // Formatta la data
    }
  }

  // Funzione per cambiare la pagina selezionata
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final accessToken = prefs.getString('access_token');

    if (username != null && accessToken != null) {
      final url =
          Uri.parse('http://localhost:8080/api/user/giveUserParams/$username');
      try {
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          //print('Dati ricevuti: $data');

          UserDTO user = UserDTO.fromJson(data);

          if (data.containsKey('id')) {
            final userId = data['id'];
            await prefs.setInt('user_id', userId);
            print('ID utente salvato: $userId');
          }

          Provider.of<UserProvider>(context, listen: false).updateUser(user);
        } else if (response.statusCode == 401) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
        } else {
          print('Errore: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Errore durante la richiesta: $e');
      }
    } else {
      print('Username o token non trovati');
    }
  }

  Future<void> searchRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (!_priceController.text.isEmpty &&
        !_typeController.text.isEmpty &&
        !_peopleController.text.isEmpty &&
        _startDateController2.text.isNotEmpty &&
        _endDateController2.text.isNotEmpty) {
      if (accessToken != null) {
        final startDate = _startDateController2.text;
        final endDate = _endDateController2.text;
        final price = _priceController.text;
        final type = _typeController.text.toUpperCase();
        final people = _peopleController.text;

        final url = Uri.parse(
            'http://localhost:8080/api/room/find/room/$startDate/$endDate/$price/$type/$people');

        try {
          final response = await http.get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          );

          if (response.statusCode == 200) {
            final List<dynamic> data = json.decode(response.body);
            //print('Dati stanze trovate: $data');

            if (data.isEmpty) {
              print('Nessuna stanza trovata');
            }

            List<Map<String, dynamic>> roomData = data.map((room) {
              return {
                'image': 'assets/images/${room['imageName']}',
                'info': room['descrizione'],
                'nome': room['nome'],
                'prezzo': room['prezzo'],
                'tipo': room['tipo'],
                'persone': room['persone'],
                'id': room['id'],
              };
            }).toList();

            setState(() {
              imageData = roomData;
            });

            if (imageData.isNotEmpty) {
              print('Stanze trovate: $imageData');
            } else {
              print('Nessuna stanza disponibile per la ricerca');
            }
          } else {
            print('Errore: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          print('Errore durante la richiesta: $e');
        }
      } else {
        print('Token non trovato');
      }
    } else if (!_priceController.text.isEmpty &&
        !_typeController.text.isEmpty &&
        !_peopleController.text.isEmpty) {
      if (accessToken != null) {
        final price = _priceController.text;
        final type = _typeController.text.toUpperCase();
        final people = _peopleController.text;

        final url = Uri.parse(
            'http://localhost:8080/api/room/find/room/$price/$type/$people');
        try {
          final response = await http.get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          );

          if (response.statusCode == 200) {
            final List<dynamic> data = json.decode(response.body);
          //  print('Dati stanze trovate: $data');

            if (data.isEmpty) {
              print('Nessuna stanza trovata');
            }

            List<Map<String, dynamic>> roomData = data.map((room) {
              return {
                'image': 'assets/images/${room['imageName']}',
                'info': room['descrizione'],
                'nome': room['nome'],
                'prezzo': room['prezzo'],
                'tipo': room['tipo'],
                'persone': room['persone'],
                'id': room['id'],
              };
            }).toList();

            setState(() {
              imageData = roomData;
            });

            if (imageData.isNotEmpty) {
              print('Stanze trovate: $imageData');
            } else {
              print('Nessuna stanza disponibile per la ricerca');
            }
          } else {
            print('Errore: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          print('Errore durante la richiesta: $e');
        }
      } else {
        print('Token non trovato');
      }
    } else if (_startDateController2.text.isNotEmpty &&
        _endDateController2.text.isNotEmpty) {
      // Se le date sono presenti
      if (accessToken != null) {
        final startDate = _startDateController2.text;
        final endDate = _endDateController2.text;

        final url = Uri.parse(
            'http://localhost:8080/api/room/find/room/$startDate/$endDate');
        try {
          final response = await http.get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          );

          if (response.statusCode == 200) {
            final List<dynamic> data = json.decode(response.body);
          //  print('Dati stanze trovate per le date: $data');

            List<Map<String, dynamic>> roomData = data.map((room) {
              return {
                'image': 'assets/images/${room['imageName']}',
                'info': room['descrizione'],
                'nome': room['nome'],
                'prezzo': room['prezzo'],
                'tipo': room['tipo'],
                'persone': room['persone'],
                'id': room['id'],
              };
            }).toList();

            setState(() {
              imageData = roomData;
            });

            if (imageData.isNotEmpty) {
              print('Stanze trovate per le date: $imageData');
            } else {
              print('Nessuna stanza disponibile per le date selezionate');
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Le stanze sono disponibili!'),
              ),
            );
          } else if (response.statusCode == 401) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          } else {
            print('Errore: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          print('Errore durante la richiesta: $e');
        }
      } else {
        print('Token non trovato');
      }
    } else {
      // Mostra il dialog se mancano i dati
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Dati mancanti'),
            content: Text(
                'Per effettuare la ricerca, inserire tutti i dati richiesti.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Chiude il dialog
                },
                child: Text('OK', style: TextStyle(color: Colors.deepPurple)),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> fetchRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken != null) {
      final url = Uri.parse('http://localhost:8080/api/room/viewAll');

      try {
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
        //  print('Dati stanze ricevuti: $data');

          List<Map<String, dynamic>> roomData = data.map((room) {
            return {
              'image': 'assets/images/${room['imageName']}',
              'info': room['descrizione'],
              'nome': room['nome'], // Assicurati che il nome venga incluso
              'prezzo': room['prezzo'],
              'tipo': room['tipo'],
              'persone': room['persone'],
              'id': room['id'],
            };
          }).toList();
          // Salva i dati nel SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'roomData', json.encode(roomData)); // Salva come JSON
          setState(() {
            imageData = roomData; // Aggiorna imageData
          });
        } else if (response.statusCode == 401) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
        } else {
          print('Errore: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Errore durante la richiesta: $e');
      }
    } else {
      print('Token non trovato');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchRooms(); // Carica i dati delle stanze
    _startPolling();
  }

  void _startPolling() {
    // Timer per eseguire il polling ogni _pollingInterval secondi
    _timer = Timer.periodic(Duration(seconds: _pollingInterval), (timer) {
      fetchData(); // Carica di nuovo i dati
      fetchRooms(); // Ricarica i dati delle stanze
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Annulla il timer quando il widget viene distrutto
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutte le stanze'),
        backgroundColor: const Color.fromARGB(255, 137, 86, 224),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ),
      body: Consumer<UserProvider>(builder: (context, userProvider, child) {
        if (userProvider.user == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final user = userProvider.user!;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saluto personalizzato
                Text(
                  'BENTORNATO ${user.nome.toUpperCase()} ${user.cognome.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 20),

                // Form di ricerca
                Text(
                  'Cerca Stanze',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 10),
                // Prezzo massimo
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Prezzo massimo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                SizedBox(height: 10),
                // Tipo di stanza
                TextField(
                  controller: _typeController,
                  decoration: InputDecoration(
                    labelText: 'Tipo di stanza',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(Icons.bed),
                  ),
                ),
                SizedBox(height: 10),
                // Numero di persone
                TextField(
                  controller: _peopleController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Numero di persone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 20),

                GestureDetector(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        // Formatta la data selezionata nel formato YYYY-MM-DD
                        _startDateController2.text =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _startDateController2,
                      decoration: InputDecoration(
                        labelText: 'Data di inizio',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Data di fine pernottamento
                GestureDetector(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        // Formatta la data selezionata nel formato YYYY-MM-DD
                        _endDateController2.text =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _endDateController2,
                      decoration: InputDecoration(
                        labelText: 'Data di fine',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Row per i pulsanti di ricerca (Cerca, Cancella, Visualizza tutte le stanze)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Pulsante "Cerca"
                    ElevatedButton(
                      onPressed: searchRooms,
                      child: Text('Cerca'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Pulsante "Cancella"
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Resetta tutti i controller
                          _priceController.clear();
                          _typeController.clear();
                          _peopleController.clear();
                          _startDateController2.clear();
                          _endDateController2.clear();
                          // Reset imageData se necessario
                          // imageData.clear();
                        });
                      },
                      child: Text('Cancella'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Pulsante "Visualizza tutte le stanze"
                    ElevatedButton(
                      onPressed: fetchRooms,
                      child: Text('Visualizza tutte le stanze'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        textStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Mostra le stanze usando imageData
                ...imageData.map((data) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                data['image']!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['info']!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Nome: ${data['nome']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Tipo: ${data['tipo']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Prezzo: €${data['prezzo']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Logica per aprire il dialog di inserimento
                                setState(() {
                                  _roomTypeController.text = data['tipo'];
                                });
                                _showBookingDialog(data);
                              },
                              child: Text('Prenotazione gruppi'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () async {
                                final roomId = data['id'];
                                if (roomId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RoomPage(roomId: roomId),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('ID stanza non valido')),
                                  );
                                }
                              },
                              child: Text('Dettagli'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Prenotazioni',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Impostazioni',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookingRecap()),
                );
              },
              child: Icon(Icons.event),
              backgroundColor: Colors.deepPurple,
            )
          : _selectedIndex == 1
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfilePage()),
                    );
                    setState(() {});
                  },
                  child: Icon(Icons.edit),
                  backgroundColor: Colors.deepPurple,
                )
              : null,
    );
  }
}
