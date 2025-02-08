import 'package:flutter/material.dart';
import 'package:flutter_application_1/HandleCustomer.dart';
import 'package:flutter_application_1/RooManagmentPage.dart';
import 'package:flutter_application_1/ViewBookingsPage.dart';
import 'package:flutter_application_1/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstManagerPage extends StatefulWidget {
  final bool flag;

  FirstManagerPage({required this.flag});

  @override
  _FirstManagerPageState createState() => _FirstManagerPageState();
}

class _FirstManagerPageState extends State<FirstManagerPage> {
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Utente';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Benvenuto, $username'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.blue.shade200],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/hotel.webp',
                  fit: BoxFit.cover,
                  height: double.infinity,
                ),
              ),
            ),
            SizedBox(width: 20), // Spaziatura tra immagine e pulsanti

            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Funzionalità Manager:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30), // Aggiungi più spazio tra il testo e i bottoni

                  // Bottone per Gestire i Dipendenti
                  _buildButton(
                    context,
                    text: 'Gestisci Dipendenti',
                    onPressed: widget.flag
                        ? () async {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Handlecustomer(),
                              ),
                            );
                          }
                        : null, // Se il flag è false, disabilita il bottone
                  ),
                  SizedBox(height: 20), // Distanza tra i bottoni

                  // Bottone per Visualizzare le Prenotazioni
                  _buildButton(
                    context,
                    text: 'Visualizza Prenotazioni',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => ViewBookingsPage()),
                      );
                    },
                  ),
                  SizedBox(height: 20), // Distanza tra i bottoni

                  // Bottone per la Gestione delle Camere
                  _buildButton(
                    context,
                    text: 'Gestione Camere',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => RoomManagementPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Metodo per creare pulsanti stilizzati con effetto di ombra
  Widget _buildButton(BuildContext context,
      {required String text, required VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: onPressed == null ? Colors.blue[900] : Colors.white, // Colore grigio se il bottone è disabilitato
        shadowColor: Colors.black,
        elevation: 5, // Aggiungi un'ombra per un effetto visivo
      ),
    );
  }
}
