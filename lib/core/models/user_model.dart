// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:client/features/home/models/fav_song_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String token;
  final List<FavSongModel> favourites;
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.favourites,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    List<FavSongModel>? favourites,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      favourites: favourites ?? this.favourites,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'favourites': favourites.map((x) => x.toMap()).toList(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
      favourites: List<FavSongModel>.from(
        (map['favourites'] ?? []).map<FavSongModel>(
          (x) => FavSongModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, token: $token, favourites: $favourites)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.email == email &&
        other.token == token &&
        listEquals(other.favourites, favourites);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        token.hashCode ^
        favourites.hashCode;
  }
}
