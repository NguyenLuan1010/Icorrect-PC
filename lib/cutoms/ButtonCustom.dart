import 'package:flutter/material.dart';

import '../theme/app_themes.dart';

class ButtonCustom {
  ButtonCustom._();
  static final ButtonCustom _buttonCustom = ButtonCustom._();
  factory ButtonCustom.init() => _buttonCustom;

  ButtonStyle buttonPurple20() {
    return ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(AppThemes.colors.purple),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
  }

  ButtonStyle buttonBlue20() {
    return ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(AppThemes.colors.facebook),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
  }

  ButtonStyle buttonWhite20() {
    return ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all<Color>(AppThemes.colors.white),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
  }
}
