import 'dart:async';
import 'package:record/record.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../models/test_simulator/QuestionTopic.dart';
import '../../provider/VariableProvider.dart';
import '../callbacks/ViewMainCallBack.dart';
import '../data/locals/DeviceStorage.dart';
import '../presenter/TestDetailPresenter.dart';

class ReanswerDialog extends Dialog implements CountDownListener {
  BuildContext _context;
  ReanswerActionListener _listener;
  QuestionTopic _question;
  Timer? _countDown;
  final _timeRecord = 30;
  late Record _record;
  static String _pathFile = '';

  ReanswerDialog(this._context, this._question, this._listener, {super.key});

  @override
  double? get elevation => 0;

  @override
  Color? get backgroundColor => Colors.white;
  @override
  ShapeBorder? get shape =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

  @override
  Widget? get child => _buildDialog();

  Widget _buildDialog() {
    _record = Record();
    _startCountDown();
    _startRecord();
    return Container(
      width: 400,
      height: 350,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                _countDown!.cancel();
                Navigator.pop(_context);
              },
              child: const Icon(Icons.cancel_outlined),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(top: 20),
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Your answers are being recorded',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),
                const Image(image: AssetImage("assets/img_mic.png")),
                const SizedBox(height: 10),
                Consumer<VariableProvider>(builder: (context, appState, child) {
                  return Text(appState.strCount,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 38,
                          fontWeight: FontWeight.w600));
                }),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _record.stop();
                    _countDown!.cancel();
                    Navigator.pop(_context);
                    _listener.onClickEndReanswer(_question, _pathFile);
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.green),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)))),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: const Text("Finish"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void onSkip() {
    _record.stop();
    _countDown!.cancel();
    Navigator.pop(_context);
    _listener.onClickEndReanswer(_question, _pathFile);
  }

  void _startCountDown() {
    Future.delayed(Duration.zero).then((value) {
      TestDetailPresenter presenter = TestDetailPresenter();
      _countDown != null ? _countDown!.cancel() : '';
      _countDown = presenter.startCountDown(_context, _timeRecord, this);
      Provider.of<VariableProvider>(_context, listen: false)
          .setCountDown("00:$_timeRecord");
    });
  }

  void _startRecord() async {
    DateTime dateTime = DateTime.now();
    String timeNow =
        '${dateTime.year}${dateTime.month}${dateTime.day}_${dateTime.hour}${dateTime.minute}';
    _pathFile =
        '${await DeviceStorage.init().rootPath()}\\${DeviceStorage.AUDIO}\\${_question.id}_reanswer_$timeNow';

    if (await _record.hasPermission()) {
      await _record.start(
        path: _pathFile,
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        samplingRate: 44100,
      );
    }
  }

  @override
  void onCountDown(String strCount) {
    Provider.of<VariableProvider>(_context, listen: false)
        .setCountDown(strCount);
  }
}

abstract class ReanswerActionListener {
  void onClickEndReanswer(QuestionTopic topic, String fileRecord);
}
