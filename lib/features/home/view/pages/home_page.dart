// import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/view/pages/library_page.dart';
import 'package:client/features/home/view/pages/song_page.dart';
import 'package:client/features/home/widgets/music_slab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  // helps to maintain index of tabs
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int selectedIndex = 0;
  final pages = [
    const SongsPage(),
    const LibraryPage()
  ];

  @override
  Widget build(BuildContext context) {
    // final user = ref.watch(currentUserNotifierProvider);
    // print(user);
    return Scaffold(
      body: Stack(
        children: [
          pages[selectedIndex],
          const Positioned(
            bottom: 0,
            child: MusicSlab(),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                  selectedIndex == 0
                      ? Icons.music_note
                      : Icons.music_note_outlined,
                  color: selectedIndex == 0
                      ? Pallete.whiteColor
                      : const Color.fromRGBO(171, 171, 171, 1)),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_add,
                  color: selectedIndex == 1
                      ? Pallete.whiteColor
                      : Pallete.inactiveBottomBarItemColor),
              label: 'Library'),
        ],
      ),
    );
  }
}
