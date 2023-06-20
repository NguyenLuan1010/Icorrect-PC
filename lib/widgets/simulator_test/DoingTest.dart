import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win_plugin.dart';

import '../../callbacks/AuthenticationCallBack.dart';
import '../../callbacks/ViewMainCallBack.dart';
import '../../data/locals/DeviceStorage.dart';
import '../../data/locals/LocalStorage.dart';
import '../../dialog/AlertDialog.dart';
import '../../dialog/CircleLoading.dart';
import '../../dialog/LoadingTestDialog.dart';
import '../../dialog/MessageDialog.dart';
import '../../dialog/ReanswerDialog.dart';
import '../../models/Enums.dart';
import '../../models/others/HomeWorks.dart';
import '../../models/test_simulator/FileTopic.dart';
import '../../models/test_simulator/QuestionTopic.dart';
import '../../models/test_simulator/TestDetail.dart';
import '../../models/test_simulator/Topic.dart';
import '../../models/ui/AlertInfo.dart';
import '../../presenter/TestDetailPresenter.dart';
import '../../provider/VariableProvider.dart';
import 'package:record/record.dart';

import '../../theme/app_themes.dart';
import '../HomeWorksWidget.dart';
import 'SaveTheTest.dart';
import 'ShowCueCard.dart';
import 'TestPlayer.dart';
import 'TestQuestions.dart';
import 'TestRecord.dart';

class DoingTest extends StatefulWidget {
  HomeWorks homework;
  DoingTest({super.key, required this.homework});

  @override
  State<DoingTest> createState() => _DoingTestState();
}

class _DoingTestState extends State<DoingTest>
    implements
        RequestTestDetailCallBack,
        ActionRecordListener,
        SaveTheTestAction,
        ReanswerActionListener,
        DownloadFileListener,
        ActionLoadingTest,
        CountDownListener,
        FilesIntroListener,
        FilesQuestionListener,
        EndOfTestListener,
        SubmitHomeWorkCallBack,
        ActionAlertListener {
  var ERROR_REQUEST_TEST = 'ERROR_REQUEST_TEST';
  var FAIL_DOWNLOAD_VIDEO = 'FAIL_DOWNLOAD_VIDEO';
  var WARNING_OUT_THE_TEST = 'WARNING_OUT_THE_TEST';
  var SUBMIT_HOMEWORK_FAIL = 'SUBMIT_HOMEWORK_FAIL';
  var VIDEO_PATH_ERROR = 'VIDEO_PATH_ERROR';

  late VariableProvider _provider;
  final _record = Record();
  late TestDetailPresenter _presenter;
  late VideoPlayerController _playerController;
  CircleLoading? _loading;
  Timer? _countDown;
  AlertDialog? _alertDialog;

  List<Topic> _topicsList = [];
  List<QuestionTopic> _questionsList = [];
  final _topicsPlay = Queue<Topic>();
  QuestionTopic? _questionTopic;
  static TestDetail? _testDetail;

  int _timeRecord = 30;
  int _countRepeat = 0;
  int _indexQuestion = 0;
  int _indexFollowUp = 0;
  bool _visibleRecord = false;
  bool _showedCueCard = false;
  bool _ranFollowUp = false;
  bool _ranQuestion = false;
  bool _dialogShowing = false;
  String _pathFile = '';
  final List<FileTopic> _answers = [];

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<VariableProvider>(context, listen: false);
    _loading = CircleLoading();
    _loading?.show(context);
    _presenter = TestDetailPresenter();

    if (!kIsWeb && Platform.isWindows) WindowsVideoPlayer.registerWith();

    _presenter.requestTestDetail(widget.homework.id.toString(), this);
  }

  @override
  Widget build(BuildContext context) {
    return _buildTestRoom();
  }

  @override
  void dispose() {
    dispose();
    super.dispose();
    _playerController.dispose();
    _provider.dispose();
    _record.dispose();
    _countDown!.cancel();
  }

  Widget _buildTestRoom() {
    return LayoutBuilder(builder: (context, contraints) {
      if (contraints.maxWidth < SizeScreen.MINIMUM_WiDTH_2.size) {
        return _testRoomMobile();
      } else {
        return _testRoomDesktop();
      }
    });
  }

  Widget _testRoomMobile() {
    TestQuestion testQuestion = TestQuestion();
    TestPlayer testPlayer = TestPlayer();
    return Container(
      margin: const EdgeInsets.only(top: 10, right: 30, left: 30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  border: Border.all(color: Colors.black, width: 2),
                  image: const DecorationImage(
                      image: AssetImage("assets/bg_test_room.png"),
                      fit: BoxFit.cover)),
              child: testPlayer.videoPlayer(),
            ),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                testQuestion.testQuestionsWidget(context, this),
                Card(
                  elevation: 3,
                  child: Expanded(
                      child: Center(
                          child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ShowCueCard.showCueCard(
                          _questionTopic ?? QuestionTopic()),
                      TestRecord.recordAnswer(_visibleRecord, this),
                      SaveTheTest.saveTheTestWidget(
                          'Congratulations',
                          'You finished a speaking test',
                          'assets/ic_completed.png',
                          this)
                    ],
                  ))),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _testRoomDesktop() {
    TestQuestion testQuestion = TestQuestion();
    TestPlayer testPlayer = TestPlayer();
    return Container(
      margin: const EdgeInsets.only(top: 10, right: 100, left: 100),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: InkWell(
                  onTap: () {
                    _loading?.hide();
                    whenOutTheTest();
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
                  )),
            ),
            Text(widget.homework.name,
                style: TextStyle(
                    color: AppThemes.colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  border: Border.all(color: Colors.black, width: 2),
                  image: const DecorationImage(
                      image: AssetImage("assets/bg_test_room.png"),
                      fit: BoxFit.cover)),
              child: Row(
                children: [
                  testPlayer.videoPlayer(),
                  Expanded(
                      child: Center(
                          child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ShowCueCard.showCueCard(
                          _questionTopic ?? QuestionTopic()),
                      TestRecord.recordAnswer(_visibleRecord, this),
                      SaveTheTest.saveTheTestWidget(
                          'Congratulations',
                          'You finished a speaking test',
                          'assets/ic_completed.png',
                          this)
                    ],
                  )))
                ],
              ),
            ),
            testQuestion.testQuestionsWidget(context, this)
          ],
        ),
      ),
    );
  }

