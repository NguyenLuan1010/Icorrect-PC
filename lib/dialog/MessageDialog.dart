import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_themes.dart';

class MessageDialog {
  static Widget alertDialog(BuildContext context,  String message) {
    return  Dialog(
            elevation: 0,
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: SizedBox(
                width: 300,
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text("Notify",
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Text(
                          textAlign: TextAlign.center,
                          message,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 15),
                        )),
                    Divider(
                      color: AppThemes.colors.gray,
                      height: 1,
                    ),
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0),
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.center),
                        child: Text(
                          "OK",
                          style: TextStyle(
                              color: AppThemes.colors.purple,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        )),
                  ],
                )));
  }
}
