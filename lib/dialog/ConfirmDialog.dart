import 'package:flutter/material.dart';

import '../theme/app_themes.dart';

class ConfirmDialog {
  ConfirmDialog._();
  static final ConfirmDialog _confirmDialog = ConfirmDialog._();
  factory ConfirmDialog.init() => _confirmDialog;
  Widget showDialog(BuildContext context, String title, String message,
      ConfirmDialogAction listener) {
    return Dialog(
        elevation: 0,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
            width: 300,
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
                Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Text(
                      textAlign: TextAlign.center,
                      message,
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    )),
                Divider(
                  color: AppThemes.colors.gray,
                  height: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              listener.onClickCancel();
                            },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0),
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.center),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  color: AppThemes.colors.gray,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ))),
                    const VerticalDivider(
                      width: 3.0,
                      color: Colors.black38,
                    ),
                    Expanded(
                        child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              listener.onClickOK();
                            },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0),
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.center),
                            child: Text(
                              "OK",
                              style: TextStyle(
                                  color: AppThemes.colors.purple,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ))),
                  ],
                ),
              ],
            )));
  }
}

abstract class ConfirmDialogAction {
  void onClickCancel();
  void onClickOK();
}
