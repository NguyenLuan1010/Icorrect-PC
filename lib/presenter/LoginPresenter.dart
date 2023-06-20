import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';


import '../data/api/APIHelper.dart';
import 'package:device_info/device_info.dart';

import '../data/api/Repositories.dart';
import '../data/locals/SharedRef.dart';
import '../models/Enums.dart';
import '../models/others/Users.dart';
import '../callbacks/AuthenticationCallBack.dart';
import '../models/ui/AlertInfo.dart';

class LoginPresenter {
  final String REGEX_EMAIL =
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#\$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

  AlertInfo alertServerError = AlertInfo(
      'Login Fail',
      'Something went wrong. Please contact with admin to support!',
      Alert.SERVER_ERROR.type);

  AlertInfo alertNetWorkError = AlertInfo('Login Fail',
      'Please check your internet and try again !', Alert.NETWORK_ERROR.type);

  Future<void> execLogin(
      String email, String password, LoginCallBack callBack) async {
    if (email.isEmpty || password.isEmpty) {
      callBack.loginWarning("Please input data completely !");
      return;
    }
    if (!RegExp(REGEX_EMAIL).hasMatch(email)) {
      callBack.loginWarning("Invalid email .Please try again !");
      return;
    }

    String url = APIHelper.init().apiLogin();
    try {
      Response response = await Repositories.init().sendRequest(
          APIHelper.POST, url, false, body: <String, String>{
        'email': email,
        'password': password
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode != APIHelper.RESPONSE_OK) {
        AlertInfo alertInfo = AlertInfo(
            'Login Fail',
            'Please check your internet and try again !',
            Alert.NETWORK_ERROR.type);
        callBack.loginFail(alertInfo);
        return;
      }

      Map<String, dynamic> dataMap = json.decode(response.body);

      if (dataMap.isNotEmpty) {
        String status = dataMap['status'] as String;

        if (status == "success") {
          await SharedRef.instance().setAccessToken(_getAccessToken(dataMap));
          Users user = await _getUser(dataMap);
          if (user == Users()) {
            callBack.loginWarning("An error occur when get user info !");
          } else {
            callBack.loginSuccess(
                user, _getAccessToken(dataMap), "Login successfully !");
          }
        } else {
          callBack.loginWarning("Email or password was wrong !");
        }
      } else {
        callBack.loginFail(alertServerError);
      }
    } on TimeoutException {
      callBack.loginFail(alertNetWorkError);
    } on SocketException {
      callBack.loginFail(alertNetWorkError);
    } on ClientException {
      callBack.loginFail(alertNetWorkError);
    }
  }

  Future<Users> _getUser(Map<String, dynamic> jsonResponse) async {
    String url = APIHelper.init().apiUserInfo();
    Response response = await Repositories.init().sendRequest(
        APIHelper.POST, url, true, body: <String, dynamic>{
      'device_id': await _getDeviceId(),
      'app_version': "2.0.2",
      'os': _getDeviceOS()
    }).timeout(const Duration(seconds: 10));

    Map<String, dynamic> dataMap = json.decode(response.body);

    Users user = Users();

    if (dataMap.isNotEmpty) {
      user = Users.userInfo(dataMap['data']);
    }
    return user;
  }

  Future<String> _getDeviceId() async {
    String deviceId = "7b818ae27d259278";

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      deviceId = androidDeviceInfo.androidId;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      deviceId = iosDeviceInfo.identifierForVendor;
    }

    return deviceId;
  }

  String _getDeviceOS() {
    if (Platform.isAndroid) {
      return "android";
    } else {
      return "ios";
    }
  }

  String _getAccessToken(Map<String, dynamic> jsonResponse) {
    return jsonResponse['data']['access_token'];
  }
}

//   import 'package:http/http.dart' as http;

// int timeout = 5;
// try {
//   http.Response response = await http.get('someUrl').
//       timeout(Duration(seconds: timeout));
//   if (response.statusCode == 200) {
//     // do something
//   } else {
//     // handle it
//   }
// } on TimeoutException catch (e) {
//   print('Timeout Error: $e');
// } on SocketException catch (e) {
//   print('Socket Error: $e');
// } on Error catch (e) {
//   print('General Error: $e');
// }
