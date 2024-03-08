import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tpi_mybi/Data/DataLoader.dart';
import 'package:tpi_mybi/model/User.dart';

import '../ui/views/Chat/IndividualPage.dart';

class CustomCard extends StatelessWidget {
   CustomCard({  key,  required this.chatModel,  required this.sourchat, required this.content, required this.timestamp}) : super(key: key);
  final UserModel chatModel;
  final UserModel sourchat;
  final String content;
  final String timestamp;
  late double rating;


  // Fonction pour obtenir un chemin d'image aléatoire
  String getRandomImagePath() {
    List<String> images = [
      "assets/covoiturage.png",
      "assets/covoiturage2.png",
      "assets/covoiturage3.jpg"
    ];
    int randomIndex = Random().nextInt(images.length);
    return images[randomIndex];
  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // Variable pour stocker le commentaire saisi par l'utilisateur
            String userComment = '';

            // Variable pour stocker la note
            double rating = 3.0;

            return AlertDialog(
              title: const Text('Noter l\'utilisateur'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Donnez une note et un commentaire à cet utilisateur.'),
                    // Widget de notation
                    RatingBar.builder(
                      initialRating: 3,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (newRating) {
                        print(newRating);
                        rating = newRating; // Met à jour la note
                      },
                    ),
                    SizedBox(height: 20), // Ajoute un espace entre les éléments
                    // Champ de saisie pour le commentaire
                    TextField(
                      onChanged: (value) {
                        userComment = value; // Met à jour le commentaire à chaque saisie
                      },
                      decoration: InputDecoration(
                        hintText: "Entrez votre commentaire ici",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Ferme la popup
                  },
                ),
                TextButton(
                  child: const Text('Soumettre'),
                  onPressed: () {
                    // Ici, vous pouvez gérer la soumission de la note et du commentaire
                    // Par exemple, en les envoyant à un serveur ou en les stockant localement
                    DataLoader.instance.rateUser(chatModel.userID, rating, userComment);
                    Navigator.of(context).pop(); // Ferme la popup après la soumission
                  },
                ),
              ],
            );
          },

                );



        /*
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (contex) => IndividualPage(
                  chatModel: chatModel,
                  sourchat: sourchat,

                )));

         */
      },
      child: Column(
        children: [
          ListTile(
           /* leading: CircleAvatar(
              radius: 30,
              child: Image.asset(
                chatModel.pathImage != null ? "assets/logo.jpg" : "assets/bg1.png",
                color: Colors.white,
                height: 36,
                width: 36,
              ),
              backgroundColor: Colors.blueGrey,
            )
            ,

            */

            leading: CircleAvatar(
            radius: 30,
              backgroundImage:  AssetImage(getRandomImagePath()),
            ),
            title: Text(
              chatModel.firstName.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

           subtitle: Row(
              children: [
                Icon(Icons.done_all),
                SizedBox(
                  width: 3,
                ),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            trailing: Text(timestamp),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 80),
            child: Divider(
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}