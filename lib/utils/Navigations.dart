import 'package:flutter/material.dart';

import '../widgets/AuthWidget.dart';
import '../widgets/MainWidget.dart';

class Navigations {
  Navigations._();
  static final Navigations _navigation = Navigations._();
  factory Navigations.instance() => _navigation;

  void goToAuthWidget(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AuthWidget()));
  }

  void goToMainWidget(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MainWidget()));
  }

  // void goToLogin(BuildContext context) {
  //   Navigator.push(
  //       context, MaterialPageRoute(builder: (context) => const LoginWidget()));
  // }

  // void goToRegister(BuildContext context) {
  //   Navigator.push(context,
  //       MaterialPageRoute(builder: (context) => const RegisterWidget()));
  // }

  // void goToForgotPassword(BuildContext context) {
  //   Navigator.push(context,
  //       MaterialPageRoute(builder: (context) => const FotgotPasswordWidget()));
  // }

  // void goToMainWidget(BuildContext context) {
  //   Navigator.push(
  //       context, MaterialPageRoute(builder: (context) => const MainWidget()));
  // }

  // void goToTopicDetailWidget(BuildContext context, HomeWorks homeWork) {
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => TopicDetailWidget(homework: homeWork)));
  // }
}
