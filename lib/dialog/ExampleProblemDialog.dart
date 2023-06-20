import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../data/api/APIHelper.dart';
import '../models/my_test/SkillProblem.dart';
import '../provider/VariableProvider.dart';
import '../theme/app_themes.dart';

class ExampleProblemDialog {
  static VideoPlayerController playerController =
      VideoPlayerController.network('');

  Widget showDialog(BuildContext context, SkillProblem skillProblem) {
    AudioPlayer audioPlayer = AudioPlayer();

    audioPlayer.onPlayerComplete.listen((event) {
      _setVisiblePlay(context, true);
    });
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
          child: Container(
        width: 500,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: double.infinity,
              height: 40,
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  _setVisiblePlay(context, true);
                  if (playerController.value.isPlaying) {
                    playerController.pause();
                  }
                  playerController.dispose();

                  audioPlayer.stop();
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.cancel_outlined),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Example",
                    style: TextStyle(
                        color: AppThemes.colors.orangeDark,
                        fontSize: 25,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("You should say : ",
                                style: TextStyle(
                                    color: AppThemes.colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                            Text(skillProblem.exampleText,
                                style: TextStyle(
                                    color: AppThemes.colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _isVideoFile(skillProblem.fileName)
                            ? _buildVideoWidget(skillProblem)
                            : _buildAudioWidget(audioPlayer, skillProblem),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildVideoWidget(SkillProblem skillProblem) {
    String url = APIHelper.init().apiFile(skillProblem.fileName);
    playerController = VideoPlayerController.network(url)..initialize();

    playerController.play();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Video Example : ",
            style: TextStyle(
                color: AppThemes.colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        SizedBox(
            width: double.infinity,
            height: 150,
            child: AspectRatio(
              aspectRatio: playerController.value.aspectRatio,
              child: VideoPlayer(playerController),
            ))
      ],
    );
  }

  Widget _buildAudioWidget(AudioPlayer audioPlayer, SkillProblem skillProblem) {
    return Row(
      children: [
        Text("Audio Example : ",
            style: TextStyle(
                color: AppThemes.colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
        const SizedBox(width: 10),
        Consumer<VariableProvider>(builder: (context, appState, child) {
          return (appState.playAudioExample)
              ? InkWell(
                  onTap: () async {
                    _setVisiblePlay(context, false);
                    _playAudio(audioPlayer, skillProblem.fileName);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(5)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('Click To Play',
                          style: TextStyle(color: Colors.green, fontSize: 13)),
                    ),
                  ),
                )
              : InkWell(
                  onTap: () async {
                    _setVisiblePlay(context, true);
                    audioPlayer.stop();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(5)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('Stop',
                          style: TextStyle(color: Colors.red, fontSize: 13)),
                    ),
                  ),
                );
        }),
      ],
    );
  }

  bool _isVideoFile(String fileName) {
    final type = fileName.split('.');
    return type.last == 'mp4';
  }

  void _playAudio(AudioPlayer audioPlayer, String fileName) {
    String url = APIHelper.init().apiFile(fileName);

    audioPlayer.play(UrlSource(url));
    audioPlayer.setVolume(2.5);
  }

  void _setVisiblePlay(BuildContext context, bool visible) {
    Provider.of<VariableProvider>(context, listen: false)
        .setPlayAudioExample(visible);
  }
}
