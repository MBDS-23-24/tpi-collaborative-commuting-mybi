import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lalabi_project/Components/Buttons/CustomButton.dart';
import 'package:lalabi_project/Components/TextFields/AddressSearch.dart';

import 'Components/Buttons/ButtonImagePicker.dart';
import 'Components/TextFields/CustomTextField.dart';
import 'Views/AuthGate.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthGate(),
    );
    /*
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

     */
  }


}
