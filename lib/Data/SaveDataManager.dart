import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tpi_mybi/Data/DataManager.dart';
import 'package:tpi_mybi/model/User.dart';

class SaveDataManager {
  static final SaveDataManager _instance = SaveDataManager._internal();

  factory SaveDataManager() {
    return _instance;
  }

  SaveDataManager._internal();

  // Méthode pour sauvegarder le token
  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Méthode pour récupérer le token
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DataManager.instance.setToken(prefs.getString('token') ?? "");
    return prefs.getString('token');
  }

  // Méthode pour supprimer le token
  Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Méthode pour sauvegarder l'utilisateur
  Future<void> saveUser(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    await prefs.setString('user', userJson);
  }

  // Méthode pour récupérer l'utilisateur
  Future<UserModel?> getUserLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      DataManager.instance.setUser(UserModel.fromJson(userMap));
      return UserModel.fromJson(userMap);
    }
    return null; // Retourne null si aucun utilisateur n'est trouvé dans les préférences
  }

  // Méthode pour supprimer l'utilisateur
  Future<void> removeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }
}