//////////////////////////////EXECUTE ALERT ERROR/////////////////////////////

  @override
  void onAlertExit(String keyInfo) {
    onClickAlertExit(keyInfo);
  }

  @override
  void onAlertNextStep(String keyInfo) {
    onClickAlertNext(keyInfo);
  }

  void onClickAlertExit(String keyInfo) {
    switch (keyInfo) {
      case 'ERROR_REQUEST_TEST':
        _provider.resetTestSimulatorValue();
        _provider.setCurrentMainWidget(const HomeWorksWidget());
        break;
      case 'FAIL_DOWNLOAD_VIDEO':
        _provider.resetTestSimulatorValue();
        _provider.setCurrentMainWidget(const HomeWorksWidget());
        break;
      case 'SUBMIT_HOMEWORK_FAIL':
        _provider.resetTestSimulatorValue();
        _provider.setCurrentMainWidget(const HomeWorksWidget());
        break;
      case 'VIDEO_PATH_ERROR':
        _provider.resetTestSimulatorValue();
        _provider.setCurrentMainWidget(const HomeWorksWidget());
        break;
    }
    setState(() {
      _dialogShowing = false;
    });
  }

  void onClickAlertNext(String keyInfo) {
    switch (keyInfo) {
      case 'ERROR_REQUEST_TEST':
        _loading?.show(context);
        _resetCountDown();
        _presenter.requestTestDetail(widget.homework.id.toString(), this);
        break;
      case 'FAIL_DOWNLOAD_VIDEO':
        _loading?.show(context);
        _provider.resetTestSimulatorValue();
        _presenter.requestTestDetail(widget.homework.id.toString(), this);
        break;
      case 'SUBMIT_HOMEWORK_FAIL':
        _countDown != null ? _countDown!.cancel() : '';
        _setVisibleRecord(false, _countDown);
        _loading?.show(context);
        TestDetailPresenter presenter = TestDetailPresenter();
        presenter.submitHomeWork(_testDetail!.testId.toString(),
            widget.homework.id.toString(), _questionsList, this);
        break;
      case 'WARNING_OUT_THE_TEST':
        if (mounted) {
          _countDown != null ? _countDown!.cancel() : '';
          _setVisibleRecord(false, _countDown);
          _provider.stopVideoController();
          _provider.resetTestSimulatorValue();
          _provider.setCurrentMainWidget(const HomeWorksWidget());
        }
      case 'VIDEO_PATH_ERROR':
        _loading?.show(context);
        _countDown != null ? _countDown!.cancel() : '';
        _setVisibleRecord(false, _countDown);
        _provider.stopVideoController();
        _provider.resetTestSimulatorValue();
        _presenter.requestTestDetail(widget.homework.id.toString(), this);
        break;
    }

    setState(() {
      _dialogShowing = false;
    });
  }

  //////////////////////////////////////////////////////////////////////////////

  @override
  Future<void> startDownloadFile(Map<String, dynamic> dataMap) async {
    _loading?.hide();

    TestDetail testDetail = await _presenter.getTestDetail(dataMap, this);
    if (mounted) {
      setState(() {
        if (testDetail.introduce != null) {
          _topicsList.add(testDetail.introduce!);
        }
        if (testDetail.part1 != null) {
          _topicsList.addAll(testDetail.part1 ?? []);
        }

        if (testDetail.part2 != null) {
          _topicsList.add(testDetail.part2!);
        }

        if (testDetail.part3 != null &&
            (testDetail.part3!.questions!.isNotEmpty ||
                testDetail.part3!.fileEndOfTest!.getUrl
                    .toString()
                    .isNotEmpty)) {
          _topicsList.add(testDetail.part3!);
        }
      });
    }

    _showLoadDialog();
  }

  @override
  void errorRequestTestDetail(AlertInfo alertInfo) {
    _loading?.hide();

    if (!_dialogShowing) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertsDialog.init().showDialog(context, alertInfo, this,
                keyInfo: ERROR_REQUEST_TEST);
          });
      setState(() {
        _dialogShowing = true;
      });
    }
  }

  void _showLoadDialog() {
    if (!_dialogShowing) {
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
      setState(() {
        _dialogShowing = true;
      });
    }
  }

  @override
  void successDownload(
      TestDetail testDetail, String nameFile, double progress) {
    int downloadAll = 1;
    _setProgress(progress);
    if (mounted && progress >= downloadAll / 4) {
      _setVisibleButton(true);
    }
    if (context.mounted) {
      setState(() {
        _topicsList.sort((a, b) => a.numPart.compareTo(b.numPart));
        _topicsPlay.addAll(_topicsList);
        _testDetail = testDetail;
      });
    }
  }

  @override
  void failDownload(AlertInfo info) {
    if (mounted) {
      if (!_dialogShowing) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertsDialog.init().showDialog(context, info, this,
                  keyInfo: FAIL_DOWNLOAD_VIDEO);
            });
        setState(() {
          _dialogShowing = true;
        });
      }
    }
  }

  @override
  void onClickStartNow() {
    _setVisibleReanswer(false);
    _initVideoController(File(''), true);
    Navigator.of(context).pop();

    List<FileTopic> files = _topicsPlay.first.files!;
    _presenter.fileIntroPlayer(files, this);
  }

  @override
  void onClickBackToHome() {
    _provider.setCurrentMainWidget(const HomeWorksWidget());
  }

  @override
  void clickEndQuestion() {
    if (context.mounted && mounted) {
      setState(() {
        _indexQuestion++;
        _indexFollowUp++;
        _showedCueCard = false;
        _countRepeat = 0;
      });
      _playQuestion();
      _provider.setQuestionsTest(_questionTopic!);
    }
  }

  @override
  Future<void> clickRepeat() async {
    _pathFile = await _createFileName();
    setState(() {
      _countRepeat++;
      _answers.add(FileTopic(0, url: _pathFile, type: 0));
    });

    _playQuestion();
  }

  @override
  void onCountDown(String strCount) {
    if (mounted) {
      _provider.setCountDown(strCount);
    }
  }

  @override
  void onSkip() {
    if (context.mounted && mounted) {
      setState(() {
        _indexQuestion++;
        _indexFollowUp++;
        _countRepeat = 0;
      });

      _playQuestion();

      if (!_showedCueCard) {
        _provider.setQuestionsTest(_questionTopic!);
      }
    }
  }

  @override
  void clickSaveTheTest() {
    _loading?.show(context);
    TestDetailPresenter presenter = TestDetailPresenter();
    presenter.submitHomeWork(_testDetail!.testId.toString(),
        widget.homework.id.toString(), _questionsList, this);
  }

  @override
  void onClickEndReanswer(QuestionTopic topic, String fileRecord) {
    for (QuestionTopic q in _questionsList) {
      if (q.id == topic.id) {
        setState(() {
          q.answers!.last.setUrl = fileRecord;
          q.reanswer_count++;
        });
        break;
      }
    }
  }

  Future<void> _initVideoController(File file, bool isIntro) async {
    _playerController = VideoPlayerController.file(file)..initialize();

    _playerController.value.isPlaying
        ? _playerController.pause()
        : _playerController.play();
    if (_countRepeat == 2) {
      _playerController.setPlaybackSpeed(0.7);
    }
    _playerController.addListener(() async {
      if (!_playerController.value.size.isEmpty) {
        if (_playerController.value.position ==
            _playerController.value.duration) {
          if (!isIntro) {
            _countDown = _presenter.startCountDown(context, _timeRecord, this);
            if (_questionTopic!.cue_card.isNotEmpty && !_showedCueCard) {
              _setVisibleCueCard(true, _countDown);
              _showedCueCard = true;
            } else {
              _setVisibleRecord(true, _countDown);
            }
          } else {
            _playQuestion();
          }
        } else {
          _setVisibleRecord(false, null);
          _setVisibleCueCard(false, null);
        }
      }
    });

    if (context.mounted) {
      _provider.setPlayController(_playerController);
    }
  }

  Future<void> _playQuestion() async {
    _provider.setRepeatVisible(_countRepeat < 2);
    _resetCountDown();

    Topic topic = _topicsPlay.first;
    List<QuestionTopic> questions = topic.questions ?? [];
    List<QuestionTopic> followsUp = topic.followUp ?? [];

    if (questions.isEmpty && followsUp.isEmpty) {
      _presenter.fileEndOfTest(topic, this);
      return;
    }

    if (followsUp.isNotEmpty && _indexFollowUp < followsUp.length) {
      _ranFollowUp = true;
      if (_countRepeat == 0) {
        _answers.clear();
      }
      _presenter.fileQuestionsPlayer(topic, followsUp, this,
          index: _indexFollowUp, isReanswer: false);
    } else {
      if (_ranFollowUp) {
        _indexQuestion = 0;
        _ranFollowUp = false;
      }
      if (_indexQuestion < questions.length) {
        (topic.followUp.isNotEmpty)
            ? (_ranQuestion = true)
            : {_ranQuestion = false};
        if (_countRepeat == 0) {
          _answers.clear();
        }
        _presenter.fileQuestionsPlayer(topic, questions, this,
            index: _indexQuestion, isReanswer: false);
      } else {
        if ((_questionTopic!.cue_card.isNotEmpty && _showedCueCard) ||
            (topic.followUp.isNotEmpty && _ranQuestion)) {
          _presenter.fileEndOfTest(topic, this);
        } else {
          if (topic.numPart == _topicsPlay.last.numPart &&
              topic.fileEndOfTest!.getUrl.toString().isEmpty &&
              topic.followUp.isEmpty) {
            _setSaveTheTest();
            return;
          }

          if (topic.fileEndOfTest!.getUrl.toString().isNotEmpty &&
              _questionTopic!.cue_card.toString().isEmpty &&
              topic.followUp.isEmpty) {
            _presenter.fileEndOfTest(topic, this);
            return;
          }

          if (topic.numPart != _topicsPlay.last.numPart) {
            _topicsPlay.removeFirst();
          }

          _indexQuestion = 0;
          if (!_ranFollowUp) {
            _indexFollowUp = 0;
            Topic nextTest = _topicsPlay.first;
            List<FileTopic> files = nextTest.files!;
            _presenter.fileIntroPlayer(files, this);
          } else {
            if (_countRepeat == 0) {
              _answers.clear();
            }
            _ranFollowUp = false;
            _presenter.fileQuestionsPlayer(topic, questions, this,
                index: _indexQuestion, isReanswer: false);
          }
        }
      }
    }
  }

  @override
  void playIntro(String path) {
    print('introduce $path');
    _countRepeat = 0;
    _countDown != null ? _countDown!.cancel() : '';
    _initVideoController(File(path), true);
  }

  @override
  void nothingIntroduce() {
    if (context.mounted && mounted) {
      setState(() {
        _indexQuestion = 0;
        _indexFollowUp = 0;
        _countRepeat = 0;
        Topic topic = _topicsPlay.first;
        if (topic.numPart != _topicsPlay.last.numPart) {
          _topicsPlay.removeFirst();
        }
      });

      _playQuestion();
    }
  }

  @override
  void nothingFileIntroduce() {
    _videoFileEmpty();
  }

  @override
  Future<void> playQuestion(QuestionTopic question, String path) async {
    print('question path : $path');
    _pathFile = await _createFileName();

    if (context.mounted) {
      setState(() {
        question.is_follow_up = _ranFollowUp;
        _questionTopic = question;
        _timeRecord = 30;

        if (_questionTopic!.cue_card.isNotEmpty) {
          _timeRecord = 2;
        }
        _provider.setCountDown("00:$_timeRecord");
      });
    }
    _countDown != null ? _countDown!.cancel() : '';

    _initVideoController(File(path), false);
  }

  @override
  void nothingQuestion() {
    if (context.mounted && mounted) {
      setState(() {
        _indexQuestion = 0;
        _indexFollowUp = 0;
        _countRepeat = 0;
        Topic topic = _topicsPlay.first;
        if (topic.numPart != _topicsPlay.last.numPart) {
          _topicsPlay.removeFirst();
        }
      });

      _playQuestion();
    }
  }

  @override
  void nothingFileQuestion() {
    _videoFileEmpty();
  }

  @override
  void playEndOfTest(String path) {
    print('end of test : $path');
    if (!context.mounted && !mounted) {
      return;
    }
    _countDown != null ? _countDown!.cancel() : '';
    Topic topicDetail = _topicsPlay.first;

    if (_questionTopic!.cue_card.isNotEmpty && _showedCueCard) {
      setState(() {
        _answers.clear();
        _timeRecord = 120;
        _provider.setCountDown("01:60");

        if (topicDetail.numPart != _topicsPlay.last.numPart) {
          _topicsPlay.removeFirst();
        }

        List<QuestionTopic> questions = _topicsPlay.first.questions!;
        _indexQuestion = questions.length;
        List<QuestionTopic> followsUp = _topicsPlay.first.followUp;
        _indexFollowUp = followsUp.length;
      });

      _initVideoController(File(path), false);
    } else {
      _playerController = VideoPlayerController.file(File(path))..initialize();

      _playerController.value.isPlaying
          ? _playerController.pause()
          : _playerController.play();

      _playerController.addListener(() {
        if (!_playerController.value.size.isEmpty &&
            _playerController.value.position ==
                _playerController.value.duration) {
          _countDown != null ? _countDown!.cancel() : '';
        }
        _setSaveTheTest();
      });

      if (context.mounted && mounted) {
        _provider.setPlayController(_playerController);
      }
    }
  }

  @override
  void nothingEndOfTest() {
    if (context.mounted && mounted) {
      setState(() {
        _indexQuestion = 0;
        _indexFollowUp = 0;
        _countRepeat = 0;
      });

      Topic topic = _topicsPlay.first;
      if (topic.numPart == _topicsPlay.last.numPart) {
        _setSaveTheTest();
      } else {
        _topicsPlay.removeFirst();
        _playQuestion();
      }
    }
  }

  @override
  void nothingFileEndOfTest() {
    _videoFileEmpty();
  }

  @override
  void submitHomeWorkFail(AlertInfo alertInfo) {
    _loading?.hide();

    if (!_dialogShowing) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertsDialog.init().showDialog(context, alertInfo, this,
                keyInfo: SUBMIT_HOMEWORK_FAIL);
          });
      setState(() {
        _dialogShowing = true;
      });
    }
  }

  @override
  void submitHomeWorkSuccess(String message) {
    _loading?.hide();
    if (mounted) {
      _provider.setCurrentMainWidget(const HomeWorksWidget());
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return MessageDialog.alertDialog(context, message);
        });
  }

  void _resetCountDown() {
    if (context.mounted && mounted) {
      setState(() {
        _countDown != null ? _countDown!.cancel() : '';
        _countDown = _presenter.startCountDown(context, _timeRecord, this);
        _provider.setCountDown("00:$_timeRecord");
      });
    }
  }

  void _setVisibleRecord(bool visible, Timer? count) {
    if (context.mounted && mounted) {
      setState(() {
        _visibleRecord = visible;
      });

      if (_visibleRecord) {
        _recordAnswer();
      } else {
        setState(() {
          _record.stop();
        });
      }
      _provider.setLitenTimer(count);
    }
  }

  Future<void> _recordAnswer() async {
    print(_pathFile.toString());
    if (await _record.hasPermission()) {
      await _record.start(
        path: _pathFile,
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        samplingRate: 44100,
      );
    }

    if (_countRepeat == 0) {
      _answers.add(FileTopic(0, url: _pathFile, type: 0));
    }
    _questionTopic!.answers!.clear();
    _questionTopic!.answers!.addAll(_answers);
    _questionsList.add(_questionTopic!);
    print(_pathFile);
    print(_questionsList.first.answers ?? []);
  }

  Future<String> _createFileName() async {
    DateTime dateTime = DateTime.now();
    String timeNow =
        '${dateTime.year}${dateTime.month}${dateTime.day}_${dateTime.hour}${dateTime.minute}${dateTime.second}';
    if (_countRepeat > 0) {
      return '${await DeviceStorage.init().rootPath()}\\${DeviceStorage.AUDIO}\\${timeNow}_repeat';
    }
    return '${await DeviceStorage.init().rootPath()}\\${DeviceStorage.AUDIO}\\${timeNow}_answer';
  }

  void _setSaveTheTest() {
    _countDown != null ? _countDown!.cancel() : '';
    if (context.mounted && mounted) {
      _setVisibleSaveTest(true);
      _setVisibleCueCard(false, null);
      _setVisibleRecord(false, null);
      _setVisibleReanswer(true);
    }
  }

  void _setProgress(double progress) {
    _provider.setProgressDownload(progress);
  }

  void _setVisibleButton(bool isVisible) {
    _provider.setVisibleStartNow(isVisible);
  }

  void _setVisibleReanswer(bool visible) {
    _provider.setVisibleReanswer(visible);
  }

  void _setVisibleCueCard(bool visible, Timer? count) {
    _provider.setVisibleCueCard(visible, timer: count);
  }

  void _setVisibleSaveTest(bool isVisible) {
    _provider.setVisibleSaveTheTest(isVisible);
  }

  void _videoFileEmpty() {
    AlertInfo info = AlertInfo(
        'Warning',
        'Video path was incorrect , Please try again !',
        Alert.DATA_NOT_FOUND.type);

    if (!_dialogShowing) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertsDialog.init()
                .showDialog(context, info, this, keyInfo: VIDEO_PATH_ERROR);
          });
      setState(() {
        _dialogShowing = true;
      });
    }
  }

  void whenOutTheTest() {
    AlertInfo info = AlertInfo(
        'Warning',
        'Are you sure to out this test? Your test won\'t be saved !',
        Alert.WARNING.type);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertsDialog.init()
              .showDialog(context, info, this, keyInfo: WARNING_OUT_THE_TEST);
        });
  }
}
