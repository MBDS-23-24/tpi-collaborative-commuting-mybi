


import 'package:tpi_mybi/model/User.dart';

enum DataManagerUpdateType {
  userCreateSuccess,
  userCreateError,
  userLoginSuccess,
  userLoginError
  // Ajoutez d'autres types de mises à jour ici
}

class DataManager {
  static DataManager? _instance;
  DataManager._privateConstructor();

  static DataManager get instance {
    // Retourne l'instance existante ou en crée une nouvelle si nécessaire
    _instance ??= DataManager._privateConstructor();
    return _instance!;
  }

  late UserModel userModel;
  late String token;

  // Méthodes pour manipuler les données
  void setUser(UserModel userModel) {
    this.userModel = userModel;
  }

  UserModel getUser(){
    return userModel;
  }

  void setToken(String token) {
    this.token = token;
  }

  String getToken(){
    return token;
  }

  final List<void Function(DataManagerUpdateType)> _listeners = [];

  // Méthode pour ajouter un listener
  void addListener(void Function(DataManagerUpdateType) listener) {
    _listeners.add(listener);
  }

  // Méthode pour retirer un listener
  void removeListener(void Function(DataManagerUpdateType) listener) {
    _listeners.remove(listener);
  }

  responseCreateUser(bool hasError){
    for (var listener in _listeners) {
      if (!hasError){

        listener(DataManagerUpdateType.userCreateSuccess);
      }
      else {
        listener(DataManagerUpdateType.userCreateError);
      }
    }
  }

  responseLogin(bool hasError){
    for (var listener in _listeners) {
      if (!hasError){
        listener(DataManagerUpdateType.userLoginSuccess);
      }
      else {
        listener(DataManagerUpdateType.userLoginError);
      }
    }
  }

}