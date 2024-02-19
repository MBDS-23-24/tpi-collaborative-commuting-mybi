import 'package:flutter/material.dart';
import 'package:tpi_mybi/model/User.dart' as model;
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tpi_mybi/model/User.dart';
import 'package:tpi_mybi/ui/views/Chat/chat.dart';
import 'package:tpi_mybi/ui/views/home.dart';
import 'firebase_options.dart';
import 'ui/views/Dashboard/dashboard.dart';
import 'ui/views/Login/login.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_database/firebase_database.dart';

import 'package:http/http.dart' as http;


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

/*
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

 */


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<auth.User?>(
        stream: auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // Check if the user is logged in
            auth.User? user = snapshot.data;
            if (user == null) {
              // User not logged in, show SignInScreen
              // var userModel = UserModel(uid: '1', email: "yassine@gmail.com", name: "yassine");
              //fetchData();
              //return DashboardScreen(user: userModel);
              // return ChatScreen();
              return SignInScreen();
            }
            // User is logged in, convert User to UserModel and show DashboardScreen
         //  UserModel userModel = UserModel.fromFirebaseUser(user);
           // return DashboardScreen(user: user);
          }
          // Waiting for authentication state to be available
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}
