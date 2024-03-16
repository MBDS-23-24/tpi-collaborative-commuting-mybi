import 'package:http/http.dart' as http;
import 'package:tpi_mybi/Data/DataManager.dart';
import 'package:tpi_mybi/model/User.dart';
import 'dart:convert';

import 'package:tpi_mybi/model/login.dart';
import 'package:tpi_mybi/ui/views/Chat/LatestMessageModel.dart';

import '../model/AccessToken.dart';
import '../model/Rating.dart';
import '../ui/views/Chat/Meesage.dart'; // Pour utiliser json.encode

class DataLoader {
  static DataLoader? _instance;

  DataLoader._privateConstructor();

  static DataLoader get instance {
    // Retourne l'instance existante ou en crée une nouvelle si nécessaire
    _instance ??= DataLoader._privateConstructor();
    return _instance!;
  }

  String urlPathHosted = "https://lalabi.azurewebsites.net/";
  String urlPathLocal = "http://localhost:3000/";

  Future<void> getUsers(String token) async {
    var manager = DataManager.instance;
    var token2 = DataManager.instance.token;
    var url = Uri.parse('${urlPathHosted}api/users');
   // var url = Uri.parse('http://localhost:3000/api/users');
    try {
      var headers = {
        'Authorization': 'Bearer $token2' // Remplacez VOTRE_TOKEN_ICI par votre token réel
        //'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjksImlhdCI6MTcwNzgyOTExMCwiZXhwIjoxNzA3ODMwOTEwfQ.rb0dYGfC4YJfqueWcO7ADW7woGkbTINxTOOm9xKJ3CA'
      };
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        // Si la requête a réussi (statut 200), vous pouvez traiter les données de réponse ici
       //var jsonResponse = json.decode(response.body);
        List<dynamic> userJson = json.decode(response.body);
        List<UserModel> users = userJson.map((json) => UserModel.fromJson(json)).toList();
        manager.setUsers(users);
        manager.responseGetUsers(false);
        print('Réponse de l\'API: ${response.body}');
      } else {
        // En cas d'échec de la requête, vous pouvez afficher un message d'erreur ou effectuer d'autres actions
        print('Échec de la requête: ${response.statusCode}');
        manager.responseGetUsers(false);
      }
    } catch (e) {
      // En cas d'erreur lors de la connexion à l'API, vous pouvez afficher un message d'erreur
      print('Erreur de connexion: $e');
      manager.responseGetUsers(false);
    }
  }

  Future<void> createUser(UserModel user) async {
    var manager = DataManager.instance;
    var url = Uri.parse('${urlPathHosted}api/users');

   // var url = Uri.parse('http://localhost:3000/api/users');
    // Convertir l'objet UserModel en JSON
    var userJson = user.toJson(); // Assurez-vous que vous avez une méthode toJson dans votre classe UserModel

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Spécifier le type de contenu comme JSON
        },
        body: json.encode(userJson), // Encoder la map en string JSON
      );

      if (response.statusCode == 201) {
        // Si la requête a réussi (statut 200), vous pouvez traiter les données de
        //
        // réponse ici
        manager.responseCreateUser(false);
        print('Réponse de l\'API: ${response.body}');
      } else {
        manager.responseCreateUser(true);
        // En cas d'échec de la requête, vous pouvez afficher un message d'erreur ou effectuer d'autres actions
        print('Échec de la requête: ${response.statusCode}');
      }
    } catch (e) {
      // En cas d'erreur lors de la connexion à l'API, vous pouvez afficher un message d'erreur
      print('Erreur de connexion: $e');
    }
  }

  Future<void> login(LoginModel login) async {
    var manager = DataManager.instance;
    var url = Uri.parse('${urlPathHosted}login');
   // var url = Uri.parse('http://localhost:3000/login');
    // Convertir l'objet UserModel en JSON
    var userJson = login.toJson(); // Assurez-vous que vous avez une méthode toJson dans votre classe UserModel

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Spécifier le type de contenu comme JSON
        },
        body: json.encode(userJson), // Encoder la map en string JSON
      );

      if (response.statusCode == 200) {
        // Si la requête a réussi (statut 200), vous pouvez traiter les données de
        //
        // réponse ici
        print('Réponse de l\'API: ${response.body}');
        var jsonResponse = json.decode(response.body);
        var token = AccessToken.fromJson(jsonResponse);
        manager.setUser(token.userModel);
        manager.setToken(token.accessToken);
        manager.responseLogin(false);
        print('Réponse de l\'API: ${response.body}');
      } else {
        manager.responseLogin(true);
        // En cas d'échec de la requête, vous pouvez afficher un message d'erreur ou effectuer d'autres actions
        print('Échec de la requête: ${response.statusCode}');
      }
    } catch (e) {
      // En cas d'erreur lors de la connexion à l'API, vous pouvez afficher un message d'erreur
      print('Erreur de connexion: $e');
    }
  }

  Future<void> postMessage(String message, int? sourceId, int? targetId) async{

    var url = Uri.parse('${urlPathHosted}api/messages/');
    var messageSended = new MessageModel(0, targetId, sourceId, message, DateTime.now());
    var messageJson = messageSended.toJson();

    if (DataManager.instance.token == null) {
      print('Token non défini');
      return;
    }

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${DataManager.instance.token}', // Remplacez VOTRE_TOKEN_ICI par votre token réel
        },
        body: json.encode(messageJson), // Encoder la map en string JSON
      );

      if (response.statusCode == 201) {
        // Si la requête a réussi (statut 200), vous pouvez traiter les données de
        //
        // réponse ici
        print('Réponse de l\'API: ${response.body}');
      } else {
        // En cas d'échec de la requête, vous pouvez afficher un message d'erreur ou effectuer d'autres actions
        print('Échec de la requête: ${response.statusCode}');
      }
    } catch (e) {
      // En cas d'erreur lors de la connexion à l'API, vous pouvez afficher un message d'erreur
      print('Erreur de connexion: $e');
    }

  }

