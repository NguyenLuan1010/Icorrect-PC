import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../models/test_simulator/QuestionTopic.dart';
import '../../../provider/VariableProvider.dart';
import '../../../theme/app_themes.dart';
import '../../dialog/ReanswerDialog.dart';
import '../../dialog/TipQuestionDialog.dart';
import '../../models/Enums.dart';

class TestQuestion {
  Widget testQuestionsWidget(
      BuildContext context, ReanswerActionListener listener) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        height: 300,
        margin: const EdgeInsets.only(top: 20),
        child: Center(child:
            Consumer<VariableProvider>(builder: (context, appState, child) {
          if (appState.questionsTest.isEmpty) {
            return const Center(
              child: Text(
                "Opps, Nothing questions in here. Please play question!",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
            );
          } else {
            return LayoutBuilder(builder: ((context, constraints) {
              if (constraints.maxWidth < SizeScreen.MINIMUM_WiDTH_2.size) {
                return ListView.builder(
                    itemCount: appState.questionsTest.length,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: const EdgeInsets.only(top: 15),
                        child: _testQuestionItem(context,
                            appState.questionsTest.elementAt(index), listener),
                      );
                    });
              } else {
                return GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 6,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  children: appState.questionsTest
                      .map(
                        (data) => _testQuestionItem(context, data, listener),
                      )
                      .toList(),
                );
              }
            }));
          }
        })),
      ),
    );
  }

  Widget _testQuestionItem(BuildContext context, QuestionTopic question,
      ReanswerActionListener listener) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
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
                      // Text("00:15' | 1 repeat times",
                      //     style: TextStyle(
                      //         color: AppThemes.colors.purpleSlight,
                      //         fontSize: 13)),
                      const SizedBox(width: 20),
                      Consumer<VariableProvider>(
                          builder: (context, appState, child) {
                        return Visibility(
                            visible: appState.isVisibleReanswer,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Future.delayed(Duration.zero, () async {
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return ReanswerDialog(
                                                context, question, listener);
                                          });
                                    });
                                  },
                                  child: const Text("Re-answer",
                                      style: TextStyle(
                                          color: Colors.green, fontSize: 15)),
                                ),
                                const SizedBox(width: 20),
                                InkWell(
                                  onTap: () {
                                    Future.delayed(Duration.zero, () async {
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
                                          color: Colors.amber, fontSize: 14)),
                                )
                              ],
                            ));
                      }),
                    ],
                  )
                ],
              )),
              const Image(image: AssetImage("assets/img_play.png"))
            ],
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey,
          )
        ],
      ),
    );
  }
}
