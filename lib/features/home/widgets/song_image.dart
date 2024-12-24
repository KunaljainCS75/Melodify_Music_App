import 'package:client/core/constants/size_constant.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:flutter/material.dart';

class SongImage extends StatelessWidget {
  const SongImage({
    super.key,
    required this.song,
    this.height = Sizes.sizeLg,
    this.width = Sizes.sizeLg,
    this.borderRadius = Sizes.radiusSm,
    this.boxfit = BoxFit.cover
  });

  final SongModel song;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit boxfit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(song.thumbnail_url),
          fit: boxfit,
        ),
        borderRadius: BorderRadius.circular(borderRadius)
      ),
    );
  }
}