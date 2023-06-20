import 'package:flutter/material.dart';


import '../models/Enums.dart';
import '../models/ui/AlertInfo.dart';
import '../theme/app_themes.dart';

class AlertsDialog {
  AlertsDialog._();
  static final AlertsDialog _alertDialog = AlertsDialog._();
  factory AlertsDialog.init() => _alertDialog;

  Widget showDialog(
      BuildContext context, AlertInfo info, ActionAlertListener listener,
      {String? keyInfo}) {
    Map<String, String> alertTypeMap = info.typeAlert;
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 450,
        height: 300,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  // Navigator.of(context).pop();
                  // listener.onAlertExit(keyInfo ?? '');
                },
                child: const Icon(Icons.cancel_outlined),
              ),
            ),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  Image(
                    image: AssetImage(alertTypeMap[Alert.icon].toString()),
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 10),
                  Text(info.title.toString(),
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(info.description.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color:  Color.fromARGB(255, 98, 97, 97),
                          fontSize: 16,
                          fontWeight: FontWeight.w400)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            listener.onAlertExit(keyInfo ?? '');
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  AppThemes.colors.gray),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)))),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                  alertTypeMap[Alert.cancelTitle].toString())),
                        ),
                      )),
                      Expanded(
                          child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            listener.onAlertNextStep(keyInfo ?? "");
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  AppThemes.colors.purple),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)))),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                  alertTypeMap[Alert.actionTitle].toString())),
                        ),
                      )),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

abstract class ActionAlertListener {
  void onAlertExit(String keyInfo);
  void onAlertNextStep(String keyInfo);
}
