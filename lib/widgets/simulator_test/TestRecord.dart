import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../callbacks/ViewMainCallBack.dart';
import '../../../provider/VariableProvider.dart';
import '../../../theme/app_themes.dart';

class TestRecord {
  static Widget recordAnswer(bool visible, ActionRecordListener listener) {
    return Visibility(
        visible: visible,
        child:  Column(
            children: [
              const Text('Your answers are being recorded',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              const Image(image: AssetImage("assets/img_mic.png")),
              const SizedBox(height: 10),
              Consumer<VariableProvider>(builder: (context, appState, child) {
                return Text(appState.strCount,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 38,
                        fontWeight: FontWeight.w600));
              }),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            listener.clickEndQuestion();
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.green),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)))),
                          child: const Text("Finish"),
                        ),
                      )),
                  Flexible(
                      flex: 1,
                      child: Consumer<VariableProvider>(
                          builder: (context, appState, child) {
                        return Visibility(
                            visible: appState.isRepeatVisible,
                            child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                height: 40,
                                child: Consumer<VariableProvider>(
                                    builder: (context, appState, child) {
                                  return ElevatedButton(
                                    onPressed: () {
                                      listener.clickRepeat();
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                AppThemes.colors.purple),
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5)))),
                                    child: const Text("Repeat"),
                                  );
                                })));
                      }))
                ],
              )
            ],
          ),
        );
  }
}
