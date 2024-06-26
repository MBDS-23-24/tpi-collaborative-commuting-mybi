import 'package:flutter/material.dart';
import 'package:tpi_mybi/Data/DataLoader.dart';
import 'package:tpi_mybi/Data/DataManager.dart';
import 'package:tpi_mybi/model/User.dart';
import 'package:tpi_mybi/ui/views/Login/login.dart';
import 'package:tpi_mybi/ui/views/Profile/editProfile.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;
  final bool isCurrentUserProfile;

  ProfilePage({required this.user, required this.isCurrentUserProfile});

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Profil'),
            Spacer(), // Pour occuper l'espace restant
            ElevatedButton(
              onPressed: () {
                DataManager.instance.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInScreen(),
                  ),
                );
              },
              child: Text('Logout'),
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
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
              children: <Widget>[
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.pathImage ?? ''),
                      radius: 60,
                    ),
                    if (isCurrentUserProfile)
                      CircleAvatar(
                        backgroundColor: Colors.indigo,
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
                SizedBox(height: 20),
                _ProfileInfo(user: user),
              ],
            ),
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
        Text(
          "${user.firstName} ${user.lastName}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black, 
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Email : ${user.email}",
          style: TextStyle(
            fontSize: 12,
            color: Colors.black, 
          ),
        ),
        const SizedBox(height: 15),
        Text(
          '${user.role ?? "N/A"}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
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
