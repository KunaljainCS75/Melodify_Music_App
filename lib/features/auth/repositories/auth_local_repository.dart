import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_local_repository.g.dart';

@Riverpod(keepAlive: true) 
// to prevent creating two instances of auth_local_repo:
// example: One is here below
// Other is in main.dart ---> calling authviewmodel method (getData())....
AuthLocalRepository authLocalRepository(AuthLocalRepositoryRef ref){
  return AuthLocalRepository();
}

class AuthLocalRepository{
  late SharedPreferences _sharedPreferences;

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance(); // Local Mobile Memory Access
  }

  void setToken(String? token) {
    if (token != null){
      _sharedPreferences.setString("x-auth-token", token);
    }
  }

  String? getToken() {
    return _sharedPreferences.getString('x-auth-token');
  }
}