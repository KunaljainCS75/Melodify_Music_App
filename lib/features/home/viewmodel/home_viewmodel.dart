import 'dart:io';
import 'dart:ui';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/models/fav_song_model.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
// import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:client/features/home/repositories/home_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_viewmodel.g.dart';

@riverpod
Future<List<SongModel>> getAllSongs(GetAllSongsRef ref) async {
  final token = ref.watch(currentUserNotifierProvider.select((user) => user!.token));
  final res = await ref.watch(homeRepositoryProvider).getAllSongs(token: token);
  
  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r
  };
}

@riverpod
Future<List<SongModel>> getAllFavSongs(GetAllFavSongsRef ref) async {
  final token = ref.watch(currentUserNotifierProvider.select((user) => user!.token));
  final res = await ref.watch(homeRepositoryProvider).getAllFavSongs(token: token);
  
  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r
  };
}

@riverpod
class HomeViewmodel extends _$HomeViewmodel {
  late HomeRepository _homeRepository;
  late HomeLocalRepository _homeLocalRepository;

  @override
  AsyncValue? build() {
    _homeRepository = ref.watch(homeRepositoryProvider);
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null;
  }

  Future<void> uploadSong({
    required File selectedAudio,
    required File selectedThumbnail,
    required String songName,
    required String artistName,
    required Color seletedColor,
  }) async {
    state = const AsyncValue.loading();
    final res = await _homeRepository.uploadSong(
        selectedAudio: selectedAudio,
        selectedThumbnail: selectedThumbnail,
        songName: songName,
        artistName: artistName,
        hexCode: rgbToHex(seletedColor),
        token: ref.read(currentUserNotifierProvider)!.token);

    final val = switch (res) {
      Left(value: final l) => state =
          AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => state = AsyncValue.data(r)
    };
    print(val);
  }

  // Mark Favourite
  Future<void> favSong({required String songId}) async {
    state = const AsyncValue.loading();
    final res = await _homeRepository.favSong(
        songId: songId,
        token: ref.read(currentUserNotifierProvider)!.token);

    final val = switch (res) {
      Left(value: final l) => state = AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => _favSongSuccessFunction(r, songId)
    };
    print(val);
  }

  _favSongSuccessFunction(bool isFavourited, String songId){
    final userNotifier = ref.read(currentUserNotifierProvider.notifier);
    if (isFavourited){
      userNotifier.addUser(
        ref.read(currentUserNotifierProvider)!.copyWith(
          favourites: [
            ...ref.read(currentUserNotifierProvider)!.favourites,
            FavSongModel(id: '', song_id: songId, user_id: '')
          ]
        )
      );
    } else {
      userNotifier.addUser(
        ref.read(currentUserNotifierProvider)!.copyWith(
          favourites: ref.read(currentUserNotifierProvider)!
                      .favourites.where((fav) => fav.song_id != songId).toList()
        )
      );
    }
    ref.invalidate(getAllFavSongsProvider); // to run this method and update library in real time
    return state = AsyncValue.data(isFavourited);
  }

  // Delete
  Future<void> deleteSong({required String songId}) async {
    state = const AsyncValue.loading();
    final res = await _homeRepository.deleteSong(
        songId: songId,
        token: ref.read(currentUserNotifierProvider)!.token);

    final val = switch (res) {
      Left(value: final l) => state = AsyncValue.error(l.message, StackTrace.current),
      Right(value: final r) => AsyncValue.data(r)
    };
    print(val);
  }

  List<SongModel> getRecentlyPlayedSongs() {
    return _homeLocalRepository.loadSongs();
  }
}
