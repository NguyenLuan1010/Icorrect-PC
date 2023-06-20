import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/others/Users.dart';

class SharedRef {
  final PREF_COOKIES_USER = "COOKIES_USER";
  final PREF_ACCESS_TOKEN = "ACCESS_TOKEN";

  SharedRef._();
  static final SharedRef _cookies = SharedRef._();
  factory SharedRef.instance() => _cookies;

  Future<void> setUser(Users? user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(PREF_COOKIES_USER, jsonEncode(user ?? Users().toJson()));
  }

  Future<Users?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userJson = prefs.getString(PREF_COOKIES_USER) ?? '';
    if (userJson.isEmpty) {
      return null;
    }
    Map<String, dynamic> userMap = jsonDecode(userJson) ?? {};
    if (userMap.isEmpty) {
      return null;
    }
    return Users.fromJson(userMap);
  }

  Future<void> setAccessToken(String? accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(PREF_ACCESS_TOKEN, accessToken ?? '');
  }

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(PREF_ACCESS_TOKEN) ?? '';
  }
}
