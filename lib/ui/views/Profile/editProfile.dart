import 'package:flutter/material.dart';
import 'package:tpi_mybi/model/User.dart';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        _isConfirmationPasswordVisible = !_isConfirmationPasswordVisible;
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
              
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    Navigator.pop(context);
                  }
                },
                child: Text('Enregistrer les modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}