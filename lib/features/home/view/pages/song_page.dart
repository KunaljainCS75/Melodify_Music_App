import 'package:client/core/constants/size_constant.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:client/features/home/widgets/song_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SongsPage extends ConsumerWidget {
  const SongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyPlayedSongs =
        ref.watch(homeViewmodelProvider.notifier).getRecentlyPlayedSongs();
    final currentSong = ref.watch(currentSongNotifierProvider);
    // whenever a song changes, above code of line rebuilds whole widget
    int length = recentlyPlayedSongs.length;
    if (length > 0 && length % 6 == 0) {
      length = 6;
    } else if (length >= 6) {
      length = 6;
    }
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      decoration: currentSong == null
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(Sizes.radiusSm),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    hexToColor(currentSong.hex_code),
                    Pallete.transparentColor
                  ],
                  stops: const [
                    0.0,
                    0.4
                  ])),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Sizes.defaultSpace),

          /// Recently Played Songs:
          SizedBox(
            height: Sizes.sizeMd * 2,
            child: length == 0
                ? const Padding(
                    padding: EdgeInsets.all(Sizes.defaultSpace),
                    child: Row(
                      children: [
                        Image(
                          image: AssetImage("assets/images/image.png"),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 24),
                              Text("Welcome to Melodify",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Pallete.gradient2),
                                  textAlign: TextAlign.center),
                              SizedBox(height: 24),
                              Text(
                                  "Start adding your loveliest songs in your collection...",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: Sizes.defaultSpace * 9,
                      childAspectRatio: 3.5,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: Sizes.defaultSpace / 2,
                    ),
                    itemCount: length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final song = recentlyPlayedSongs[index];
                      final color = hexToColor(song.hex_code);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.defaultSpace / 6),
                        child: GestureDetector(
                          onTap: () => ref
                              .read(currentSongNotifierProvider.notifier)
                              .updateSong(song),
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.grey.shade900, color],
                                    stops: const [0.6, 1]),
                                // border: Border.all(color: color),
                                borderRadius:
                                    BorderRadius.circular(Sizes.radiusSm)),
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.all(Sizes.radiusSm / 2),
                                  child: SongImage(
                                      song: song,
                                      height: Sizes.defaultSpace * 2,
                                      width: Sizes.defaultSpace * 2),
                                ),
                                const SizedBox(width: Sizes.defaultSpace / 2),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        song.song_name,
                                        style: const TextStyle(
                                            fontSize: Sizes.textMd / 1.5,
                                            fontWeight: FontWeight.w700),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Text(song.artist, style: const TextStyle(fontSize: Sizes.textSm / 2)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
          ),

          /// Heading
          const Padding(
            padding: EdgeInsets.all(Sizes.defaultSpace),
            child: Text('All your Songs',
                style: TextStyle(
                    fontSize: Sizes.textMd, fontWeight: FontWeight.w700)),
          ),

          /// Songs View
          ref.watch(getAllSongsProvider).when(
              data: (songs) {
                return SizedBox(
                  height: Sizes.sizeSm * 6,
                  width: MediaQuery.of(context).size.width,
                  child: songs.isEmpty 
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("No song uploaded", style: TextStyle(fontSize: Sizes.textMd)),
                        SizedBox(height: Sizes.defaultSpace / 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(image: AssetImage("assets/images/library.png")),
                            Text(" Go to library")
                          ],
                        )
                      ],
                    ),
                  ) 
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: Sizes.defaultSpace * 10,
                        // childAspectRatio: 1,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: songs.length,
                      // reverse: true,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        // Song Card
                        return GestureDetector(
                          onTap: () => ref
                              .watch(currentSongNotifierProvider.notifier)
                              .updateSong(song),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.spaceBtwItems),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Song Image
                                SongImage(song: song, height: Sizes.iconLg * 3),
                                const SizedBox(height: Sizes.spaceBtwItems),

                                // Song Name
                                SizedBox(
                                  width: Sizes.sizeLg,
                                  child: Text(
                                    song.song_name,
                                    style: const TextStyle(
                                        fontSize: Sizes.textSm,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Artist Name
                                SizedBox(
                                  width: Sizes.sizeLg,
                                  child: Text(
                                    song.artist,
                                    style: const TextStyle(
                                        fontSize: Sizes.textSm / 1.5,
                                        color: Pallete.subtitleText,
                                        fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: Sizes.spaceBtwItems),
                              ],
                            ),
                          ),
                        );
                      }),
                );
              },
              error: (error, st) {
                return Center(
                    heightFactor: Sizes.spaceBtwItems / 2,
                    child: Text("Oops! ${error.toString()}"));
              },
              loading: () => const CustomLoader()),
        ],
      ),
    );
  }
}
