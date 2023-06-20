import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../theme/app_themes.dart';

class TestRoomWidget {
  final String? _count;
  final VideoPlayerController? _playerController;

  TestRoomWidget(this._count,this._playerController);

  Widget buildTestRoom() {
    return Column(
      children: [_testVideo(), _testQuestions()],
    );
  }

  Widget _testVideo() {
    var radius = const Radius.circular(5);

    double width = 500, height = 300;
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(radius),
            border: Border.all(color: Colors.black, width: 2),
            image: const DecorationImage(
                image: AssetImage("assets/bg_test_room.png"),
                fit: BoxFit.cover)),
        child: Row(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      _playerController!.value.isInitialized
                          ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: SizedBox(
                                  width: width,
                                  height: height,
                                  child: AspectRatio(
                                    aspectRatio:
                                        _playerController!.value.aspectRatio,
                                    child: VideoPlayer(_playerController!),
                                  )),
                            )
                          : Container(),
                      const Image(
                        image: AssetImage("assets/ic_paste.png"),
                        alignment: Alignment.topLeft,
                      )
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 500,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: Colors.grey, width: 1)),
                    child: LinearProgressIndicator(
                      minHeight: 7,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppThemes.colors.progressBar),
                      backgroundColor: Colors.white,
                      value: 0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Cau 2/ 10 ",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                ],
              )),
            ),
            Expanded(
              child: Column(
                children: [   
                  const Text('Câu trả lời của bạn đang được ghi lại',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  const Image(image: AssetImage("assets/img_mic.png")),
                  const SizedBox(height: 10),
                  Text("00:$_count",
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 38,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.green),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)))),
                              child: const Text("Kết thúc"),
                            ),
                          )),
                      Flexible(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                _playerController!.play();
                              },
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          AppThemes.colors.purple),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)))),
                              child: const Text("Lặp lại"),
                            ),
                          ))
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

  Widget _testQuestions() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  _testQuestion(),
                  _testQuestion(),
                  _testQuestion(),
                  _testQuestion()
                ],
              ),
              Column(
                children: [
                  _testQuestion(),
                  _testQuestion(),
                  _testQuestion(),
                  _testQuestion()
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _testQuestion() {
    return Container(
      width: 500,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '1.Can you please tell me your full name',
                    style:  TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("00:15' | 1 repeat times",
                          style: TextStyle(
                              color: AppThemes.colors.purpleSlight,
                              fontSize: 13)),
                      const SizedBox(width: 20),
                      const Text("Re-answer",
                          style: TextStyle(color: Colors.green, fontSize: 15)),
                      const SizedBox(width: 20),
                      const Text("View tips",
                          style: TextStyle(color: Colors.amber, fontSize: 14))
                    ],
                  )
                ],
              )),
              const Image(image: AssetImage("assets/img_play.png"))
            ],
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey,
          )
        ],
      ),
    );
  }
}
