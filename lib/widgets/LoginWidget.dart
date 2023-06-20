import 'package:flutter/material.dart';


import 'package:provider/provider.dart';

import '../callbacks/AuthenticationCallBack.dart';
import '../cutoms/InputFieldCustom.dart';
import '../data/locals/SharedRef.dart';
import '../dialog/AlertDialog.dart';
import '../dialog/CircleLoading.dart';
import '../dialog/MessageDialog.dart';
import '../models/Enums.dart';
import '../models/others/Users.dart';
import '../models/ui/AlertInfo.dart';
import '../presenter/LoginPresenter.dart';
import '../provider/VariableProvider.dart';
import '../theme/app_themes.dart';
import '../utils/Navigations.dart';
import 'ForgotPasswordWidget.dart';
import 'RegisterWidget.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginState();
}

class _LoginState extends State<LoginWidget>
    implements LoginCallBack, ActionAlertListener {
  CircleLoading? _loading;

  final _txtEmailController = TextEditingController();
  final _txtPasswordController = TextEditingController();
  bool _passVisibility = true;

  @override
  void initState() {
    super.initState();
    _loading = CircleLoading();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      if (constraint.maxWidth < SizeScreen.MINIMUM_WiDTH_1.size) {
        return _buildLoginFormMobile();
      } else {
        return _buildLoginFormDesktop();
      }
    });
  }

  Widget _buildLoginFormMobile() {
    return Center(
      child: Container(
        width: 700,
        height: 400,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        margin: const EdgeInsets.only(bottom: 100),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: AppThemes.colors.gray),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildEmailField(),
            const SizedBox(height: 15),
            _buildPasswordField(),
            const SizedBox(height: 15),
            _buildLinkText(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _loading?.show(context);
                _onPressLogin();
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(AppThemes.colors.purple),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)))),
              child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text("Sign In")),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoginFormDesktop() {
    return Center(
      child: Container(
        width: 700,
        height: 400,
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 30),
        margin: const EdgeInsets.only(bottom: 100),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: AppThemes.colors.gray),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildEmailField(),
            const SizedBox(height: 15),
            _buildPasswordField(),
            const SizedBox(height: 15),
            _buildLinkText(),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _loading?.show(context);
                _onPressLogin();
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(AppThemes.colors.purple),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)))),
              child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text("Sign In")),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email',
            style: TextStyle(
                color: AppThemes.colors.purple,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: _txtEmailController,
          decoration:
              InputFieldCustom.init().borderGray10('VD: hocvien@gmail.com'),
        )
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password',
            style: TextStyle(
                color: AppThemes.colors.purple,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          key: const Key('password-input'),
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.visiblePassword,
          obscureText: _passVisibility,
          controller: _txtPasswordController,
          decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 15),
              // prefixIcon: Padding(
              //     padding: const EdgeInsets.only(left: 18, right: 12),
              //     child: Icon(iconData, color: AppThemes.colors.purple)),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.deepPurple,
                  width: 1,
                ),
              ),
              suffixIcon: IconButton(
                icon: _passVisibility
                    ? const Icon(Icons.visibility_off)
                    : const Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    _passVisibility = !_passVisibility;
                  });
                },
              )),
        )
      ],
    );
  }

  Widget _buildLinkText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'You don not have an account',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                Provider.of<VariableProvider>(context, listen: false)
                    .setCurrentAuthWidget(const RegisterWidget());
              },
              child: const Text(
                'Register',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
            )
          ],
        ),
        InkWell(
          onTap: () {
            Provider.of<VariableProvider>(context, listen: false)
                .setCurrentAuthWidget(const ForgotPasswordWidget());
          },
          child: const Text(
            'Forgot password ?',
            style: TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.black,
                fontSize: 13,
                fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }

  void _onPressLogin() {
    String email = _txtEmailController.text;
    String password = _txtPasswordController.text;

    var presenter = LoginPresenter();
    presenter.execLogin(email, password, this);
  }

  @override
  void loginFail(AlertInfo info) {
    _loading?.hide();
    showDialog(
        context: context,
        builder: (context) {
          return AlertsDialog.init().showDialog(context, info, this);
        });
  }

  @override
  void onAlertExit(String keyInfo) {}

  @override
  void onAlertNextStep(String keyInfo) {
    _onPressLogin();
  }

  @override
  void loginSuccess(Users user, String token, String message) {
    _loading?.hide();

    DateTime today = DateTime.now();
    user.savedTime = today.toString();

    SharedRef.instance().setUser(user);
    Navigations.instance().goToMainWidget(context);
  }

  @override
  void loginWarning(String message) {
    _loading?.hide();
    showDialog(
        context: context,
        builder: (context) {
          return MessageDialog.alertDialog(context, message);
        });
  }
}
