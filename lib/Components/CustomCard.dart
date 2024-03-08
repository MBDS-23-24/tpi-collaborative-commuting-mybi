import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tpi_mybi/model/User.dart';

import '../ui/views/Chat/IndividualPage.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({  key,  required this.chatModel,  required this.sourchat, required this.content, required this.timestamp}) : super(key: key);
  final UserModel chatModel;
  final UserModel sourchat;
  final String content;
  final String timestamp;
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
            // Retourne un AlertDialog contenant le widget de notation
            return AlertDialog(
              title: const Text('Noter l\'utilisateur'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Donnez une note à cet utilisateur.'),
                    // Ici, vous intégrez votre widget de notation
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
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
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
                    // Ici, vous pouvez gérer la soumission de la note, par exemple, l'enregistrer pour l'utilisateur
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