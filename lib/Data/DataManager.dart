


import 'package:tpi_mybi/model/User.dart';

enum DataManagerUpdateType {
  userCreateSuccess,
  userCreateError,
  userLoginSuccess,
  userLoginError,
  getUsersSuccess,
  getUsersError,
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
   List<UserModel> users = [];

  // Méthodes pour manipuler les données
  void setUser(UserModel userModel) {
  //  this.userModel = UserModel(uid: 0, email: "test@gmail.com", firstName: "test", lastName: "test", password: "test");
    this.userModel = userModel;
  }

  UserModel getUser(){
   // this.userModel = UserModel(uid: 0, email: "test@gmail.com", firstName: "test", lastName: "test", password: "test");
    return userModel;
  }

  void setToken(String token) {
    this.token = token;
  }

  String getToken(){
   // token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEwLCJpYXQiOjE3MDgyNzI3NjMsImV4cCI6MTcwODI3NDU2M30.2edEdLxqDuucK6mZMTpdr1bCB_qhEYResIfec12WRuE";
    return token;
  }

  void setUsers(List<UserModel> users) {
    this.users = users;
  }

  void addUser(UserModel user) {
    users.add(user);
  }

  List<UserModel> getUsers() {
    return users;
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

  responseGetUsers(bool hasError){
    for (var listener in _listeners) {
      if (!hasError){
        listener(DataManagerUpdateType.getUsersSuccess);
      }
      else {
        listener(DataManagerUpdateType.getUsersError);
      }
    }
  }

}