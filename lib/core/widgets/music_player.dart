import 'package:client/core/constants/size_constant.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:client/features/home/widgets/song_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicPlayer extends ConsumerWidget {
  const MusicPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final songNotifier = ref.read(currentSongNotifierProvider.notifier);
    final color = hexToColor(currentSong!.hex_code);
    final userFavs = ref.watch(currentUserNotifierProvider.select((data) => data!.favourites)); 
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color,
            const Color(0xff121212)
          ]
        )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text("Melodify"),
          leading:  //// DELETE SONG
              IconButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await ref.read(homeViewmodelProvider.notifier).deleteSong(songId: currentSong.id);
                  songNotifier.removeSong(currentSong);
                  
                },
                icon: const Icon(CupertinoIcons.delete)
              ),    
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.defaultSpace),
          child: Column(
            children: [
              Expanded(
                  flex: 3,
                  child: Hero(
                    tag: 'music-image',
                    child: SongImage(
                        song: currentSong,
                        // height: Sizes.sizeMd,
                        width: MediaQuery.of(context).size.width),
                  )),
              const SizedBox(height: Sizes.spaceBtwSections / 2),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Song Name
                            Text(currentSong.song_name,
                                style: const TextStyle(
                                    fontSize: Sizes.textMd,
                                    fontWeight: FontWeight.w700)),
      
                            /// Artist Name
                            Text(currentSong.artist,
                                style: const TextStyle(
                                    fontSize: Sizes.textSm,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                         IconButton(
                          onPressed: () async {
                            await ref.read(homeViewmodelProvider.notifier).favSong(songId: currentSong.id);
                          },
                          icon: Icon(
                            userFavs.where((fav) => fav.song_id == currentSong.id).toList().isNotEmpty 
                                      ? CupertinoIcons.heart_fill
                                      : CupertinoIcons.heart
                                    )
                        ),

                   
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwSections),

                    /// Duration Bar
                    StreamBuilder(
                      stream: songNotifier.audioPlayer?.positionStream,
                      builder: (context, snapshot) {
                         if (snapshot.connectionState == ConnectionState.waiting){
                          return const SizedBox();
                        }
                        final duration = songNotifier.audioPlayer?.duration;
                        final position = snapshot.data;
                        double sliderValue = 0.0;
                        if (position != null && duration != null){
                          sliderValue = position.inMilliseconds / duration.inMilliseconds;
                        }
                        return Column(
                          children: [
                            StatefulBuilder(
                              builder: (context, setState) => SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: color,
                                  overlayShape: SliderComponentShape.noOverlay,
                                  thumbColor: Colors.white
                                ),
                                child: Slider(
                                  value: sliderValue,
                                  onChanged: (value) => setState(() => sliderValue = value),                                  
                                  onChangeEnd: (value) => songNotifier.seek(value)
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${position!.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}'),                                  
                                Text('${duration!.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}'),
                              ],
                            )
                          ],
                        );
                      }
                    ),
                    const SizedBox(height: Sizes.spaceBtwSections / 2 ),
            
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/images/shuffle.png', color: Pallete.whiteColor),
                        Image.asset('assets/images/previus-song.png', color: Pallete.whiteColor),
                        IconButton(
                          onPressed: songNotifier.playPause, 
                          icon: Icon(
                            songNotifier.isPlaying 
                              ? CupertinoIcons.pause_circle_fill 
                              : CupertinoIcons.play_circle_fill, 
                            size: Sizes.iconMd * 2, 
                            color: Pallete.whiteColor
                          )
                        ),
                        Image.asset('assets/images/next-song.png', color: Pallete.whiteColor),
                        Image.asset('assets/images/repeat.png', color: Pallete.whiteColor),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwSections / 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/images/connect-device.png', color: Pallete.whiteColor),
                        Image.asset('assets/images/playlist.png', color: Pallete.whiteColor),
                      ],
                    )
                  ],
                ),
              ),
      
             
        
            ],
          ),
        ),
      ),
    );
  }
}
