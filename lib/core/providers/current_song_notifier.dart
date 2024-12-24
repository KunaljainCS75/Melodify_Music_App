// ignore_for_file: avoid_public_notifier_properties
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'current_song_notifier.g.dart';

@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier{
  late HomeLocalRepository _homeLocalRepository;
  AudioPlayer? audioPlayer;
  bool isPlaying = false;

  @override
  SongModel? build() {
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null;
  }

  void removeSong(SongModel song){
    audioPlayer?.pause();
    state = null;
    _homeLocalRepository.deleteLocalSong(song);
  }

  void playPause() {
    if (isPlaying){
      audioPlayer?.pause();
    } else {
      audioPlayer?.play();
    }
    isPlaying = !isPlaying;

    // Trick riverpod in thinking that state is changed
    state = state?.copyWith(hex_code: state?.hex_code);
  }

  void updateSong(SongModel song) async {
    await audioPlayer?.stop();
    audioPlayer = AudioPlayer(); // new instance is created when a new song is selected
    // await audioPlayer!.setUrl(song.song_url); // one approach

    // this approach is better
    // here, we have "AudioSource.uri" parameter tag => allows to play song in background
    // also good for multiple songs queue feature
    final audioSource = AudioSource.uri(
      Uri.parse(song.song_url),
      tag: MediaItem(
        id: song.id,
        title: song.song_name,
        artist: song.artist,
        artUri: Uri.parse(song.thumbnail_url)
      )
    );
    await audioPlayer!.setAudioSource(audioSource);

    // Store in local database (hive) before playing a new song
    _homeLocalRepository.uploadLocalSong(song);

    // Start Playing Song
    audioPlayer!.play();
    isPlaying = true;
    state = song;

    // if song has completed then restart the duration & stop playing
    audioPlayer!.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed){
        audioPlayer!.seek(Duration.zero);
        audioPlayer!.pause();
        isPlaying = false;
        this.state = this.state!.copyWith(hex_code: this.state!.hex_code);
      }
    });
  }

  // seek
  void seek(double value){
    audioPlayer!.seek(
      Duration(milliseconds: (value * audioPlayer!.duration!.inMilliseconds).toInt()));
  }
}