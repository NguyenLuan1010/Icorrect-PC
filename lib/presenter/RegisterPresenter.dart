
import '../callbacks/AuthenticationCallBack.dart';

class RegisterPresenter {
  final String REGEX_EMAIL =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#\$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

  void execRegister(String email, String password, String confirmPassword,
      RegisterCallBack callBack) {
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      callBack.registerWarning('Please input field completely !');
      return;
    }

    if (!RegExp(REGEX_EMAIL).hasMatch(email)) {
      callBack.registerWarning('Email is invalid. Try again !');
      return;
    }
    
    if (password != confirmPassword) {
      callBack.registerWarning('Password and Confirm password does not match!');
      return;
    }
  }
}
