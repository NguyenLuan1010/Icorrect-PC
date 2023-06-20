import 'dart:async';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

import '../models/test_simulator/QuestionTopic.dart';
import '../widgets/HomeWorksWidget.dart';
import '../widgets/LoginWidget.dart';

class VariableProvider with ChangeNotifier {
  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  void resetTestSimulatorValue() {
    _progress = 0;
    _isVisible = false;
    _playerController = null;
    _strCount = null;
    _timer = null;
    _isRepeatVisible = false;
    _questions = [];
    if (_timerCueCard != null) {
      _timerCueCard!.cancel();
    }
    _isVisibleCueCard = false;
    _questionId = '';
    _playAnswer = false;
    _isVisibleReanswer = false;
    _isVisibleSave = false;
    _playAudioExample = true;
    if (_timer != null) {
      _timer!.cancel();
    }
    if (!isDisposed) {
      notifyListeners();
    }
  }

  //Change page when click in MainWidget
  Widget _currentWidget = HomeWorksWidget();
  Widget get currentMainWidget => _currentWidget;

  void setCurrentMainWidget(Widget widget) {
    _currentWidget = widget;
    if (!isDisposed) {
      notifyListeners();
    }
  }

//Change page when click in AuthWidget
  Widget _currentAuthWidget = LoginWidget();
  Widget get currentAuthWidget => _currentAuthWidget;

  void setCurrentAuthWidget(Widget widget) {
    _currentAuthWidget = widget;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  //Listener percent when downloading .mp4 file
  double _progress = 0;
  double get progress => _progress;

  void setProgressDownload(double progress) {
    _progress = progress;
    if (!isDisposed) {
      notifyListeners();
    }
  }

//Change visible record widget
  bool _isVisible = false;

  bool get isVisible => _isVisible;
  void setVisibleStartNow(bool isVisible) {
    _isVisible = isVisible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

//Loading to get Part of Test
  String _partOfTest = "Please wait...";
  String get partOfTest => _partOfTest;
  void setLoadTestListener(String partOfTest) {
    _partOfTest = partOfTest;
    if (!isDisposed) {
      notifyListeners();
    }
  }

// Listen and Change Play Video
  VideoPlayerController? _playerController;
  VideoPlayerController get playController =>
      _playerController ?? VideoPlayerController.network("");
  void setPlayController(VideoPlayerController playerController) {
    _playerController = playerController;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void stopVideoController() {
    if (_playerController != null) {
      if (_playerController!.value.isPlaying) {
        _playerController!.pause();
      }
      _playerController!.dispose();
    }

    if (!isDisposed) {
      notifyListeners();
    }
  }

//Listen Record
  String? _strCount;
  String get strCount => _strCount ?? '00:00';
  void setCountDown(String strCount) {
    _strCount = strCount;
    if (!isDisposed) {
      notifyListeners();
    }
  }

  Timer? _timer;
  Timer get timerCountDown => _timer!;

  void setLitenTimer(Timer? timer) {
    _timer = timer;
    if (!isDisposed) {
      notifyListeners();
    }
  }

//Change Visible of Repeat button

  bool _isRepeatVisible = true;
  bool get isRepeatVisible => _isRepeatVisible;
  void setRepeatVisible(bool visible) {
    _isRepeatVisible = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

//Questions List While Testing
  List<QuestionTopic> _questions = [];
  List<QuestionTopic> get questionsTest => _questions;

  void setQuestionsTest(QuestionTopic question) {
    _questions.add(question);
    if (!isDisposed) {
      notifyListeners();
    }
  }

  void clearQuestions() {
    _questions.clear();
    if (!isDisposed) {
      notifyListeners();
    }
  }

//Visible Cue Card

  bool _isVisibleCueCard = false;
  bool get isVisibleCueCard => _isVisibleCueCard;
  Timer? _timerCueCard;
  Timer get timerCueCard => _timerCueCard!;
  void setVisibleCueCard(bool visible, {required Timer? timer}) {
    _isVisibleCueCard = visible;
    _timerCueCard = timer;
    if (!isDisposed) {
      notifyListeners();
    }
  }

//Visible Save The Test
  bool _isVisibleSave = false;
  bool get isVisibleSaveTheTest => _isVisibleSave;
  void setVisibleSaveTheTest(bool visible) {
    _isVisibleSave = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

//Visible Reanswer
  bool _isVisibleReanswer = false;

  bool get isVisibleReanswer => _isVisibleReanswer;
  void setVisibleReanswer(bool visible) {
    _isVisibleReanswer = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }

//Set play Answer Audio
  bool _playAnswer = false;
  String _questionId = '';
  String get questionId => _questionId;

  bool get playAnswer => _playAnswer;
  void setPlayAnswer(bool visible, String questionId) {
    _playAnswer = visible;
    _questionId = questionId;
    if (!isDisposed) {
      notifyListeners();
    }
  }

// Set Play Audio Example
  bool _playAudioExample = true;
  bool get playAudioExample => _playAudioExample;

  void setPlayAudioExample(bool visible) {
    _playAudioExample = visible;
    if (!isDisposed) {
      notifyListeners();
    }
  }
}
