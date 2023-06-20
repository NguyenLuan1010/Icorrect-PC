import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../models/test_simulator/QuestionTopic.dart';
import '../../../provider/VariableProvider.dart';

class ShowCueCard {
  static Widget showCueCard(QuestionTopic? question) {
    return Consumer<VariableProvider>(builder: (context, appState, child) {
      return Visibility(
          visible: appState.isVisibleCueCard,
          child: Column(
            children: [
              const Text("Cue Card",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 10),
              Text(appState.strCount,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
              const SizedBox(height: 10),
              Text(question?.content ?? '',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black)),
              const SizedBox(height: 10),
              Text(question?.cue_card ?? '',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.black)),
            ],
          ));
    });
  }
}
