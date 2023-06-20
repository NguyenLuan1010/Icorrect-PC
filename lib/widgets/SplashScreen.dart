import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../data/locals/SharedRef.dart';
import '../models/others/Users.dart';
import '../theme/app_themes.dart';
import '../utils/Navigations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _checkUserCookies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildSplashScreen();
  }

  Widget _buildSplashScreen() {
    return Center(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              width: 300,
              image: AssetImage('assets/logo_app.png'),
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 50),
            CircularProgressIndicator(
              strokeWidth: 4,
              backgroundColor: AppThemes.colors.purpleSlight2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppThemes.colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _checkUserCookies() async {
    int daysSaveCookie = 25;
    Users? user = await SharedRef.instance().getUser();

    if (user != null && user.savedTime != null) {
      DateTime today = DateTime.now();
      DateTime savedTime = DateTime.parse(user.savedTime.toString());
      Duration timeRange = today.difference(savedTime);
      if (timeRange.inDays >= daysSaveCookie) {
        SharedRef.instance().setUser(null);
        SharedRef.instance().setAccessToken('');
      }
    }

    String token = await SharedRef.instance().getAccessToken();

    Future.delayed(const Duration(seconds: 1), () {
      if (user == null || user.email == null && token.isEmpty) {
        Navigations.instance().goToAuthWidget(context);
      } else {
        Navigations.instance().goToMainWidget(context);
      }
    });
  }
}
