import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:client/core/constants/size_constant.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AudioWaves extends StatefulWidget {

  final String path;
  const AudioWaves({
    super.key,
    required this.path  
  });

  @override
  State<AudioWaves> createState() => _AudioWavesState();
}

class _AudioWavesState extends State<AudioWaves> {
  final playerController = PlayerController();

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }
  void initAudioPlayer() async {
    await playerController.preparePlayer(path: widget.path);
  }

  Future<void> playAndPause() async {
    if (!playerController.playerState.isPlaying){
      await playerController.startPlayer();
    } else if (!playerController.playerState.isPaused){
      await playerController.pausePlayer();
    } 
    setState(() {
      
    });
  }

  @override
  void dispose() {
    super.dispose();
    playerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: playAndPause,
          icon: Icon(
            playerController.playerState.isPlaying 
            ? CupertinoIcons.pause_solid
            : CupertinoIcons.play_arrow_solid)),
        Expanded(
          child: AudioFileWaveforms(
            size: const Size(double.infinity, Sizes.defaultSpace * 4), 
            playerController: playerController,
            playerWaveStyle: const PlayerWaveStyle(
              fixedWaveColor: Pallete.borderColor,
              liveWaveColor: Pallete.gradient2,
              spacing: 6,
              showSeekLine: false,
            ),
            // waveformType: WaveformType.fitWidth
          ),
        ),
      ],
    );
  }
}