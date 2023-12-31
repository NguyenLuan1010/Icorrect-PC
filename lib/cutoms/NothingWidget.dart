import 'package:flutter/material.dart';

import '../theme/app_themes.dart';

class NothingWidget {
  NothingWidget._();
  static final NothingWidget _widget = NothingWidget._();
  factory NothingWidget.init() => _widget;

  Widget buildNothingWidget(String message,
      {required double? widthSize, required double? heightSize}) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: widthSize,
            height: heightSize,
            child: const Image(
              image: AssetImage("assets/img_empty.png"),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
                color: AppThemes.colors.gray,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
