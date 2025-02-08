import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/UserDTO.dart';


class UserProvider with ChangeNotifier {
  UserDTO? _user;

  UserDTO? get user => _user;

  // Funzione per aggiornare lo stato dell'utente
  void updateUser(UserDTO user) {
    _user = user;
    notifyListeners(); // Notifica i widget che lo stato è cambiato
    print('User updated: ${_user?.username}, ${_user?.email}');
  }
}