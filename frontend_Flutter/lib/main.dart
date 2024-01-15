import 'package:flutter/material.dart';
import 'package:lalabi_project/Components/Buttons/CustomButton.dart';
import 'package:lalabi_project/Components/TextFields/AddressSearch.dart';

import 'Components/Buttons/ButtonImagePicker.dart';
import 'Components/TextFields/CustomTextField.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void signUserIn() {
    print("Test Button");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Lalabi",
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lalabi'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ButtonImagePicker(
                onImageSelected: (imagePath) {
                  // Utilisez imagePath ici pour traiter ou afficher l'image sélectionnée.
                  print(imagePath);
                },)
          ),
        ),
      ),
    );

    throw UnimplementedError();
  }


}
