import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditRoomPage extends StatefulWidget {
  final dynamic room;

  EditRoomPage({required this.room});

  @override
  _EditRoomPageState createState() => _EditRoomPageState();
}

class _EditRoomPageState extends State<EditRoomPage> {
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _peopleController;
  late TextEditingController _imageNameController;

  @override
  void initState() {
    super.initState();
    print("Dati stanza ricevuti: ${widget.room}");
    _nameController = TextEditingController(text: widget.room['nome'] ?? '');
    _typeController = TextEditingController(text: widget.room['tipo'] ?? '');
    _descriptionController = TextEditingController(text: widget.room['descrizione'] ?? '');
    _priceController = TextEditingController(text: widget.room['prezzo']?.toString() ?? '0');
    _peopleController = TextEditingController(text: widget.room['persone']?.toString() ?? '0');
    _imageNameController = TextEditingController(text: widget.room['imageName'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _peopleController.dispose();
    _imageNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        final fileName = result.files.single.name;
        if (fileName.isNotEmpty) {
          setState(() {
            _imageNameController.text = fileName;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File selezionato non valido')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nessun file selezionato')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante la selezione del file: $e')),
      );
    }
  }

  Future<void> _updateRoom() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token non trovato. Effettua il login.')),
      );
      return;
    }

    final url = Uri.parse('http://localhost:8080/api/room/edit/room');
    final body = json.encode({
      "nome": _nameController.text.isNotEmpty ? _nameController.text : "Default Name",
      "tipo": _typeController.text.isNotEmpty ? _typeController.text : "Default Type",
      "descrizione": _descriptionController.text.isNotEmpty ? _descriptionController.text : "",
      "prezzo": int.tryParse(_priceController.text) ?? 0,
      "persone": int.tryParse(_peopleController.text) ?? 0,
      "imageName": _imageNameController.text,
      "bookingList": null
    });

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Modifiche salvate con successo!')),
        );
        Navigator.pop(context, true); // Ritorna alla pagina precedente con successo
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante il salvataggio delle modifiche')),
        );
        print("Errore HTTP: ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante la connessione al server: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifica ${widget.room['nome'] ?? 'Stanza'}'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(labelText: 'Tipo'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descrizione'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Prezzo'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _peopleController,
              decoration: InputDecoration(labelText: 'Numero di persone'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _imageNameController,
              decoration: InputDecoration(
                labelText: 'Percorso immagine',
                suffixIcon: IconButton(
                  icon: Icon(Icons.upload_file),
                  onPressed: _pickImage,
                ),
              ),
              readOnly: true,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Apporta modifiche',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
