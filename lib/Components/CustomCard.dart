import 'dart:math';

import 'package:flutter/material.dart';
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
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (contex) => IndividualPage(
                  chatModel: chatModel,
                  sourchat: sourchat,
                )));
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