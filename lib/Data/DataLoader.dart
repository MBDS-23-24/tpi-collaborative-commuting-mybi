


import 'package:http/http.dart' as http;
import 'package:tpi_mybi/Data/DataManager.dart';
import 'package:tpi_mybi/model/User.dart';
import 'dart:convert';

import 'package:tpi_mybi/model/login.dart';

import '../model/AccessToken.dart'; // Pour utiliser json.encode

class DataLoader {
  static DataLoader? _instance;

  DataLoader._privateConstructor();

  static DataLoader get instance {
    // Retourne l'instance existante ou en crée une nouvelle si nécessaire
    _instance ??= DataLoader._privateConstructor();
    return _instance!;
  }

  String urlPathHosted = "https://integrationlalabi.azurewebsites.net/";
  String urlPathLocal = "http://localhost:3000/";

  Future<void> getUsers(String token) async {
    var manager = DataManager.instance;
    var url = Uri.parse('https://integrationlalabi.azurewebsites.net/api/users');
   // var url = Uri.parse('http://localhost:3000/api/users');
    try {
      var headers = {
        'Authorization': 'Bearer $token' // Remplacez VOTRE_TOKEN_ICI par votre token réel
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
   // var url = Uri.parse('https://integrationlalabi.azurewebsites.net/api/users');

    var url = Uri.parse('http://localhost:3000/api/users');
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
    //var url = Uri.parse('https://integrationlalabi.azurewebsites.net/login');
    var url = Uri.parse('http://localhost:3000/login');
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
        manager.setToken(token.accessToken);
        manager.setUser(token.userModel);
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

}