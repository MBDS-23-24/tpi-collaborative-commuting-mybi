import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tpi_mybi/Components/Buttons/ButtonImagePicker.dart';
import 'package:tpi_mybi/Data/DataLoader.dart';
import 'package:tpi_mybi/Data/DataManager.dart';
import 'package:tpi_mybi/model/User.dart';
import 'package:tpi_mybi/ui/views/Login/login.dart';
import 'package:tpi_mybi/ui/views/Profile/profile.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  EditProfilePage({required this.user});
  

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lasteNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController biographyController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmationPasswordVisible = false;

  String? _newImagePath;

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.user.firstName ?? '';
    lasteNameController.text = widget.user.lastName ?? '';
    emailController.text = widget.user.email ?? '';
    passwordController.text = widget.user.password ?? '';
    roleController.text = widget.user.role ?? '';
    biographyController.text = widget.user.biography ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: firstNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre Nom';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'First Name ',
                  ),
                ),
                TextFormField(
                  controller: lasteNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre Prénom';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Last Name ',
                  ),
                ),
                TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre adresse e-mail';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Adresse e-mail',
                  ),
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !_isConfirmationPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    } else if (value != passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmationPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmationPasswordVisible =
                              !_isConfirmationPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                TextFormField(
                  controller: roleController,
                  decoration: InputDecoration(
                    labelText: 'Rôle',
                  ),
                ),
                TextFormField(
                  controller: biographyController,
                  decoration: InputDecoration(
                    labelText: 'Biographie',
                  ),
                ),
                Visibility(
                  child: ButtonImagePicker(
                    onImageSelected: (imagePath) {
                      setState(() {
                        _newImagePath = imagePath;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    await _updateUser();
                  },
                  child: Text('Enregistrer les modifications'),
                ),
                SizedBox(height: 20.0),
                // Bouton pour supprimer le compte
                        ElevatedButton(
                          onPressed: () {
                            _deleteAccount(context);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                          ),
                          child: Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _deleteAccount(BuildContext context) async {
    try {
      await DataLoader.instance.deleteUser(widget.user.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte supprimé avec succès')),
      );

      Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()), 
      (route) => false,
    );
    } catch (e) {
      print('Erreur lors de la suppression du compte : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du compte')),
      );
    }
  }


  Future<void> _updateUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      // c"ation d un nouvel objet UserModel avec les données mises à jour
      UserModel updatedUser = UserModel(
        uid: widget.user.uid,
        firstName: firstNameController.text,
        lastName: lasteNameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: roleController.text,
        biography: biographyController.text,
        pathImage: _newImagePath ?? widget.user.pathImage,
      );

      print('Avant la mise à jour : $widget.user');

      // méthode pour mettre à jour l'utilisateur
      await DataLoader.instance.updateUser(updatedUser);

      DataManager.instance.setUser(updatedUser);

      // Retourner à la page de profil après la mise à jour
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(user: updatedUser)),
      );
    }
  }
}
