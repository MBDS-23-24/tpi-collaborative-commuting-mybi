import 'package:firebase_auth/firebase_auth.dart';

enum RoleType {
  passenger,
  driver,
  both,
}

class UserModel {
  final int uid;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? pathImage;
  final String? password;
  final String? role;
  final String? biography;

  UserModel({required this.uid, /*required this.uid,*/ this.email, this.firstName, this.lastName, this.pathImage, this.password, this.role, this.biography});


  /*
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
     // uid: user.uid,
      email: user.email,
      firstName: user.displayName,
    );
  }
   */

  Map<String, dynamic> toJson() => {
    'email': email,
    'firstName': firstName,
    'lastName' : lastName,
    'photoURL' : pathImage,
    'password' : password,
    'role' : role
    // Ajoutez d'autres champs ici
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        uid: json['userID'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        email: json['email'],
        password: json['password'],
        pathImage: json['photoURL'],
        biography: json['biography'],
        role: json['role']
    );
  }

}
