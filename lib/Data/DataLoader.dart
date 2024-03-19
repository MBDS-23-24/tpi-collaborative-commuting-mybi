import 'package:http/http.dart' as http;
import 'package:tpi_mybi/Data/DataManager.dart';
import 'package:tpi_mybi/model/Trip.dart';
import 'package:tpi_mybi/model/User.dart';
import 'dart:convert';

import 'package:tpi_mybi/model/login.dart';
import 'package:tpi_mybi/ui/views/Chat/LatestMessageModel.dart';

import '../model/AccessToken.dart';
import '../model/Passenger.dart';
import '../model/Rating.dart';
import '../ui/views/Chat/Meesage.dart'; // Pour qutiliser json.encode

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

  Future<UserModel?> getUser(int? id) async {
    var manager = DataManager.instance;
    var token = manager.token; // Utilisation de token depuis DataManager
    var url = Uri.parse('https://lalabi.azurewebsites.net/api/users/$id');

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Si la requête a réussi, décodez le corps de la réponse en un objet UserModel
        Map<String, dynamic> userJson = json.decode(response.body);
        UserModel user = UserModel.fromJson(userJson);

        print('User data retrieved successfully: ${response.body}');
        return user; // Retourne l'objet UserModel
      } else {
        // Gérez le cas où la requête n'est pas réussie
        print('Failed to retrieve user: ${response.statusCode}');
        return null; // Retourne null en cas d'échec
      }
    } catch (e) {
      // Gérez les exceptions liées à la requête
      print('Error fetching user: $e');
      return null; // Retourne null en cas d'exception
    }
  }


  Future<void> createUser(UserModel user) async {
    var manager = DataManager.instance;

  //  var url = Uri.parse('https://lalabi.azurewebsites.net/api/users');


    var url = Uri.parse('${urlPathHosted}api/users');


   // var url = Uri.parse('http://localhost:3000/api/users');
    // Convertir l'objet UserModel en JSON
    var userJson = user.toJson(); // Assurez-vous que vous avez une méthode toJson dans votre classe UserModel
    print(userJson);
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
    //var url = Uri.parse('https://lalabi.azurewebsites.net/api/avis/');
    // var url = Uri.parse('http://localhost:3000/api/avis/');
     var url = Uri.parse('https://lalabi.azurewebsites.net/api/avis/');

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

  var url = Uri.parse('https://lalabi.azurewebsites.net/api/users/$userID');

  //var url = Uri.parse('https://lalabi.azurewebsites.net/api/users/$userID');
 // var url = Uri.parse('http://localhost:3000/api/avis/$userID');


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



///////////////////////////////////////////////////// Planify Trip //////////////////////////////////////////////////

      Future<bool> createVoyage(VoyageModel trip) async {
        //var baseUrl = 'https://lalabi.azurewebsites.net/api/trip';
        //var baseUrl = 'http://localhost:3000/api/trip';
        var baseUrl = 'https://lalabi.azurewebsites.net/api/trip';
        var path = Uri.parse('$baseUrl/createTrip');

        Map<String, dynamic> voyageData = trip.toJson(); // Convert the trip object to JSON
        print (voyageData);
        try {
          var response = await http.post(
            path,
            headers: {'Content-Type': 'application/json',
              'Authorization': 'Bearer ${DataManager.instance.token}' // Remplacez VOTRE_TOKEN_ICI par votre token réel
            },
            body: json.encode(voyageData),
          );
          if (response.statusCode == 201) {
            print('Voyage created successfully');
            return true; // Return true on success
          } else {
            print('Failed to create voyage: ${response.statusCode}');
            print(response.body);
            return false; // Return false on failure
          }
        } catch (e) {
          print('Error creating voyage: $e');
          return false; // Return false on exception
        }
      }

  Future<List<VoyageModel>> getVoyages() async {
//http://localhost:3000/api/trip/getTripDrvier/0
    var baseUrl = 'https://lalabi.azurewebsites.net/api/trip';
    UserModel user = DataManager.instance.getUser();
    int? uid = user.userID;
    //var baseUrl = 'https://lalabi.azurewebsites.net/api/trip'; // Ajustez cette URL à votre API réelle
    var endpoint = user.role == 'CONDUCTEUR' ? '/getTripDrvier/$uid' : '/getTripPassager/$uid';
    var url = Uri.parse(baseUrl + endpoint);

    try {
      var response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${DataManager.instance.token}' // Remplacez VOTRE_TOKEN_ICI par votre token réel
        // Inclure ici le header pour l'authentification si nécessaire
      });
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        print(body);
        List<VoyageModel> voyages = body.map((dynamic item) => VoyageModel.fromJson(item)).toList();
        print(voyages);

        return voyages;
      } else {
        print('Failed to get voyages: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting voyages: $e');
      return [];
    }
  }

