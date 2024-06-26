enum RoleType {
  passenger,
  driver,
  both,
}

class UserModel {
  final int? userID;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? pathImage;
  final String? password;
  final String? role;
  final String? biography;
  String? token;
  String currentMessage = "Hello";
  String time = "4:00";


  UserModel({this.userID, this.email, this.firstName, this.lastName, this.pathImage, this.password, this.role, this.biography});


 // UserModel({required this.uid, /*required this.uid,*/ this.email, this.firstName, this.lastName, this.pathImage, this.password, this.role, this.biography});


  /*
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
     // uid: user.uid,
      email: user.email,
      firstName: user.displayName,
    );
  }
   */

  // Méthode toJson pour la sérialisation JSON
  Map<String, dynamic> toJson() => {
    //'userID': userID,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'password': password,
    'photoURL': pathImage,
    'biography': biography,
    'role': role,

    // Ajoutez d'autres champs ici
  };

  // Constructeur à partir d'un objet JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userID: json['userID'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'],
      pathImage: json['photoURL'],
        biography: json['biography'],

      role: json['role']
    );
  }

  String? getToken() {
    return token;
  }

  setToken(String token) {
    this.token = token;
  }
}
