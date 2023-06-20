import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:provider/provider.dart';

import '../cutoms/InputFieldCustom.dart';
import '../models/Enums.dart';
import '../provider/VariableProvider.dart';
import '../theme/app_themes.dart';
import 'LoginWidget.dart';

class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({super.key});

  @override
  State<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  final _txtEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: ((context, constraints) {
      if (constraints.maxWidth < SizeScreen.MINIMUM_WiDTH_2.size) {
        return _buildForgotPasswordFormMobile();
      } else {
        return _buildForgotPasswordFormDesktop();
      }
    }));
  }

  Widget _buildForgotPasswordFormMobile() {
    return Center(
      child: Container(
        width: 700,
        height: 300,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        margin: const EdgeInsets.only(bottom: 100),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: AppThemes.colors.gray),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Please input your email to recover password !',
              style: TextStyle(
                  color: AppThemes.colors.gray,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            _buildEmailField(),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(AppThemes.colors.purple),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)))),
              child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text("Send Verify Code")),
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                Provider.of<VariableProvider>(context, listen: false)
                    .setCurrentAuthWidget(const LoginWidget());
              },
              child: Text(
                'Back',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: AppThemes.colors.purple,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordFormDesktop() {
    return Center(
      child: Container(
        width: 700,
        height: 300,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 30),
        margin: const EdgeInsets.only(bottom: 100),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: AppThemes.colors.gray),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Please input your email to recover password !',
              style: TextStyle(
                  color: AppThemes.colors.gray,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            _buildEmailField(),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(AppThemes.colors.purple),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)))),
              child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text("Send Verify Code")),
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                Provider.of<VariableProvider>(context, listen: false)
                    .setCurrentAuthWidget(const LoginWidget());
              },
              child: Text(
                'Back',
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: AppThemes.colors.purple,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
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
}
