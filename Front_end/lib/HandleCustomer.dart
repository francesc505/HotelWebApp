import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Handlecustomer extends StatefulWidget {
  @override
  _HandlecustomerState createState() => _HandlecustomerState();
}

class _HandlecustomerState extends State<Handlecustomer> {
  // Funzione per recuperare i manager
  Future<List<dynamic>> fetchManagers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('http://localhost:8080/api/user/viewAll/Managers'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Errore nel caricamento dei manager');
    }
  }

  // Funzione per eliminare un manager
  Future<void> deleteManager(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.delete(
      Uri.parse('http://localhost:8080/api/user/delete/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Manager eliminato con successo!')),
      );
      setState(() {
        // Ricarica la lista dei manager dopo la cancellazione
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante l\'eliminazione del manager')),
      );
    }
  }

//RIMOZIONE DEL RUOLO
  Future<void> removeRole(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token non trovato!')),
      );
      return;
    }

    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleziona Ruolo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('ADMIN'),
                onTap: () {
                  Navigator.of(context).pop('ADMIN');
                },
              ),
              ListTile(
                title: Text('MANAGER'),
                onTap: () {
                  Navigator.of(context).pop('MANAGER');
                },
              ),
            ],
          ),
          actions: <Widget>[
            // Pulsante Chiudi che chiude il dialog
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Chiude il dialog senza selezionare nessun ruolo
              },
              child: Text('Chiudi'),
            ),
          ],
        );
      },
    ).then((role) {
      // Se l'utente ha selezionato un ruolo, eseguiamo la chiamata API
      if (role != null) {
        final url =
            Uri.parse('http://localhost:8080/api/user/$id/removeRole/$role');
        http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
          },
        ).then((response) {
          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ruolo $role rimosso con successo!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Errore nell\'assegnare il ruolo')),
            );
          }
        }).catchError((e) {
          print('Errore nella chiamata API: $e');
        });
      }
    });
  }

//VISUALIZZAZIONE DEI RUOLI
  Future<void> viewRoles(int id) async {
    try {
      // Recupera il token dalle SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        print('Token non trovato');
        return;
      }

      // Costruisci l'URL con l'ID del manager
      final url =
          Uri.parse('http://localhost:8080/api/user/view/manager/roles/$id');

      // Fai la richiesta GET
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // Controlla lo stato della risposta
      if (response.statusCode == 200) {
        // Decodifica la risposta JSON
        List<dynamic> roles = json.decode(response.body);

        // Estrai solo i roleName e visualizzali
        List<String> roleNames =
            roles.map((role) => role['roleName'].toString()).toList();

        // Stampa o usa il risultato come preferisci
        print('Ruoli: $roleNames');

        // Mostra il dialog con i ruoli
        _showRoleNamesDialog(roleNames, context);

        // Puoi usare roleNames per visualizzarli nel tuo UI, per esempio:
        // showDialog per mostrare i ruoli, o semplicemente aggiorna lo stato del widget
      } else {
        print('Errore nella chiamata API: ${response.statusCode}');
      }
    } catch (e) {
      print('Errore: $e');
    }
  }

  // Funzione per visualizzare i ruoli in un Dialog
  void _showRoleNamesDialog(List<String> roleNames, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ruoli dell'utente"),
          content: SingleChildScrollView(
            child: ListBody(
              children: roleNames.map((roleName) => Text(roleName)).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Chiudi'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

//AGGIUNTA DEL RUOLO
  Future<void> addRole(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token non trovato!')),
      );
      return;
    }

    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleziona Ruolo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('ADMIN'),
                onTap: () {
                  Navigator.of(context).pop('ADMIN');
                },
              ),
              ListTile(
                title: Text('MANAGER'),
                onTap: () {
                  Navigator.of(context).pop('MANAGER');
                },
              ),
            ],
          ),
          actions: <Widget>[
            // Pulsante Chiudi che chiude il dialog
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Chiude il dialog senza selezionare nessun ruolo
              },
              child: Text('Chiudi'),
            ),
          ],
        );
      },
    ).then((role) {
      // Se l'utente ha selezionato un ruolo, eseguiamo la chiamata API
      if (role != null) {
        final url =
            Uri.parse('http://localhost:8080/api/user/$id/assignRole/$role');
        http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
          },
        ).then((response) {
          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ruolo $role rimosso con successo!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Errore nell\'assegnare il ruolo')),
            );
          }
        }).catchError((e) {
          print('Errore nella chiamata API: $e');
        });
      }
    });
  }

/*MODIFICA DEI PARAMETRI UTENTI
  Future<void> modifyManager(int id) async {
    // Implementa la logica per modificare il manager
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestione Dipendenti'),
        backgroundColor: Colors.blue.shade700,
        elevation: 4.0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchManagers(),
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
                'Nessun manager disponibile',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          } else {
            final managers = snapshot.data!;
            return ListView.builder(
              itemCount: managers.length,
              itemBuilder: (context, index) {
                final manager = managers[index];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Username: ${manager['username']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blue.shade700),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Nome: ${manager['nome']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Cognome: ${manager['cognome']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Email: ${manager['email'] ?? "Non disponibile"}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                deleteManager(manager['id']);
                              },
                              child: Text('Elimina'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                textStyle: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            /*ElevatedButton(
                              onPressed: () {
                                modifyManager(manager['id']);
                              },
                              child: Text('Modifica'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                textStyle: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),*/
                            ElevatedButton(
                              onPressed: () {
                                addRole(manager['id']);
                              },
                              child: Text('Aggiungi Ruolo'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                textStyle: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                removeRole(manager['id']);
                              },
                              child: Text('Rimuovi Ruolo'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                textStyle: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                viewRoles(manager['id']);
                              },
                              child: Text('Visualizza Ruoli'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                textStyle: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
    );
  }
}
