import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../../cutoms/ButtonCustom.dart';
import '../../theme/app_themes.dart';

class LoadingTestDialog {
  static Widget loadingTestDialog(BuildContext context, progress,
      String partOfTest, bool isVisible, ActionLoadingTest listener) {
    return Dialog(
      child: Container(
        width: 300,
        height: 300,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  margin: const EdgeInsets.all(0),
                  width: 150,
                  height: 150,
                  child: DashedCircularProgressBar.aspectRatio(
                    aspectRatio: 1,
                    progress: (progress * 100).roundToDouble(),
                    startAngle: 225,
                    sweepAngle: 270,
                    foregroundColor: AppThemes.colors.purple,
                    backgroundColor: const Color(0xffeeeeee),
                    foregroundStrokeWidth: 15,
                    backgroundStrokeWidth: 15,
                    animation: true,
                    seekSize: 6,
                    seekColor: const Color(0xffeeeeee),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${(progress * 100).roundToDouble()}%',
                              style: TextStyle(
                                  color: AppThemes.colors.purple,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 10),
              Text(
                partOfTest,
                style: TextStyle(
                    color: AppThemes.colors.purple,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              Visibility(
                  visible: isVisible,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        listener.onClickStartNow();
                      },
                      style: ButtonCustom.init().buttonPurple20(),
                      child: const Text("Start Now"),
                    ),
                  )),
              InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    listener.onClickBackToHome();
                  },
                  child: Text(
                    'Back to home',
                    style: TextStyle(
                        color: AppThemes.colors.purple,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

abstract class ActionLoadingTest {
  void onClickStartNow();
  void onClickBackToHome();
}
