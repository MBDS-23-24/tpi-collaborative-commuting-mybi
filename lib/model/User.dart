class UserModel {
  final int? userID;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? pathImage;
  final String? password;
  final String? role;
  final String? biograthy;
  String? token;
  String currentMessage = "Hello";
  String time = "4:00";

  UserModel({this.userID, this.email, this.firstName, this.lastName, this.pathImage, this.password, this.role, this.biograthy});

  // Méthode toJson pour la sérialisation JSON
  Map<String, dynamic> toJson() => {
    'userID': userID,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'photoURL': pathImage,
    'password': password,
    'role': role,
    'biograthy': biograthy,
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
      biograthy: json['biograthy'],
      role: json['role'],
    );
  }

  String? getToken() {
    return token;
  }

  setToken(String token) {
    this.token = token;
  }
}
