import 'User.dart';

class AccessToken {
  final String accessToken;
  final UserModel userModel;

  AccessToken({required this.accessToken, required this.userModel});

  factory AccessToken.fromJson(Map<String, dynamic> json) {
    return AccessToken(
      accessToken: json['accessToken'],
        userModel: UserModel.fromJson(json['user'] as Map<String, dynamic>)
    );
  }
}
