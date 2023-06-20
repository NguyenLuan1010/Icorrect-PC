import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:path_provider/path_provider.dart';
import 'package:webview_cef/webview_cef.dart';

import '../../data/api/Repositories.dart';
import '../../presenter/LoginPresenter.dart';
import '../../theme/app_themes.dart';

class AIResponseWidget extends StatefulWidget {
  String url;
  AIResponseWidget({super.key, required this.url});

  @override
  State<AIResponseWidget> createState() => _AIResponseWidgetState();
}

class _AIResponseWidgetState extends State<AIResponseWidget>
 {
  final _controller = WebViewController();

  @override
  void reassemble() {
    super.reassemble();
    _controller.reload();
  }

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  Future<void> initPlatformState() async {
    await _controller.initialize();
    await _controller
        .loadUrl('${widget.url}&token=${await Repositories.init().getToken()}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 50),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
          color: AppThemes.colors.opacity,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2)),
      child: _controller.value
          ? Expanded(child: WebView(_controller))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 4,
                  backgroundColor: AppThemes.colors.purpleSlight2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppThemes.colors.purple,
                  ),
                ),
                const SizedBox(height: 10),
                Text("Please wait.....",
                    style: TextStyle(
                        color: AppThemes.colors.purple,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
              ],
            ),
    );
  }

}
