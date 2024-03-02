import 'package:flutter/material.dart';
import 'package:tpi_mybi/Data/DataManager.dart';
import 'package:tpi_mybi/Data/SaveDataManager.dart';
import 'package:tpi_mybi/model/User.dart';
import 'package:tpi_mybi/ui/views/Dashboard/dashboard.dart';
import 'package:tpi_mybi/ui/views/Login/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: SaveDataManager().getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Si la future est en cours de chargement, affichez un indicateur de chargement
          return MaterialApp(
            title: 'LALABI',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          // Si une erreur s'est produite lors de la récupération des données, affichez un message d'erreur
          return MaterialApp(
            title: 'LALABI',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: Scaffold(
              body: Center(
                child: Text('Une erreur s\'est produite lors de la récupération des données. ${snapshot.error}'),
              ),
            ),
          );
        } else {
          // Si aucune erreur ne s'est produite et que des données sont disponibles, affichez l'écran correspondant
          final UserModel? user = snapshot.data;

          if (user != null) {
            // Si un utilisateur est récupéré, configurez-le dans DataManager et affichez le tableau de bord
            DataManager.instance.setUser(user);
            return MaterialApp(
              title: 'LALABI',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: DashboardScreen(user: user),
            );
          } else {
            // Si aucun utilisateur n'est récupéré, affichez l'écran de connexion
            return MaterialApp(
              title: 'LALABI',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: SignInScreen(),
            );
          }
        }
      },
    );
  }
}
