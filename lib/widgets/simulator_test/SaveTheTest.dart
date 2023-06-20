import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../callbacks/ViewMainCallBack.dart';
import '../../../cutoms/ButtonCustom.dart';
import '../../../models/test_simulator/QuestionTopic.dart';
import '../../../models/test_simulator/TestDetail.dart';
import '../../../presenter/TestDetailPresenter.dart';
import '../../../provider/VariableProvider.dart';
import '../../theme/app_themes.dart';

class SaveTheTest {
  static Widget saveTheTestWidget(String title, String description,
      String imgAsset, SaveTheTestAction listener) {
    return Consumer<VariableProvider>(builder: (context, appState, child) {
      return Visibility(
          visible: appState.isVisibleSaveTheTest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(image: AssetImage(imgAsset), width: 100),
              Text(title,
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
              const SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppThemes.colors.gray),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    listener.clickSaveTheTest();
                  },
                  style: ButtonCustom.init().buttonPurple20(),
                  child: const Text("Save the test"),
                ),
              )
            ],
          ));
    });
  }
}

abstract class SaveTheTestAction {
  void clickSaveTheTest();
}
