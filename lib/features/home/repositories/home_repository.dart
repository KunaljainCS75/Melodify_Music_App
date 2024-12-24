import 'dart:convert';
import 'dart:io';

import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/failure/failure.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref){
  return HomeRepository();
}

class HomeRepository {

  /// UPLOAD SONG
  Future<Either<AppFailure, String>> uploadSong({
    required File selectedAudio, 
    required File selectedThumbnail,
    required String songName,
    required String artistName,
    required String hexCode,
    required String token
  }) async {
    try{
      final request = http.MultipartRequest(
          'POST', Uri.parse('${ServerConstant.serverUrl}/song/upload')
      );
      request..files.addAll([
        await http.MultipartFile.fromPath('song', selectedAudio.path),
        await http.MultipartFile.fromPath('thumbnail', selectedThumbnail.path)
      ])..fields.addAll({
        'artist' : artistName,
        'song_name' : songName,
        'hex_code': hexCode,
      })..headers.addAll({
        'x-auth-token' : token,
      });

      final res = await request.send();

      if (res.statusCode != 201){
        return Left(AppFailure(await res.stream.bytesToString()));
      }
      return Right(await res.stream.bytesToString());

    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  /// FETCH SONGS
  Future<Either<AppFailure, List<SongModel>>> getAllSongs({required String token}) async {
    try {
      // Request Phase
      final res = await http.get(
        Uri.parse('${ServerConstant.serverUrl}/song/list'),
        headers: {
          'Content-Type' : 'application/json',
          'x-auth-token' : token
        }  
      );
      // Decode response
      var resBodyMap = jsonDecode(res.body);

      // Failure case
      if (res.statusCode != 200){
        resBodyMap = resBodyMap as Map<String, dynamic>; 
        return Left(AppFailure(resBodyMap['detail']));
      }

      // Success fetching
      resBodyMap = resBodyMap as List; // For loop iteration
      List<SongModel> songs = [];
      
      for (final map in resBodyMap){
        songs.add(SongModel.fromMap(map));
      }
      return Right(songs);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  } 

  /// Favourite/Unfavourite a song
  Future<Either<AppFailure, bool>> favSong({
    required String token, 
    required String songId}) async {
    try {
      // Request Phase
      final res = await http.post(
        Uri.parse('${ServerConstant.serverUrl}/song/favourite'),
        headers: {
          'Content-Type' : 'application/json',
          'x-auth-token' : token
        },
        body: jsonEncode({
          "song_id" : songId
        }), 
      );
      // Decode response
      var resBodyMap = jsonDecode(res.body);

      // Failure case
      if (res.statusCode != 200){
        resBodyMap = resBodyMap as Map<String, dynamic>; 
        return Left(AppFailure(resBodyMap['detail']));
      }

      // Success fetching 
      return Right(resBodyMap['message']);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  } 

  /// FETCH Favourite Songs
  Future<Either<AppFailure, List<SongModel>>> getAllFavSongs({required String token}) async {
    try {
      // Request Phase
      final res = await http.get(
        Uri.parse('${ServerConstant.serverUrl}/song/list/favourites'),
        headers: {
          'Content-Type' : 'application/json',
          'x-auth-token' : token
        },
      );
      // Decode response
      var resBodyMap = jsonDecode(res.body);

      // Failure case
      if (res.statusCode != 200){
        resBodyMap = resBodyMap as Map<String, dynamic>; 
        return Left(AppFailure(resBodyMap['detail']));
      }

      // Success fetching
      resBodyMap = resBodyMap as List; // For loop iteration
      List<SongModel> songs = [];
      
      for (final map in resBodyMap){
        songs.add(SongModel.fromMap(map['song']));
      }

      return Right(songs);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

   /// Delete a song
  Future<Either<AppFailure, String>> deleteSong({
    required String token, 
    required String songId}) async {
    try {
      // Request Phase
      final res = await http.delete(
        Uri.parse('${ServerConstant.serverUrl}/song/delete'),
        headers: {
          'Content-Type' : 'application/json',
          'x-auth-token' : token
        },
        body: jsonEncode({
          "song_id" : songId
        }), 
      );
      // Decode response
      var resBodyMap = jsonDecode(res.body);

      // Failure case
      if (res.statusCode != 204){
        resBodyMap = resBodyMap as Map<String, dynamic>; 
        return Left(AppFailure(resBodyMap['detail']));
      }

      // Success fetching 
      return const Right("Deletion Successful");
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  } 

}
