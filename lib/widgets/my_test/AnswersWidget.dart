import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'package:provider/provider.dart';

import '../../data/locals/DeviceStorage.dart';
import '../../data/locals/LocalStorage.dart';
import '../../dialog/ReanswerDialog.dart';
import '../../dialog/TipQuestionDialog.dart';
import '../../models/Enums.dart';
import '../../models/test_simulator/FileTopic.dart';
import '../../models/test_simulator/QuestionTopic.dart';
import '../../provider/VariableProvider.dart';
import '../../theme/app_themes.dart';

class AnswersWidget {
  static Widget buildRecordedAnswers(
      BuildContext context,
      bool isAIScore,
      List<QuestionTopic> questions,
      ReanswerActionListener listener,
      PlayAudioListener audioListener) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        height: 300,
        margin: const EdgeInsets.only(top: 20),
        child: LayoutBuilder(builder: ((context, constraints) {
          if (constraints.maxWidth < SizeScreen.MINIMUM_WiDTH_2.size) {
            return ListView.builder(
                itemCount: questions.length,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: _testQuestionItem(context, isAIScore,
                        questions.elementAt(index), listener, audioListener),
                  );
                });
          } else {
            return Center(
                child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 1,
              mainAxisSpacing: 2,
              childAspectRatio: 6,
              children: questions
                  .map(
                    (data) => _testQuestionItem(
                        context, isAIScore, data, listener, audioListener),
                  )
                  .toList(),
            ));
          }
        })),
      ),
    );
  }

  static Widget _testQuestionItem(
      BuildContext context,
      bool isAIScore,
      QuestionTopic question,
      ReanswerActionListener listener,
      PlayAudioListener audioListener) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      question.content.toString(),
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                            "${_repeatTimes(question.answers ?? [])} repeat times",
                            style: TextStyle(
                                color: AppThemes.colors.purple, fontSize: 15)),
                        const SizedBox(width: 20),
                        Consumer<VariableProvider>(
                            builder: (context, appState, child) {
                          return Visibility(
                              visible: appState.isVisibleReanswer,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  (isAIScore)
                                      ? Container()
                                      : InkWell(
                                          onTap: () {
                                            Future.delayed(Duration.zero,
                                                () async {
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) {
                                                    return ReanswerDialog(
                                                        context,
                                                        question,
                                                        listener);
                                                  });
                                            });
                                          },
                                          child: const Text("Re-answer",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 15)),
                                        ),
                                  const SizedBox(width: 20),
                                  question.tips.toString().isEmpty &&
                                          question.cue_card.toString().isEmpty
                                      ? Container()
                                      : InkWell(
                                          onTap: () {
                                            Future.delayed(Duration.zero,
                                                () async {
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) {
                                                    return TipQuestionDialog
                                                        .tipQuestionDialog(
                                                            context, question);
                                                  });
                                            });
                                          },
                                          child: const Text("View tips",
                                              style: TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 14)),
                                        )
                                ],
                              ));
                        }),
                      ],
                    )
                  ],
                )),
                Consumer<VariableProvider>(builder: (context, appState, child) {
                  if (appState.playAnswer &&
                      question.id == appState.questionId) {
                    return InkWell(
                        onTap: () async {
                          Provider.of<VariableProvider>(context, listen: false)
                              .setPlayAnswer(false, question.id);

                          audioListener.onPauseAudio();
                        },
                        child: const Image(
                            image: AssetImage("assets/img_pause.png")));
                  } else {
                    return InkWell(
                        onTap: () async {
                          Provider.of<VariableProvider>(context, listen: false)
                              .setPlayAnswer(true, question.id.toString());
                          if (question.answers != null &&
                              question.answers!.isNotEmpty) {
                            audioListener.onPlayAudio(
                                _audioPathFile((question.answers!.last)),
                                question.id.toString());
                          }
                        },
                        child: const Image(
                            image: AssetImage("assets/img_play.png")));
                  }
                })
              ],
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey,
            )
          ],
        ));
  }
}

String _audioPathFile(FileTopic answer) {
  return '${DeviceStorage.AUDIO}\\${basename(DeviceStorage.init().nameFileConvert(answer.getUrl.toString()))}';
}

int _repeatTimes(List<FileTopic> answer) {
  if (answer.length - 1 < 0) {
    return 0;
  }
  return answer.length - 1;
}

abstract class PlayAudioListener {
  void onPlayAudio(String audioPath, String questionId);
  void onPauseAudio();
}
