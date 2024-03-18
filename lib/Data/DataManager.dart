import 'package:tpi_mybi/Data/SaveDataManager.dart';
import 'package:tpi_mybi/model/User.dart';
import 'package:tpi_mybi/ui/views/Chat/Meesage.dart';

import '../ui/views/Chat/LatestMessageModel.dart';

enum DataManagerUpdateType {
  userCreateSuccess,
  userCreateError,
  userLoginSuccess,
  userLoginError,
  getUsersSuccess,
  getUsersError,
  getMessagesSuccess,
  getLatestMessagesSuccess,
  getLatestMessagesError

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
   String token = "";
   List<UserModel> users = [];
   List<MessageModel> messages = [];
   List<LatestMessageModel> latestMessages = [];

  // Méthodes pour manipuler les données
  void setUser(UserModel userModel) {
  //  this.userModel = UserModel(uid: 0, email: "test@gmail.com", firstName: "test", lastName: "test", password: "test");
    this.userModel = userModel;
  }


  UserModel getUser(){
   // this.userModel = UserModel(uid: 0, email: "test@gmail.com", firstName: "test", lastName: "test", password: "test");
    return userModel;
  }

  UserModel getUserById(int? id){
    return users.firstWhere((element) => element.userID == id);
  }

  void setToken(String token) {
    this.token = token;
    this.userModel.setToken(token);
    SaveDataManager().saveToken(token);
    SaveDataManager().saveUser(userModel);
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

  void logout() {
  userModel = UserModel(); // Réinitialisez l'utilisateur
  token = ""; // Effacez le jeton
  SaveDataManager().removeToken(); // Supprimez le token des préférences partagées
  SaveDataManager().removeUser(); // Supprimez les données utilisateur des préférences partagées
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

  setMessages(List<MessageModel> messages) {
    this.messages = messages;
    for (var listener in _listeners) {
      listener(DataManagerUpdateType.getMessagesSuccess);
    }
  }

  List<MessageModel> getMessages() {
    return messages;
  }

  List<LatestMessageModel> getLatestMessages() {
    return latestMessages;
  }

  setLatestMessages(List<LatestMessageModel> latestMessages) {
    this.latestMessages = latestMessages;
  }

  responseGetLatestMessages(bool hasError){
    for (var listener in _listeners) {
      if (!hasError){
        listener(DataManagerUpdateType.getLatestMessagesSuccess);
      }
      else {
        listener(DataManagerUpdateType.getLatestMessagesError);
      }
    }
  }

}