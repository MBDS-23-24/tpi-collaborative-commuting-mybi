import 'package:flutter/material.dart';


import 'package:tpi_mybi/ui/views/home.dart';

import 'package:http/http.dart' as http;


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line

  runApp(MyApp());
}

Future<void> fetchData() async {
  var url = Uri.parse('https://integrationlalabi.azurewebsites.net/api/users');
  try {
    var response = await http.get(url);
    if (response.statusCode == 200) {
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


class MyApp extends StatelessWidget {
  static const String ACCESS_TOKEN = String.fromEnvironment("ACCESS_TOKEN");

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polyline example',
      theme: ThemeData(

        primarySwatch: Colors.orange,
      ),
      home: HomeView(),
    );
  }
}

