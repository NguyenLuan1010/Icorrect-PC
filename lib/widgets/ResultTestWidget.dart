import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:icorrect/widgets/simulator_test/SaveTheTest.dart';


import 'package:image/image.dart' as img;

import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

import '../callbacks/AuthenticationCallBack.dart';
import '../callbacks/ViewMainCallBack.dart';
import '../data/locals/DeviceStorage.dart';
import '../data/locals/LocalStorage.dart';
import '../dialog/AlertDialog.dart';
import '../dialog/CircleLoading.dart';
import '../dialog/LoadingTestDialog.dart';
import '../dialog/MessageDialog.dart';
import '../dialog/ReanswerDialog.dart';
import '../models/Enums.dart';
import '../models/my_test/ResultResponse.dart';
import '../models/others/HomeWorks.dart';
import '../models/test_simulator/FileTopic.dart';
import '../models/test_simulator/QuestionTopic.dart';
import '../models/test_simulator/TestDetail.dart';
import '../models/test_simulator/Topic.dart';
import '../models/ui/AlertInfo.dart';
import '../presenter/MyTestPresenter.dart';
import '../presenter/TestDetailPresenter.dart';
import '../provider/VariableProvider.dart';
import '../theme/app_themes.dart';
import 'HomeWorksWidget.dart';
import 'my_test/AIResponseWidget.dart';
import 'my_test/AnswersWidget.dart';
import 'my_test/HighLightHomeWorks.dart';
import 'my_test/OtherHomeWorks.dart';
import 'my_test/TeacherResponseWidget.dart';
import 'simulator_test/ShowCueCard.dart';
import 'simulator_test/TestPlayer.dart';
import 'simulator_test/TestRecord.dart';

class ResultTestWidget extends StatefulWidget {
  HomeWorks homeWork;
  ResultTestWidget({super.key, required this.homeWork});

  @override
  State<ResultTestWidget> createState() => _ResultTestWidgetState();
}

