
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tpi_mybi/CostumColor.dart';
import 'package:tpi_mybi/Data/DataLoader.dart';
import 'package:tpi_mybi/model/User.dart';
import 'package:tpi_mybi/ui/views/Dashboard/dashboard.dart';
import 'package:tpi_mybi/ui/views/Login/login.dart';
import 'package:tpi_mybi/ui/widget/custom_theme.dart';

import '../../../Components/Buttons/ButtonImagePicker.dart';
import '../../../Data/DataManager.dart';
import 'dart:io' if (dart.library.html) '';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  @override
  void initState() {
    super.initState();
    DataManager.instance.addListener(_onUserUpdated);
  }

  @override
  void dispose() {
    super.dispose();
    DataManager.instance.removeListener(_onUserUpdated);
  }
  final _formSignupKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  late String pathImage = "";
  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  bool agreePersonalData = true;
  bool agreePassenger = false;
  bool agreeDriver = false;
  bool agreeBoth = false ;

  void _handleCheckboxChange(String role, bool? value) {
    setState(() {
      // Réinitialiser toutes les valeurs à false
      agreePassenger = false;
      agreeDriver = false;
      agreeBoth = false;

      // Activer la case à cocher sélectionnée
      if (role == 'Passenger') {
        agreePassenger = value!;
      } else if (role == 'Driver') {
        agreeDriver = value!;
      } else if (role == 'Both') {
        agreeBoth = value!;
      }
    });
  }

  Future<void> registerUser() async {
    if (!_formSignupKey.currentState!.validate() || !agreePersonalData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields and agree to the terms')),
      );
      return;
    }
    String role;
    if (agreePassenger){
      role = "PASSAGER";
    }
    else if(agreeDriver){
      role = "CONDUCTEUR";
    }
    else {
      role = "BOTH";
    }


      var manager = DataManager.instance;

      UserModel user = UserModel(uid : 0,email: emailController.text.trim(), firstName: firstNameController.text.trim(), lastName: lastNameController.text.trim(), pathImage: pathImage, password: passwordController.text.trim(), role: role);

     // manager.setUser(user);


    var loader = DataLoader.instance;
    loader.createUser(user);




     // UserModel userModel = UserModel.fromFirebaseUser(userCredential.user!);
      /*
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInScreen(),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User registered successfully')),
      );
       */


  }

  void _onUserUpdated(DataManagerUpdateType type) {
    switch (type) {
      case DataManagerUpdateType.userCreateSuccess:
        setState(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SignInScreen(),
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User registered successfully')),
          );
        });
        break;
      case DataManagerUpdateType.userCreateError:
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User registered failed')),
          );
        });
        break;
    // Ajoutez d'autres cas au besoin
      default:
      // Gérez un cas par défaut si nécessaire
        break;
    }
  }




// nom / prenom / mdp / email / photo
  @override
  Widget build(BuildContext context) {
    return CustomTheme(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                // get started form
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // get started text
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: myPrimaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),

                      Column(
                        children: <Widget>[
                          // Utilisez Visibility pour afficher l'image seulement si pathImage n'est pas vide
                          if (kIsWeb && pathImage.isNotEmpty)
                            ClipOval(
                              child: Image.network(
                                pathImage,
                                width: 100, // Définissez la taille de l'image
                                height: 100,
                                fit: BoxFit.cover, // Assurez-vous que l'image couvre bien le cercle
                              ),
                            )
                          /*else if (!kIsWeb && pathImage.isNotEmpty)
      ClipOval(
        child: Image(
          image: FileImage(File(pathImage)),
          width: 100, // Définissez la taille de l'image
          height: 100,
          fit: BoxFit.cover, // Assurez-vous que l'image couvre bien le cercle
        ),
      ),*/,
                          // Utilisez Visibility pour cacher le bouton une fois une image sélectionnée
                          Visibility(
                            // visible: pathImage.isEmpty, // Le bouton est caché si une image est sélectionnée
                            child: ButtonImagePicker(
                              onImageSelected: (imagePath) {
                                setState(() {
                                  pathImage = imagePath; // Mettez à jour pathImage avec le chemin de l'image sélectionnée
                                });
                              },
                            ),
                          ),
                          // Ajoutez d'autres widgets si nécessaire
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),// full name
                      TextFormField(
                        controller: firstNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter First name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('First Name'),
                          hintText: 'Enter First Name',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        controller: lastNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Last name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Last Name'),
                          hintText: 'Enter Last Name',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // email
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // password
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Role :',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          const Text(
                            'Passenger ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          Checkbox(
                            value: agreePassenger,
                            onChanged: (bool? value) {
                              _handleCheckboxChange('Passenger', value);
                            },
                            activeColor: myPrimaryColor,
                          ),
                          const Text(
                            'Driver ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          Checkbox(
                            value: agreeDriver,
                            onChanged: (bool? value) {
                              _handleCheckboxChange('Driver', value);
                            },
                            activeColor: myPrimaryColor,
                          ),
                          const Text(
                            'Both ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          Checkbox(
                            value: agreeBoth,
                            onChanged: (bool? value) {
                              _handleCheckboxChange('Both', value);
                            },
                            activeColor: myPrimaryColor,
                          )
                        ]

                      ),




                      // i agree to the processing
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (bool? value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                            activeColor: myPrimaryColor,
                          ),
                          const Text(
                            'I agree to the processing of ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          Text(
                            'Personal data',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: myPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // signup button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await registerUser();
                          },
                          child: const Text('Sign up'),
                        ),

                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      // sign up divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10,
                            ),
                            child: Text(
                              'Sign up with',
                              style: TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.7,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      // sign up social media logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                        ],
                      ),
                      const SizedBox(
                        height: 25.0,
                      ),
                      // already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.black45,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: myPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                   
                    ],

                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }}