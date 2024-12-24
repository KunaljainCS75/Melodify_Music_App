import 'dart:convert';
import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/failure/failure.dart';
import 'package:client/core/models/user_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_remote_repository.g.dart';

@riverpod
AuthRemoteRepository authRemoteRepository(AuthRemoteRepositoryRef ref) {
  return AuthRemoteRepository();
}
//--------------------------------SIGN_UP REQUEST----------------------------------// 
class AuthRemoteRepository {
  Future<Either<AppFailure, UserModel>> signup(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final response = await http.post(
          Uri.parse("${ServerConstant.serverUrl}/auth/signup"),
          headers: {'Content-Type': 'application/json'},
          body:
              jsonEncode({'name': name, 'email': email, 'password': password}));
      
      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 201){
        // handle error
        return Left(AppFailure(resBodyMap['detail']));/////
      }


      return Right(UserModel.fromMap(resBodyMap));
      // print(response.body);
      // print(response.statusCode);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
//--------------------------------LOGIN REQUEST----------------------------------// 
  Future<Either<AppFailure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
          Uri.parse("${ServerConstant.serverUrl}/auth/login"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password})
      );

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200){
        return Left(AppFailure(resBodyMap['detail']));
      }

      // return Right(UserModel.fromMap(resBodyMap)); // Intially we were returning directly resBodyMap
      // But now after using PyJWT, our map is changed
      return Right(UserModel.fromMap(resBodyMap['user']).copyWith(token: resBodyMap['token']));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
//--------------------------GET_CURRENT_USER_DATA REQUEST (by token)------------------------//
  Future<Either<AppFailure, UserModel>> getCurrentUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${ServerConstant.serverUrl}/auth"),
        headers: {
          'Content-Type' : "application/json",
          'x-auth-token' : token,
        },
      );

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200){
        return Left(AppFailure(resBodyMap['detail']));
      }

      return Right(UserModel.fromMap(resBodyMap).copyWith(token: token));

    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
}
