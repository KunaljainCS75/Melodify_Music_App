import 'package:client/core/constants/size_constant.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/view/pages/upload_song_page.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   return ref.watch(getAllFavSongsProvider).when(
      data: (data) => ListView.builder(
        itemCount: data.length + 1,
        itemBuilder: (context, index) {

          /// Upload song 
          if (index == 0){
            return ListTile(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UploadSongPage())),
              leading: const CircleAvatar(
                radius: Sizes.radiusLg,
                backgroundColor: Pallete.backgroundColor,
                child: Icon(CupertinoIcons.plus_circle_fill),
              ),
              title: const Text(
                    "Upload new song", 
                    style: TextStyle(fontSize: Sizes.textMd / 1.2, fontWeight: FontWeight.w700)
              ),
            ); 
          }

          /// Favourite Songs
          final song = data[index - 1];
          return ListTile(
            onTap: () => ref.read(currentSongNotifierProvider.notifier).updateSong(song),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(song.thumbnail_url),
              radius: Sizes.radiusLg,
              backgroundColor: Pallete.backgroundColor,
            ),
            title: Text(
                  song.song_name, 
                  style: const TextStyle(color: Colors.yellow, fontSize: Sizes.textMd / 1.2, fontWeight: FontWeight.w700)
            ),
            subtitle:  Text(
                  song.artist, 
                  style: const TextStyle(fontSize: Sizes.textSm / 1.2, fontWeight: FontWeight.w500)
            ),
          );
        },
      ) , 
      error: (error, st) => Center(child: Text(error.toString())), 
      loading: () => const CustomLoader()
    );
  }
}