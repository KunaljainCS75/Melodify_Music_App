import 'package:client/core/constants/size_constant.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/music_player.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:client/features/home/widgets/song_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicSlab extends ConsumerWidget {
  const MusicSlab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongNotifierProvider);
    final songNotifier = ref.read(currentSongNotifierProvider.notifier);
    final userFavs = ref
        .watch(currentUserNotifierProvider.select((data) => data!.favourites));
    if (currentSong == null) {
      return const SizedBox();
    }
    final color = hexToColor(currentSong.hex_code);
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const MusicPlayer()));
        // Navigator.of(context).push(
        //   PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation){
        //     return const MusicPlayer();
        // }, transitionsBuilder: (context, animation, secondaryAnimation, child) {
        //   final tween = Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeIn));
        //   final offsetAnimation = animation.drive(tween);
        //   return SlideTransition(position: offsetAnimation, child: child);
        // }));
      },
      child: Stack(
        children: [
          // Music Details
          Hero(
            tag: 'music-image',
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              height: Sizes.defaultSpace * 3,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Sizes.radiusSm),
                  color: Colors.grey.shade900),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(Sizes.defaultSpace / 3),
                          child: SongImage(
                              song: currentSong,
                              width: Sizes.defaultSpace * 3)),
                      const SizedBox(width: Sizes.spaceBtwItems / 2),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(currentSong.song_name,
                              style: TextStyle(
                                  color: color,
                                  fontSize: Sizes.textSm,
                                  fontWeight: FontWeight.w500)),
                          // const SizedBox(height: s),
                          Text(currentSong.artist,
                              style: const TextStyle(
                                  fontSize: Sizes.textSm / 1.3)),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      /// Favoutites Button
                      IconButton(
                          onPressed: () async {
                            await ref
                                .read(homeViewmodelProvider.notifier)
                                .favSong(songId: currentSong.id);
                          },
                          icon: Icon(userFavs
                                  .where((fav) => fav.song_id == currentSong.id)
                                  .toList()
                                  .isNotEmpty
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart)),

                      /// Play - Pause Button
                      IconButton(
                          onPressed: songNotifier.playPause,
                          icon: songNotifier.isPlaying
                              ? const Icon(CupertinoIcons.pause)
                              : const Icon(CupertinoIcons.play_fill)),
                    ],
                  )
                ],
              ),
            ),
          ),

          // Duration Bars
          Positioned(
            bottom: 0,
            left: 8,
            child: Container(
              height: Sizes.defaultSpace / 5,
              width: MediaQuery.of(context).size.width - 16,
              decoration: BoxDecoration(
                  color: Pallete.backgroundColor,
                  border: Border.all(color: Pallete.whiteColor, width: 0.4)),
            ),
          ),
          StreamBuilder(
              stream: songNotifier.audioPlayer?.positionStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                final duration = songNotifier.audioPlayer?.duration;
                final position = snapshot.data;
                double sliderValue = 0.0;
                if (position != null && duration != null) {
                  sliderValue =
                      position.inMilliseconds / duration.inMilliseconds;
                }
                return Positioned(
                  bottom: 0,
                  left: 8,
                  child: Container(
                    height: Sizes.defaultSpace / 5,
                    width:
                        sliderValue * (MediaQuery.of(context).size.width - 16),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        border: Border.all(color: Colors.white, width: 0.4)),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
