 import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/Provider/UserProvider.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _cognomeController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();

    // Otteniamo i dati dell'utente dal provider e inizializziamo i controller
    final user = Provider.of<UserProvider>(context, listen: false).user;

    // Assicurati che 'user' non sia null
    if (user != null) {
      _nomeController = TextEditingController(text: user.nome);
      _cognomeController = TextEditingController(text: user.cognome);
      _emailController = TextEditingController(text: user.email);
      _usernameController = TextEditingController(text: user.username);
    } else {
      // Se l'utente non è disponibile, crea controller vuoti
      _nomeController = TextEditingController();
      _cognomeController = TextEditingController();
      _emailController = TextEditingController();
      _usernameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Recupera l'ID e altri dati salvati in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(
          'user_id'); // Supponiamo che l'ID utente sia salvato con questa chiave
      final token = prefs.getString('access_token');

      print(userId);
      print(token);

      if (userId == null || token == null) {
        // Se mancano i dati, mostra un messaggio o gestisci l'errore
        print("ID utente o token non trovati. Utente non autenticato.");
        return;
      }

      // Costruisci l'oggetto con i dati aggiornati
      final updatedUser = {
        "id": userId,
        "username": _usernameController.text,
        "cognome": _cognomeController.text,
        "nome": _nomeController.text,
        "email": _emailController.text,
      };

      // Aggiorna il backend
      await _updateUserProfile(updatedUser, token);

      // Ritorna alla pagina precedente
      Navigator.pop(context);
    }
  }

  Future<void> _updateUserProfile(
      Map<String, dynamic> updatedUser, String token) async {
    const url = 'ttp://localhost:8080/api/user/change';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updatedUser),
      );

      if (response.statusCode == 200) {
        // Se la risposta è OK
        print('Profilo salvato con successo');
        // Mostra il messaggio di successo con un SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Modifiche salvate con successo'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Gestisci errori di risposta
        print('Errore nel salvataggio del profilo: ${response.statusCode}');
        print('Messaggio: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel salvataggio del profilo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Errore nella chiamata HTTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nella connessione al server'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    // Se l'utente non è ancora disponibile, mostra un caricamento o un messaggio
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Modifica Profilo'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Modifica Profilo'),
        backgroundColor: const Color.fromARGB(255, 137, 86, 224),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo per il nome
                _buildTextField(_nomeController, 'Nome'),
                SizedBox(height: 20),

                // Campo per il cognome
                _buildTextField(_cognomeController, 'Cognome'),
                SizedBox(height: 20),

                // Campo per l'email
                _buildTextField(_emailController, 'Email',
                    keyboardType: TextInputType.emailAddress),
                SizedBox(height: 20),

                // Campo per lo username
                _buildTextField(_usernameController, 'Username'),
                SizedBox(height: 20),

                // Pulsante per salvare il profilo
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: Icon(Icons.save, size: 20),
                    label: Text('Salva Modifiche'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.deepPurple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Inserisci il $label';
        }
        return null;
      },
    );
  }
} 