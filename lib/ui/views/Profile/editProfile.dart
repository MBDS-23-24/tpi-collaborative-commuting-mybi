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
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController biographyController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmationPasswordVisible = false;

  String? _newImagePath;

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.user.firstName ?? '';
    lastNameController.text = widget.user.lastName ?? '';
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
        backgroundColor: Colors.teal,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _deleteAccount(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                'Supprimer le compte',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                      'Informations ${widget.user.firstName} ${widget.user.lastName}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                SizedBox(height: 10),
                TextFormField(
                  controller: firstNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre Nom';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Prénom',
                    hintText: 'Entrez votre prénom',
                    border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.teal),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.teal),
                            borderRadius: BorderRadius.circular(10),
                          ),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: lastNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre Nom';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    hintText: 'Entrez votre nom',
                    border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.teal),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.teal),
                            borderRadius: BorderRadius.circular(10),
                          ),
                  ),
                ),
                SizedBox(height: 10),
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
                    hintText: 'Entrez votre adresse e-mail',
                    border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.teal),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.teal),
                            borderRadius: BorderRadius.circular(10),
                          ),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    hintText: 'Entrez votre mot de passe',
                    border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.teal),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.teal),
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                SizedBox(height: 10),
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
                    hintText: 'Confirmez votre mot de passe',
                    border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.teal),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.teal),
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                SizedBox(height: 10),
                
                DropdownButtonFormField<String>(
                  value: roleController.text,
                  onChanged: (String? newValue) {
                    setState(() {
                      roleController.text = newValue!;
                    });
                  },
                  items: ['CONDUCTEUR', 'PASSAGER', 'BOTH']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Rôle',
                    hintText: 'Sélectionnez votre rôle',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.teal),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.teal),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: biographyController,
                  decoration: InputDecoration(
                    labelText: 'Biographie',
                    hintText: 'Entrez votre biographie',
                    border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.teal),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.teal),
                            borderRadius: BorderRadius.circular(10),
                          ),
                  ),
                ),
                SizedBox(height: 10),
                ButtonImagePicker(
                  onImageSelected: (imagePath) {
                    setState(() {
                      _newImagePath = imagePath;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _updateUser();
                  },
                  child: Text('Enregistrer les modifications'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    bool confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmation'),
        content: Text('Êtes-vous sûr de vouloir supprimer votre compte ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Annuler la suppression
            },
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirmer la suppression
            },
            child: Text('Supprimer'),
          ),
        ],
      );
    },
  );

  // On verifie si la suppression a été confirmée
  if (confirmDelete == true) {
    try {
      await DataLoader.instance.deleteUser(widget.user.userID);
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
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      UserModel updatedUser = UserModel(
        userID: widget.user.userID,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: roleController.text,
        biography: biographyController.text,
        pathImage: _newImagePath ?? widget.user.pathImage,
      );

      await DataLoader.instance.updateUser(updatedUser);

      DataManager.instance.setUser(updatedUser);

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(user: updatedUser)),
      );
    }
  }
}