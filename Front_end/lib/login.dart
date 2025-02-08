import 'package:flutter/material.dart';
import 'package:flutter_application_1/FirstManagerPage.dart';
import 'package:flutter_application_1/changePasswordPage.dart';
import 'package:flutter_application_1/firstPage.dart';
import 'package:flutter_application_1/registrationPage.dart'; // Import della RegistrationPage
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool flag = true;

  Future<void> login(String username, String password) async {
    final url = Uri.parse('http://localhost:8080/api/login');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      print('Codice di stato: ${response.statusCode}');
      print('Corpo della risposta: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          final accessToken = data['access_token'];
          final refreshToken = data['refresh_token'];

          if (accessToken == null || refreshToken == null) {
            setState(() {
              _errorMessage =
                  'Token di accesso, di refresh o ID utente mancanti.';
            });
            return;
          }

          // Salva accesso e refresh token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', accessToken);
          await prefs.setString('refresh_token', refreshToken);
          await prefs.setString('username', username);

          // Itera su tutti i campi della risposta e salvali nell'SharedPreferences
          data.forEach((key, value) async {
            if (value == null) {
              await prefs.setString(
                  key, ''); // Salva con valore vuoto se il campo è null
            } else {
              await prefs.setString(
                  key, value.toString()); // Salva il valore del campo
            }
          });

          // Log dei dati salvati
          print('Access Token: $accessToken');
          print('Refresh Token: $refreshToken');

          // Decodifica il token JWT
          final decodedToken = _decodeJwt(accessToken);
          print('Decoded Token: $decodedToken');

          final roles = decodedToken['roles'];

          if (roles == null) {
            setState(() {
              _errorMessage = 'Ruoli non trovati nel token.';
            });
            return;
          }

          print('Ruoli dell\'utente: $roles');
          print(roles.toString() + " lista dei ruoli");
          String LRoles = roles.toString();
          print(LRoles);
          prefs.setString(LRoles, LRoles);

          // Naviga in base ai ruoli
          if ((roles.contains('MANAGER')) || roles.contains('ADMIN')) {
            // Mostra una finestra di dialogo per scegliere tra le due pagine
            flag = (roles.contains('ADMIN'));
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Seleziona la pagina'),
                  content: Text('Dove vuoi andare?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        if (!mounted)
                          return; // Assicurati che il widget sia ancora montato
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  FirstManagerPage(flag: true)),
                        );
                      },
                      child: Text('Gestione'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (!mounted)
                          return; // Assicurati che il widget sia ancora montato
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => FirstPage()),
                        );
                      },
                      child: Text('Ambiente Creato'),
                    ),
                  ],
                );
              },
            );
          } else {
            if (!mounted) return; // Assicurati che il widget sia ancora montato
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FirstPage()),
            );
          }
        } catch (e, stackTrace) {
          print('Errore nella decodifica della risposta: $e');
          print('Stack Trace: $stackTrace');
          setState(() {
            _errorMessage = 'Errore nella decodifica della risposta: $e';
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'Credenziali non valide.';
        });
      } else if (response.statusCode == 403) {
        setState(() {
          _errorMessage = 'Accesso negato.';
        });
      } else {
        setState(() {
          _errorMessage = 'Errore durante il login: ${response.body}';
        });
      }
    } catch (e, stackTrace) {
      print('Errore durante la richiesta di login: $e');
      print('Stack Trace: $stackTrace');
      setState(() {
        _errorMessage = 'Errore durante la richiesta di login: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

// Funzione per decodificare il token JWT
  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Token JWT non valido');
    }

    final payload = parts[1];
    final normalizedPayload = _base64UrlDecode(payload);
    final decoded = utf8.decode(normalizedPayload);
    return json.decode(decoded);
  }

// Funzione di decodifica Base64Url
  List<int> _base64UrlDecode(String input) {
    final String normalizedInput =
        input.replaceAll('-', '+').replaceAll('_', '/');
    final padding = '=' * (4 - normalizedInput.length % 4);
    final decoded = base64.decode(normalizedInput + padding);
    return decoded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Impostiamo uno sfondo gradiente per la pagina di login
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.blue.shade200],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    // Username
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: Colors.blue.shade700),
                        prefixIcon:
                            Icon(Icons.person, color: Colors.blue.shade700),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.blue.shade700),
                        prefixIcon:
                            Icon(Icons.lock, color: Colors.blue.shade700),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Error message
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    // Login Button
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () {
                              final username = _usernameController.text;
                              final password = _passwordController.text;
                              login(username, password);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    SizedBox(height: 20),
                    // Registrazione Button
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegistrationPage()),
                        );
                      },
                      child: Text(
                        'Non hai un account? Registrati',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Password dimenticata Button
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangePasswordPage()),
                        );
                      },
                      child: Text(
                        'Password dimenticata?',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
