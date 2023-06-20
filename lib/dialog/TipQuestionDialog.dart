import 'package:flutter/material.dart';

import '../../models/test_simulator/QuestionTopic.dart';
import '../../theme/app_themes.dart';
import '../models/Enums.dart';

class TipQuestionDialog {
  static Widget tipQuestionDialog(
      BuildContext context, QuestionTopic question) {
    ScrollController controller = ScrollController();
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Container(
          width: 500,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 50,
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.cancel_outlined),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Tip",
                      style: TextStyle(
                          color: AppThemes.colors.orangeDark,
                          fontSize: 25,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5),
                  Text(question.content.toString(),
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                        thickness: 1,
                        color: AppThemes.colors.gray,
                      )),
                  const SizedBox(height: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      question.numPart == PartOfTest.PART2.get
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('Cue Card',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Text(question.cue_card.toString(),
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16))
                              ],
                            )
                          : Container(),
                      const SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          question.numPart == PartOfTest.PART2.get
                              ? const Text('Another tips',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))
                              : Container(),
                          Text(
                              question.tips == null ||
                                      question.tips.toString().isEmpty
                                  ? "Nothing tip in here"
                                  : question.tips.toString(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16))
                        ],
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