class _ResultTestWidgetState extends State<ResultTestWidget>
    with TickerProviderStateMixin
    implements
        ReanswerActionListener,
        DownloadFileListener,
        PlayAudioListener,
        ActionLoadingTest,
        ActionAlertListener,
        SaveTheTestAction,
        SubmitHomeWorkCallBack {
  late VariableProvider _provider;
  TabController? _tabController;
  final int _tabLength = 5;
  bool _dialogShowing = false;
  CircleLoading? _loading;
  late MyTestPresenter _presenter;

  VideoPlayerController? _playerController;
  TestDetail? _testDetail;
  List<QuestionTopic> _questions = [];
  final Queue<Topic> _topics = Queue();
  final List<Topic> _topicsList = [];
  late AudioPlayer _audioPlayer;
  ResultResponse? _resultResponse;
  List<QuestionTopic> _reanswerQuestions = [];

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();
    _tabController = TabController(length: _tabLength, vsync: this);
    _provider = Provider.of<VariableProvider>(context, listen: false);

    if (!kIsWeb && Platform.isWindows) WindowsVideoPlayer.registerWith();
    _prepareData();
  }

  void _prepareData() {
    _presenter = MyTestPresenter();
    _presenter.getMyTestDetail(widget.homeWork, this);
    Future.delayed(Duration.zero, () {
      _provider.resetTestSimulatorValue();
      _provider.setVisibleSaveTheTest(true);
      _showLoadDialog();
    });
    setState(() {
      _reanswerQuestions = [];
    });
  }

  @override
  void dispose() {
    dispose();
    super.dispose();

    _provider.dispose();

    if (_playerController != null) {
      _playerController!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const Tab(text: 'Test\'s Detail'),
      const Tab(text: 'Response'),
      const Tab(text: 'Highlights'),
      const Tab(text: 'List Other'),
      (widget.homeWork.haveAIResponse == Status.HAD_SCORE.get)
          ? const Tab(text: 'AI Response')
          : Container(),
    ];
    return LayoutBuilder(builder: ((context, constraints) {
      if (constraints.maxWidth < SizeScreen.MINIMUM_WiDTH_1.size) {
        return _buildTabLayoutMobileScreen(tabs);
      } else {
        return _buildTabLayoutDesktopScreen(tabs);
      }
    }));
  }

  Widget _buildTabLayoutMobileScreen(final tabs) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              alignment: Alignment.center,
              child: DefaultTabController(
                  initialIndex: 0,
                  length: _tabLength,
                  child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5)),
                          border: Border.all(color: Colors.black, width: 2)),
                      indicatorColor: AppThemes.colors.black,
                      labelColor: AppThemes.colors.black,
                      unselectedLabelColor: AppThemes.colors.gray,
                      tabs: tabs)),
            )),
        body: TabBarView(
            controller: _tabController,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _buildTestRoom(),
              TeacherResponseWidget(homeWork: widget.homeWork),
              HighLightHomeWorks(activityId: widget.homeWork.id.toString()),
              OtherHomeWorks(activityId: widget.homeWork.id.toString()),
              AIResponseWidget(url: widget.homeWork.aiResponseLink.toString())
            ]),
      ),
    );
  }

  Widget _buildTabLayoutDesktopScreen(final tabs) {
    return Container(
      margin: const EdgeInsets.only(top: 30, left: 150, right: 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: InkWell(
              onTap: () {
                _provider.setCurrentMainWidget(HomeWorksWidget());
              },
              child: Row(
                children: [
                  Icon(
                    Icons.keyboard_backspace_sharp,
                    color: AppThemes.colors.gray,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Back',
                    style: TextStyle(
                        color: AppThemes.colors.gray,
                        fontWeight: FontWeight.w500,
                        fontSize: 17),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Scaffold(
              backgroundColor: const Color.fromARGB(0, 255, 255, 255),
              appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(40),
                  child: Container(
                    margin: const EdgeInsets.only(left: 20, right: 600),
                    child: DefaultTabController(
                        initialIndex: 0,
                        length: _tabLength,
                        child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    topRight: Radius.circular(5)),
                                border:
                                    Border.all(color: Colors.black, width: 2)),
                            indicatorColor: AppThemes.colors.black,
                            labelColor: AppThemes.colors.black,
                            unselectedLabelColor: AppThemes.colors.gray,
                            tabs: tabs)),
                  )),
              body: TabBarView(
                  controller: _tabController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildTestRoom(),
                    TeacherResponseWidget(homeWork: widget.homeWork),
                    HighLightHomeWorks(
                        activityId: widget.homeWork.id.toString()),
                    OtherHomeWorks(activityId: widget.homeWork.id.toString()),
                    AIResponseWidget(
                        url: widget.homeWork.aiResponseLink.toString())
                  ]),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTestRoom() {
    TestPlayer testPlayer = TestPlayer();
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: Border.all(color: Colors.black, width: 2),
            image: const DecorationImage(
                image: AssetImage("assets/bg_test_room.png"),
                fit: BoxFit.none)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            testPlayer.videoPlayer(),
            (_reanswerQuestions.isNotEmpty)
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 100),
                    child: SaveTheTest.saveTheTestWidget(
                        'Reanswer the question',
                        'You just reanswered the question',
                        'assets/img_question_answer.png',
                        this))
                : Container()
          ],
        ),
      ),
      AnswersWidget.buildRecordedAnswers(
          context, widget.homeWork.haveAIScore(), _questions, this, this),
    ]);
  }

  @override
  void failDownload(AlertInfo info) {
    if (_dialogShowing) {
      setState(() {
        _dialogShowing = false;
      });
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          _dialogShowing = true;
          return AlertsDialog.init().showDialog(context, info, this);
        });
  }

  @override
  void onAlertExit(String keyInfo) {
    Navigator.of(context).pop();
    _provider.resetTestSimulatorValue();
    _provider.setCurrentMainWidget(const HomeWorksWidget());
  }

  @override
  void onAlertNextStep(String keyInfo) {
    MyTestPresenter presenter = MyTestPresenter();
    presenter.getMyTestDetail(widget.homeWork, this);
  }

  @override
  void successDownload(
      TestDetail testDetail, String nameFile, double progress) {
    int downloaded = 1;
    _provider.setProgressDownload(progress);
    _provider.setVisibleReanswer(true);
    List<QuestionTopic> questions = _getQuestions(testDetail);
    if (context.mounted && mounted) {
      setState(() {
        _testDetail = testDetail;
        _questions = questions;
        if (mounted && progress == downloaded) {
          _provider.setVisibleStartNow(true);
        }
      });
    }
  }

  void _showLoadDialog() {
    if (_dialogShowing) {
      setState(() {
        _dialogShowing = false;
      });
    }
    Future.delayed(Duration.zero, () async {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Consumer<VariableProvider>(
                builder: (context, appState, child) =>
                    LoadingTestDialog.loadingTestDialog(
                        context,
                        appState.progress,
                        appState.partOfTest,
                        appState.isVisible,
                        this));
          });
    });
  }

  @override
  void onClickStartNow() {
    Navigator.of(context).pop();
  }

  List<QuestionTopic> _getQuestions(TestDetail testDetail) {
    List<QuestionTopic> questions = [];
    if (testDetail.introduce != null) {
      questions.addAll(testDetail.introduce!.questions ?? []);
    }
    if (testDetail.part1 != null) {
      for (Topic q in testDetail.part1 ?? []) {
        questions.addAll(q.questions ?? []);
      }
    }
    if (testDetail.part2 != null) {
      questions.addAll(testDetail.part2!.questions ?? []);
    }
    if (testDetail.part3 != null) {
      questions.addAll(testDetail.part3!.questions ?? []);
      questions.addAll(testDetail.part3!.followUp ?? []);
    }
    questions.sort((a, b) => a.numPart.compareTo(b.numPart));
    return questions;
  }

  @override
  void onClickEndReanswer(QuestionTopic question, String fileRecord) {
    setState(() {
      //Set record to reanswer questions
      if (question.answers!.isNotEmpty) {
        question.answers!.last.setUrl = fileRecord;
      } else {
        question.answers!.add(FileTopic('', url: fileRecord, type: ''));
      }
      question.reanswer_count++;
      _reanswerQuestions.add(question);

      ///Update data record for question
      for (QuestionTopic q in _questions) {
        if (q.id == question.id) {
          q.answers!.last.setUrl = '$fileRecord.wav';
          q.reanswer_count = question.reanswer_count;
          break;
        }
      }
    });
  }

  @override
  void onPauseAudio() {
    _stopAudio();
  }

  // Future<void> mergeVideoImageAudio() async {
  //   // Get the paths for the input video, image, and audio files
  //   String videoPath =
  //       "${await DeviceStorage.init().rootPath()}\\${DeviceStorage.VIDEO}\\135.mp4";

  //   // Path to the input image file
  //   String imagePath = "assets/img_play.png";

  //   // Path to the input audio file
  //   String audioPath =
  //       "${await DeviceStorage.init().rootPath()}\\${DeviceStorage.AUDIO}\\audio_1681709862_4599-0.mp3";

  //   VideoPlayerController videoController =
  //       VideoPlayerController.file(File(videoPath))..initialize();
  //   int videoWidth = videoController.value.size.width.toInt();
  //   int videoHeight = videoController.value.size.height.toInt();

  //   // Load the image
  //   Uint8List imageBytes = await File(imagePath).readAsBytes();
  //   img.Image? image = img.decodeImage(imageBytes);
  //   image = img.copyResize(image!, width: videoWidth, height: videoHeight);

  //   // Convert the image to bytes
  //   Uint8List resizedImageBytes = Uint8List.fromList(img.encodePng(image));

  //   // Read the audio bytes
  //   Uint8List audioBytes = await File(audioPath).readAsBytes();

  //   // Create a directory to store the merged video

  //   String outputVideoPath =
  //       "${await DeviceStorage.init().rootPath()}\\output.mp4";

  //   // Create a file to write the merged video
  //   File mergedVideoFile = File(outputVideoPath);

  //   // Write the video frames
  //   for (int i = 0; i < videoController.value.duration.inSeconds; i++) {
  //     mergedVideoFile.writeAsBytesSync(resizedImageBytes);
  //   }

  //   //Write the audio frames
  //  mergedVideoFile.writeAsBytesSync(audioBytes);

  //   // Dispose the video controller
  //   videoController.dispose();
  // }


  @override
  Future<void> onPlayAudio(String audioPath, String questionId) async {
    _playAudio(
        '${await DeviceStorage.init().rootPath()}\\$audioPath', questionId);
    print('audio file: ${await DeviceStorage.init().rootPath()}\\$audioPath');
  }

  Future<void> _playAudio(String audioPath, String questionId) async {
    try {
      await _audioPlayer.play(DeviceFileSource(audioPath));
      await _audioPlayer.setVolume(2.5);
      _audioPlayer.onPlayerComplete.listen((event) {
        _provider.setPlayAnswer(false, questionId);
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
  }

  @override
  void onClickBackToHome() {
    _provider.setCurrentMainWidget(const HomeWorksWidget());
  }

  @override
  void clickSaveTheTest() {
    _loading?.show(context);

    TestDetailPresenter presenter = TestDetailPresenter();
    presenter.submitHomeWork(_testDetail!.testId.toString(),
        widget.homeWork.id.toString(), _reanswerQuestions, this);
  }

  @override
  void submitHomeWorkFail(AlertInfo alertInfo) {
    _loading?.hide();
    if (!_dialogShowing) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertsDialog.init().showDialog(context, alertInfo, this);
          });
      setState(() {
        _dialogShowing = true;
      });
    }
  }

  @override
  void submitHomeWorkSuccess(String message) {
    _loading?.hide();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return MessageDialog.alertDialog(context, message);
        });

    setState(() {
      _reanswerQuestions = [];
    });
  }
}
