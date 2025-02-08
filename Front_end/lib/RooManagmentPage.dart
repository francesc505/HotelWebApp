import 'package:flutter/material.dart';
import 'package:flutter_application_1/EditRoomPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Per la decodifica JSON
import 'package:shared_preferences/shared_preferences.dart';

class RoomManagementPage extends StatefulWidget {
  @override
  _RoomManagementPageState createState() => _RoomManagementPageState();
}

class _RoomManagementPageState extends State<RoomManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _tipoController = TextEditingController();
  final _descrizioneController = TextEditingController();
  final _prezzoController = TextEditingController();
  final _personeController = TextEditingController();
  final _imageNameController = TextEditingController();
  
  Future<List<dynamic>> fetchRooms() async {
    // Recupero del token dalle SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    // Chiamata GET all'API
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/room/viewAll'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // Verifica dello stato della risposta
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Errore nel caricamento delle stanze');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> _handleAddRoom(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final roomData = {
        "nome": _nomeController.text,
        "tipo": _tipoController.text,
        "descrizione": _descrizioneController.text,
        "prezzo": double.parse(_prezzoController.text),
        "persone": int.parse(_personeController.text),
        "imageName": _imageNameController.text,
        "bookingList": null,
      };

      final response = await http.post(
        Uri.parse('http://localhost:8080/api/room/addRoom'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(roomData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Stanza aggiunta con successo!'),
        ));
        Navigator.pop(context); // Torna indietro
        // await fetchRooms(); // Ricarica le stanze
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Errore nell\'aggiungere la stanza: ${response.body}'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestione Camere'),
        backgroundColor: Colors.blue.shade700,
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Pulsante Aggiungi fuori dalla lista delle stanze
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Naviga alla pagina di aggiunta stanza
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Aggiungi una nuova stanza'),
                        content: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: _nomeController,
                                decoration: InputDecoration(labelText: 'Nome'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Il nome è obbligatorio';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _tipoController,
                                decoration: InputDecoration(labelText: 'Tipo'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Il tipo è obbligatorio';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _descrizioneController,
                                decoration:
                                    InputDecoration(labelText: 'Descrizione'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'La descrizione è obbligatoria';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _prezzoController,
                                decoration:
                                    InputDecoration(labelText: 'Prezzo'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Il prezzo è obbligatorio';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _personeController,
                                decoration: InputDecoration(
                                    labelText: 'Numero di persone'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Il numero di persone è obbligatorio';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _imageNameController,
                                decoration:
                                    InputDecoration(labelText: 'Nome immagine'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Il nome immagine è obbligatorio';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Chiude il dialog
                            },
                            child: Text('Annulla'),
                          ),
                          TextButton(
                            onPressed: () {
                              _handleAddRoom(context);
                            },
                            child: Text('Aggiungi'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  iconColor: Colors.blue[100], // Colore di sfondo del pulsante
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Aggiungi Stanza',
                  style: TextStyle(color: Colors.blue), // Colore del testo
                ),
              ),
            ),
            SizedBox(height: 16),
            // Lista delle stanze
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: fetchRooms(),
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
                        'Nessuna stanza disponibile',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  } else {
                    final rooms = snapshot.data!;
                    return ListView.builder(
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Immagine della stanza
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    'assets/images/${room['imageName']}',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.broken_image,
                                          size: 100);
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                // Dettagli della stanza
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        room['nome'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '${room['tipo']} - €${room['prezzo']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '${room['persone']} persone',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        room['descrizione'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                // Bottone Modifica e Icona Rimuovi
                                Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Azione per modificare la stanza
                                        _handleEditRoom(context, room);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        iconColor: Colors
                                            .blue[100], // Colore di sfondo
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        'Modifica',
                                        style: TextStyle(
                                            color: Colors
                                                .blue), // Colore del testo
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    IconButton(
                                      onPressed: () {
                                        // Azione per rimuovere la stanza
                                        _handleRemoveRoom(context, room['id']);
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.blue, // Colore dell'icona
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleEditRoom(BuildContext context, dynamic room) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRoomPage(room: room),
      ),
    );     
  }

  Future<void> _handleRemoveRoom(BuildContext context, int roomId) async {
    // Recupero del token dalle SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    // Chiamata DELETE all'API per rimuovere la stanza
    final response = await http.delete(
      Uri.parse('http://localhost:8080/api/room/$roomId/delete'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Stanza con ID $roomId eliminata con successo!'),
      ));
      // Ricarica la lista delle stanze
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Errore nell\'eliminazione della stanza: ${response.body}'),
      ));
    }
  }
}