Future<void> getMessages(int? sourceId, int? targetId) async {
    var manager = DataManager.instance;
    var url = Uri.parse('${urlPathHosted}api/messages/messagesBetween/$sourceId/$targetId');
    //var url = Uri.parse('http://localhost:3000/api/messages/$sourceId/$targetId');
   // var url = Uri.parse('https://integrationlalabi.azurewebsites.net/api/messages/messagesBetween/7/5');

    try {
      var headers = {
        'Authorization': 'Bearer ${DataManager.instance.token}' // Remplacez VOTRE_TOKEN_ICI par votre token réel
      };
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        // Si la requête a réussi (statut 200), vous pouvez traiter les données de réponse ici
        var jsonResponse = json.decode(response.body);
        List<dynamic> messageJson = json.decode(response.body);
        List<MessageModel> messages = messageJson.map((json) => MessageModel.fromJson(json)).toList();
        manager.setMessages(messages);
        //manager.responseGetMessages(false);
        print('Réponse de l\'API: ${response.body}');
      } else {
        // En cas d'échec de la requête, vous pouvez afficher un message d'erreur ou effectuer d'autres actions
        print('Échec de la requête: ${response.statusCode}');
       // manager.responseGetMessages(false);
      }
    } catch (e) {
      // En cas d'erreur lors de la connexion à l'API, vous pouvez afficher un message d'erreur
      print('Erreur de connexion: $e');
     // manager.responseGetMessages(false);
    }
  }

  Future<void> getLatestMessages(int? idUser) async {
    var manager = DataManager.instance;
    var url = Uri.parse('${urlPathHosted}api/messages/getLatestMessages/$idUser');
    //var url = Uri.parse('http://localhost:3000/api/messages/latestMessages/$idUser');
    try {
      var headers = {
        'Authorization': 'Bearer ${DataManager.instance.token}' // Remplacez VOTRE_TOKEN_ICI par votre token réel
      };
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        // Si la requête a réussi (statut 200), vous pouvez traiter les données de réponse ici
        var jsonResponse = json.decode(response.body);
        List<dynamic> messageJson = json.decode(response.body);
        List<LatestMessageModel> messages = messageJson.map((json) => LatestMessageModel.fromJson(json)).toList();
        manager.setLatestMessages(messages);
        manager.responseGetLatestMessages(false);
        print('Réponse de l\'API: ${response.body}');
      } else {
        // En cas d'échec de la requête, vous pouvez afficher un message d'erreur ou effectuer d'autres actions
        print('Échec de la requête: ${response.statusCode}');
        manager.responseGetLatestMessages(true);
      }
    } catch (e) {
      // En cas d'erreur lors de la connexion à l'API, vous pouvez afficher un message d'erreur
      print('Erreur de connexion: $e');
      manager.responseGetLatestMessages(true);
    }
  }

  Future<void> rateUser(int? idUser, double rating, String? content) async {
    var manager = DataManager.instance;
   // var url = Uri.parse('https://integrationlalabi.azurewebsites.net/api/avis/');
    var url = Uri.parse('http://localhost:3000/api/avis/');

    var rateSended = RatingModel(0,DataManager.instance.getUser().userID, idUser, content , rating.toInt());
    var rateJson = rateSended.toJson();
    
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${DataManager.instance.token}' // Remplacez VOTRE_TOKEN_ICI par votre token réel
      };
    
      var response = await http.post(url, headers: headers, body: jsonEncode(rateJson));
      if (response.statusCode == 201) {
        // Si la requête a réussi (statut 200), vous pouvez traiter les données de réponse ici

        print('Réponse de l\'API: ${response.body}');
      } else {
        // En cas d'échec de la requête, vous pouvez afficher un message d'erreur ou effectuer d'autres actions
        print('Échec de la requête: ${response.statusCode}');
      }
    } catch (e) {
      // En cas d'erreur lors de la connexion à l'API, vous pouvez afficher un message d'erreur
      print('Erreur de connexion: $e');
    }
  }

  Future<void> deleteUser(int userID) async {
  var manager = DataManager.instance;
  var url = Uri.parse('https://integrationlalabi.azurewebsites.net/api/users/$userID');

  try {
    var response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${manager.getToken()}',
      },
    );

    if (response.statusCode == 204) {
      // Suppression réussie
      // Vous pouvez également effectuer d'autres actions ici
    } else {
      // La suppression a échoué, affichez un message d'erreur ou effectuez d'autres actions nécessaires
      print('Échec de la suppression: ${response.statusCode}');
    }
  } catch (e) {
    // En cas d'erreur lors de la connexion à l'API, vous pouvez afficher un message d'erreur
    print('Erreur de connexion lors de la suppression du compte: $e');
  }
}

}