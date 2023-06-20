import 'package:flutter/material.dart';


import 'package:provider/provider.dart';

import '../data/api/APIHelper.dart';
import '../data/locals/SharedRef.dart';
import '../dialog/AlertDialog.dart';
import '../dialog/ConfirmDialog.dart';
import '../models/Enums.dart';
import '../models/others/Users.dart';
import '../models/ui/AlertInfo.dart';
import '../provider/VariableProvider.dart';
import '../utils/Navigations.dart';
import 'HomeWorksWidget.dart';
import 'PracticesWidget.dart';
import 'simulator_test/DoingTest.dart';

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget>
    implements ConfirmDialogAction, ActionAlertListener {
  var HOMEWORK_ACTION_TAB = 'HOMEWORK_ACTION_TAB';
  var PRACTICE_ACTION_TAB = 'PRACTICE_ACTION_TAB';
  var LOGOUT_ACTION_TAB = 'LOGOUT_ACTION_TAB';

  late VariableProvider _provider;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<VariableProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    _provider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/bg_main.png"), fit: BoxFit.fill),
          ),
          child: _mainItem(),
        ),
      ),
    );
  }

  Widget _mainItem() {
    return Padding(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Column(
          children: [_mainHeader(), _body()],
        ));
  }

  Widget _mainHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Image(width: 170, image: AssetImage('assets/logo_app.png')),
              Consumer<VariableProvider>(builder: (context, appState, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        if (appState.currentMainWidget.runtimeType ==
                            DoingTest) {
                          whenOutTheTest(HOMEWORK_ACTION_TAB);
                        } else {
                          _provider.resetTestSimulatorValue();
                          _provider
                              .setCurrentMainWidget(const HomeWorksWidget());
                        }
                      },
                      child: const Text('Homeworks',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 30),
                    InkWell(
                      onTap: () {
                        if (appState.currentMainWidget.runtimeType ==
                            DoingTest) {
                          whenOutTheTest(PRACTICE_ACTION_TAB);
                        } else {
                          _provider.resetTestSimulatorValue();
                          _provider
                              .setCurrentMainWidget(const PracticesWidget());
                        }
                      },
                      child: const Text('Practices',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 30),
                    (appState.currentMainWidget.runtimeType ==
                                HomeWorksWidget ||
                            appState.currentMainWidget.runtimeType ==
                                PracticesWidget)
                        ? InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ConfirmDialog.init().showDialog(
                                        context,
                                        'Confirm to logout',
                                        'Are you sure for logout ?',
                                        this);
                                  });
                            },
                            child: const Text('Logout',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500)),
                          )
                        : Container(),
                    const SizedBox(width: 30),
                    FutureBuilder(
                        future: _getUser(),
                        builder: (BuildContext context,
                            AsyncSnapshot<Users?> snapshot) {
                          return _getCircleAvatar(snapshot.data);
                        })
                  ],
                );
              })
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: const Divider(
            height: 1,
            thickness: 1,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Future<Users?> _getUser() async {
    return await SharedRef.instance().getUser();
  }

  static Widget _getCircleAvatar(Users? user) {
    String strAvatar =
        (user != null && user != Users()) ? user.avatar ?? '' : '';
    if (strAvatar.contains("default-avatar") || strAvatar.isEmpty) {
      return const CircleAvatar(
        radius: 18,
        backgroundImage: AssetImage("assets/default_avatar.png"),
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundImage: NetworkImage(APIHelper.API_DOMAIN + strAvatar),
    );
  }

  Widget _body() {
    return Consumer<VariableProvider>(
        builder: (context, appState, child) =>
            Expanded(flex: 1, child: appState.currentMainWidget));
  }

  void whenOutTheTest(String keyInfo) {
    AlertInfo info = AlertInfo(
        'Warning',
        'Are you sure to out this test? Your test won\'t be saved !',
        Alert.WARNING.type);
    showDialog(
        context: context,
        builder: (context) {
          return AlertsDialog.init()
              .showDialog(context, info, this, keyInfo: keyInfo);
        });
  }

  @override
  void onClickCancel() {}

  @override
  void onClickOK() {
    Navigations.instance().goToAuthWidget(context);
    SharedRef.instance().setUser(null);
    SharedRef.instance().setAccessToken('');
  }

  @override
  void onAlertExit(String keyInfo) {}

  @override
  void onAlertNextStep(String keyInfo) {
    switch (keyInfo) {
      case 'HOMEWORK_ACTION_TAB':
        if (mounted) {
          _provider.stopVideoController();
          _provider.resetTestSimulatorValue();
          _provider.setCurrentMainWidget(const HomeWorksWidget());
        }
        break;
      case 'PRACTICE_ACTION_TAB':
        _provider.stopVideoController();
        _provider.resetTestSimulatorValue();
        break;
    }
  }
}
