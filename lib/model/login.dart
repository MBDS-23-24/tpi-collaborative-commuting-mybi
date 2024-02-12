class LoginModel {
//final String uid;
final String? email;
final String? password;

LoginModel({/*required this.uid,*/ this.email, this.password});


Map<String, dynamic> toJson() => {
'email': email,
'password' : password
// Ajoutez d'autres champs ici
};

}