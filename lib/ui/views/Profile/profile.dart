import 'package:flutter/material.dart';
import 'package:tpi_mybi/Data/DataLoader.dart';
import 'package:tpi_mybi/model/User.dart';
import 'package:tpi_mybi/ui/views/Profile/editProfile.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;

  ProfilePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.8,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.lime[50],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Photo du profil
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(user.pathImage ?? ''),
                          radius: 60,
                        ),
                        // Bouton vers la page edit
                        CircleAvatar(
                          backgroundColor: Colors.green,
                          child: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfilePage(user: user)),
                              );
                            },
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    // Informations du profil
                    _ProfileInfo(user: user),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final UserModel user;

  _ProfileInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Nom et prénom
        Text(
          "${user.firstName} ${user.lastName}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 15),
        // Rôle
        Text(
          'Rôle: ${user.role ?? "N/A"}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 50),
        // Biographie
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "${user.biography}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}