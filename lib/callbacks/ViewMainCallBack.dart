import 'package:flutter/material.dart';


import '../models/my_test/ResultResponse.dart';
import '../models/my_test/StudentsResults.dart';
import '../models/others/HomeWorks.dart';
import '../models/test_simulator/QuestionTopic.dart';
import '../models/test_simulator/Topic.dart';
import '../models/ui/AlertInfo.dart';

abstract class GetHomeWorkCallBack {
  void getHomeWorksSuccess(List<HomeWorks> homeWorks);
  void failToGetHomework(AlertInfo alertInfo);
}

/////////////////////////////LOAD PART OF TEST ////////////////////////////////

abstract class GetTopicDetailCallBack {
  void getIntroduce(Topic topic);
  void getPartI(List<Topic> topics);
  void getpartII(Topic topic);
  void getPartIII(Topic topic);
  void errorWhenLoad(AlertInfo alertInfo);
}

abstract class StepPartOfTestCallBack {
  void playIntro(List<QuestionTopic>? questions, String path);
  void playVideo(QuestionTopic question, String path);
  void enOfPart();
  void skip();
}

///////////////////////////////DOING TEST DETAIL/////////////////////////////////////////

abstract class ActionRecordListener {
  void clickEndQuestion();
  void clickRepeat();
}

abstract class PlayVideoListener {
  void playFiles(String path);
  void playQuestions(String path);
  void timeCounting();
}

abstract class FilesIntroListener {
  void playIntro(String path);
  void nothingFileIntroduce();
  void nothingIntroduce();
}

abstract class FilesQuestionListener {
  void playQuestion(QuestionTopic question, String path);
  void nothingFileQuestion();
  void nothingQuestion();
}

abstract class EndOfTestListener {
  void playEndOfTest(String path);
  void nothingFileEndOfTest();
  void nothingEndOfTest();
}

abstract class FilesFollowUpListener {
  void playFollowUp(QuestionTopic question, String path);
  void nothingFollowUp();
}

abstract class CountDownListener {
  void onCountDown(String strCount);
  void onSkip();
}

abstract class SubmitHomeWorkCallBack {
  void submitHomeWorkSuccess(String message);
  void submitHomeWorkFail(AlertInfo alertInfo);
}

abstract class CreateActivityCallBack {
  void failToCreateActivity(String message);
}

/////////////////////////////MY TEST DETAIL////////////////////////////////////

abstract class GetMyTestDetailCallBack {
  void myTestDetail();
  void getMyTestFail(String message);
}

abstract class CreateResultVideoCallBack {
  void playNextQuestion();
}

abstract class ResultResponseTestCallBack {
  void resultResponseDetail(ResultResponse response);
  void failToGetResultResponse(String message);
}

abstract class GetHomeWorksByTypeCallBack {
  void homeworksByType(List<StudentsResults> studentsResults);
  void failToHomeWorksByType(String message);
}