/*
  Future<void> updateVoyage(int id, Map<String, dynamic> updatedData) async {

    var url = Uri.parse('https://lalabi.azurewebsites.net/login');

    var path = Uri.parse('$url/updateVoyage/$id');
    try {
      var response = await http.put(
        path,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );
      if (response.statusCode == 200) {
        print('Voyage updated successfully');
      } else {
        print('Failed to update voyage: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating voyage: $e');
    }
  }

  Future<void> deleteVoyage(int id) async {
    var url = Uri.parse('https://lalabi.azurewebsites.net/login');

    var path = Uri.parse('$url/deleteVoyage/$id');
    try {
      var response = await http.delete(path);
      if (response.statusCode == 204) {
        print('Voyage deleted successfully');
      } else {
        print('Failed to delete voyage: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting voyage: $e');
    }
  }

 */

  Future<List<Passenger>?> getPassengersByIdTrip(int? voyageId) async {
    var manager = DataManager.instance;
    var token2 = DataManager.instance.token;
    var baseUrl = 'https://lalabi.azurewebsites.net/api/trip';

    // var baseUrl = 'http://localhost:3000/api/trip/getPassengersByTrip/$voyageId';
      var url = Uri.parse('https://lalabi.azurewebsites.net/api/trip/getPassengersByTrip/$voyageId');
    // var url = Uri.parse('http://localhost:3000/api/users');
    try {
      var headers = {
        'Authorization': 'Bearer $token2' // Remplacez VOTRE_TOKEN_ICI par votre token réel
        //'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjksImlhdCI6MTcwNzgyOTExMCwiZXhwIjoxNzA3ODMwOTEwfQ.rb0dYGfC4YJfqueWcO7ADW7woGkbTINxTOOm9xKJ3CA'
      };
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> paasengerJson = json.decode(response.body);
        List<Passenger> paasangers = paasengerJson.map((json) => Passenger.fromJson(json)).toList();
        print('Réponse de l\'API: ${response.body}');
        return paasangers;
      } else if( response.statusCode == 204){
        return null;
      }
      else {
        // En cas d'échec de la requête, vous pouvez afficher un message d'erreur ou effectuer d'autres actions
        print('Échec de la requête: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // En cas d'erreur lors de la connexion à l'API, vous pouvez afficher un message d'erreur
      print('Erreur de connexion: $e');
      manager.responseGetUsers(false);
    }
  }

  Future<List<VoyageModel>?> getTripsForPassenger(VoyageModel trip) async {
      var manager = DataManager.instance;
      var token = DataManager.instance.token;
      var baseUrl = 'https://lalabi.azurewebsites.net/api/trip/getTripByFilter';

      // Préparez les paramètres de requête basés sur les propriétés du voyage fourni
      var queryParams = {
        'depart': trip.depart,
        'destination': trip.destination,
        'dateDepartSouhaite': trip.timestamp.toIso8601String(), // Formatage de la date pour la requête
      };

      var uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      try {
        var headers = {
          'Authorization': 'Bearer $token', // Utilisez le token d'authentification
        };
        var response = await http.get(uri, headers: headers);

        if (response.statusCode == 200) {
          List<dynamic> tripsJson = json.decode(response.body);
          List<VoyageModel> trips = tripsJson.map((json) => VoyageModel.fromJson(json)).toList();
          print('Réponse de l\'API: ${response.body}');
          return trips;
        } else {
          print('Échec de la requête: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        print('Erreur de connexion: $e');
        return null;
      }
  }

 Future<String> requestTrips(int? voyageId, int? userID) async {
   var baseUrl = 'https://lalabi.azurewebsites.net/api/trip';
   var path = Uri.parse('$baseUrl/requestpassenger/$voyageId/$userID');

   try {
     var response = await http.post(
         path,
         headers: {
           'Content-Type': 'application/json',
           'Authorization': 'Bearer ${DataManager.instance.token}'
           // Remplacez VOTRE_TOKEN_ICI par votre token réel
         }
     );
     if (response.statusCode == 201) {
       print('Request created successfully');
       return "Your Request created successfully"; // Return true on success
     }else if (response.statusCode == 409){
       return "User already registered as passenger for this trip."; // Return true on success
     }
     else {
       print('Failed to create Request: ${response.statusCode}');
       print(response.body);
       return "Failed to create Request: ${response.statusCode}"; // Return false on failure
     }
   } catch (e) {
     print('Error creating Request: $e');
     return "Error creating Request"; // Return false on exception
   }
 }

  Future<bool> changeEtatPassenger(String status, int? voyageId, int? userId) async {
   // var baseUrl = 'http://localhost:3000/api/trip';
    var baseUrl = 'https://lalabi.azurewebsites.net/api/trip';
    var url = Uri.parse('$baseUrl/changeEtatPassenger/$voyageId/$userId');

    try {
      var response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${DataManager.instance.token}', // Assurez-vous que le token est correctement récupéré
        },
        body: json.encode({'status': status}), // Correction ici
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Server error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending request: $e');
      return false;
    }
  }





Future<void> updateUser(UserModel user) async {
  var manager = DataManager.instance;
  //var url = Uri.parse('https://lalabi.azurewebsites.net/api/users/${user.userID}');
  var url = Uri.parse('https://lalabi.azurewebsites.net/api/users/${user.userID}');
  

  // Convertir l'objet UserModel en JSON
  var userJson = user.toJson();

  try {
    var response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${manager.getToken()}',
      },
      body: json.encode(userJson),
    );

    if (response.statusCode == 200) {
      // Mise à jour réussie
      // Vous pouvez également effectuer d'autres actions ici
      print('Réponse de l\'API lors de la mise à jour: ${response.body}');
    } else {
      // La mise à jour a échoué, affichez un message d'erreur ou effectuez d'autres actions nécessaires
      print('Échec de la mise à jour: ${response.statusCode}');
    }
  } catch (e) {
    // En cas d'erreur lors de la connexion à l'API, vous pouvez afficher un message d'erreur
    print('Erreur de connexion lors de la mise à jour du profil: $e');
  }
}


}