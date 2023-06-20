import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../provider/VariableProvider.dart';
import '../../../theme/app_themes.dart';

class TestPlayer {
   Widget videoPlayer() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              Consumer<VariableProvider>(builder: (context, appState, child) {
                return appState.playController.value.isInitialized
                    ? Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 400,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(130)),
                              child: AspectRatio(
                                aspectRatio:
                                    appState.playController.value.aspectRatio,
                                child: VideoPlayer(appState.playController),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Card(
                          child: Container(
                            alignment: Alignment.center,
                            width: 400,
                            height: 230,
                            padding: EdgeInsets.zero,
                            child: Text(
                              'Loading Video...',
                              style: TextStyle(
                                  color: AppThemes.colors.purpleBlue,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ));
              }),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: const Image(
                  image: AssetImage("assets/ic_paste.png"),
                  alignment: Alignment.topLeft,
                ),
              )
            ],
          ),
          // Container(
          //   margin: const EdgeInsets.only(top: 5),
          //   width: 400,
          //   decoration: BoxDecoration(
          //       borderRadius: const BorderRadius.all(Radius.circular(10)),
          //       border: Border.all(color: Colors.grey, width: 1)),
          //   child: LinearProgressIndicator(
          //     minHeight: 7,
          //     valueColor:
          //         AlwaysStoppedAnimation<Color>(AppThemes.colors.progressBar),
          //     backgroundColor: Colors.white,
          //     value: 0.2,
          //   ),
          // ),
          // const SizedBox(height: 10),
          // const Text(
          //   "Cau 2/ 10 ",
          //   style: TextStyle(
          //       color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          //   textAlign: TextAlign.center,
          // )
        ],
      )
    );
  }
}
