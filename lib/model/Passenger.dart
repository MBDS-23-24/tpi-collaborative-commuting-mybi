enum RoleType {
  passenger,
  driver,
  both,
}

class Passenger {
  final int? userID;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? pathImage;
  final String? password;
  final String? role;
  final String? biograthy;
  final String? status;
  String? token;
  String currentMessage = "Hello";
  String time = "4:00";

  Passenger({this.userID, this.email, this.firstName, this.lastName, this.pathImage, this.password, this.role, this.biograthy,this.status});

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
    'userID': userID,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'photoURL': pathImage,
    'password': password,
    'role': role,
    'biograthy': biograthy,
    'status': status,
    // Ajoutez d'autres champs ici
  };

  // Constructeur à partir d'un objet JSON
  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
        userID: json['UserID'],
        firstName: json['FirstName'],
        lastName: json['LastName'],
        email: json['Email'],
        password: json['Password'],
        pathImage: json['PhotoURL'],
        biograthy: json['Biography'],
        role: json['Role'],
        status: json['status']
    );
  }

  String? getToken() {
    return token;
  }

  setToken(String token) {
    this.token = token;
  }
}
