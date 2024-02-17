import 'package:flutter/material.dart';
import 'package:tpi_mybi/model/User.dart';

class ProfilPage extends StatelessWidget {
  final UserModel user;

  ProfilPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(user.pathImage ?? ''),
              radius: 60,
            ),
            SizedBox(height: 20),
            Text(
              '${user.firstName} ${user.lastName}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '${user.email}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Rôle: ${user.role}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Biographie:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              // Ajoutez ici la biographie de l'utilisateur
              'Je vais récuperer la Bio ici ...',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la page de modification des informations
                // Ajoutez votre logique de navigation ici
              },
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              child: Text('Modifier les informations',
              style: TextStyle(color: Colors.white),),
              
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Ajoutez votre logique pour supprimer le compte
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Utilisez une couleur différente pour le bouton de suppression
              ),
              child: Text('Supprimer le compte',
              style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}