import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../callbacks/AuthenticationCallBack.dart';
import '../callbacks/ViewMainCallBack.dart';
import '../data/api/APIHelper.dart';
import '../data/api/Repositories.dart';
import '../data/locals/DeviceStorage.dart';
import '../data/locals/LocalStorage.dart';
import '../data/locals/SharedRef.dart';
import '../models/Enums.dart';
import '../models/my_test/ActivityResult.dart';
import '../models/my_test/ResultResponse.dart';
import '../models/my_test/SkillFileDetail.dart';
import '../models/my_test/SkillProblem.dart';
import '../models/my_test/StudentsResults.dart';
import '../models/others/HomeWorks.dart';
import '../models/others/Students.dart';
import '../models/others/Users.dart';
import '../models/test_simulator/FileTopic.dart';
import '../models/test_simulator/QuestionTopic.dart';
import '../models/test_simulator/TestDetail.dart';
import '../models/test_simulator/Topic.dart';
import '../models/ui/AlertInfo.dart';
import '../provider/VariableProvider.dart';
import 'TestDetailPresenter.dart';

class MyTestPresenter {
  AlertInfo alertNetWork = AlertInfo('Fail to get your test',
      'Please check your internet and try again !', Alert.NETWORK_ERROR.type);
  AlertInfo alertAdmin = AlertInfo(
      'Your test is empty',
      'Please contact to Icorrect team for assistance!',
      Alert.SERVER_ERROR.type);
  Future<void> getMyTestDetail(
      HomeWorks homeWork, DownloadFileListener callback) async {
    String url = APIHelper.init().apiMyTestDetail(homeWork.testID.toString());
    try {
      Response response =
          await Repositories.init().sendRequest(APIHelper.GET, url, true);
      if (response.statusCode == APIHelper.RESPONSE_OK) {
        Map<String, dynamic> reposMap = jsonDecode(response.body);
        if (reposMap['error_code'] == APIHelper.RESPONSE_OK &&
            reposMap['status'] == APIHelper.RESPONSE_SUCCESS) {
          Map<String, dynamic> dataMap =
              json.decode(response.body)['data'] ?? [];
          _getTestDetail(dataMap, callback);
        } else {
          callback.failDownload(alertAdmin);
        }
      } else {
        callback.failDownload(alertNetWork);
      }
    } on TimeoutException {
      callback.failDownload(alertNetWork);
    } on SocketException {
      callback.failDownload(alertNetWork);
    } on ClientException {
      callback.failDownload(alertNetWork);
    }
  }

  TestDetail _getTestDetail(
      Map<String, dynamic> dataMap, DownloadFileListener callback) {
    Map<String, dynamic> testMap = dataMap['test'];

    TestDetail testDetail = TestDetail();

    testDetail.id = jsonEncode(dataMap['_id']);
    testDetail.status = jsonEncode(dataMap['status']);
    testDetail.checkSum = jsonEncode(dataMap['check_sum']);
    testDetail.testId = jsonEncode(dataMap['test_id']);
    testDetail.activityType = jsonEncode(testMap['activity_type']);
    testDetail.testOption = jsonEncode(testMap['test_option']);
    testDetail.updateAt = jsonEncode(dataMap['updated_at']);
    testDetail.hasOrder = jsonEncode(dataMap['has_order']);

    TestDetailPresenter presenter = TestDetailPresenter();
    List<FileTopic> filesTopic = [];
    if (testMap['introduce'] != null) {
      Topic introduceTopic = presenter.getEachPart(
          PartOfTest.INTRODUCE.get, testMap['introduce'] ?? {});
      testDetail.introduce = introduceTopic;
      //LocalStorage.init().downloadData(introduceTopic, callback: callback);
      filesTopic.addAll(presenter.allfilesOfTopic(introduceTopic));
    }

    if (testMap['part1'] != null) {
      List<dynamic> part1 = testMap['part1'] ?? [];
      List<Topic> topicPart1 = presenter.getPartI(PartOfTest.PART1.get, part1);
      testDetail.part1 = topicPart1;
      for (Topic t in topicPart1) {
        // LocalStorage.init().downloadData(t, callback: callback);
        filesTopic.addAll(presenter.allfilesOfTopic(t));
      }
    }

    if (testMap['part2'] != null) {
      Topic topicPart2 =
          presenter.getEachPart(PartOfTest.PART2.get, testMap['part2'] ?? {});
      testDetail.part2 = topicPart2;
      // LocalStorage.init().downloadData(topicPart2, callback: callback);
      filesTopic.addAll(presenter.allfilesOfTopic(topicPart2));
    }

    if (testMap['part3'] != null) {
      Topic topicPart3 =
          presenter.getEachPart(PartOfTest.PART3.get, testMap['part3'] ?? {});
      testDetail.part3 = topicPart3;
      // LocalStorage.init().downloadData(topicPart3, callback: callback);
      filesTopic.addAll(presenter.allfilesOfTopic(topicPart3));
    }

    DeviceStorage.init().downloadFiles(testDetail, filesTopic, callback);

    return testDetail;
  }

  Future createResultVideo(
      BuildContext context,
      List<QuestionTopic> questions,
      int index,
      VideoPlayerController? controller,
      AudioPlayer? audioPlayer,
      CreateResultVideoCallBack callBack) async {
    QuestionTopic question = questions.elementAt(index);
    String videoPath = question.files!.elementAt(0).getUrl;
    String answerPath = question.answers!.last.getUrl;

    controller = VideoPlayerController.file(File(videoPath))..initialize();

    controller.value.isPlaying ? controller.pause() : controller.play();
    controller.addListener(() {
      if (!controller!.value.size.isEmpty) {
        if (controller.value.position == controller.value.duration) {
          playAnswer(audioPlayer!, answerPath, callBack);
        }
      }
    });

    Provider.of<VariableProvider>(context, listen: false)
        .setPlayController(controller);
  }

  Future playAnswer(AudioPlayer? audioPlayer, String answerPath,
      CreateResultVideoCallBack callBack) async {
    await audioPlayer!.play(DeviceFileSource(answerPath));
    await audioPlayer.setVolume(2.5);

    audioPlayer.onPlayerComplete.listen((event) {
      callBack.playNextQuestion();
    });
  }

  //////////////////////////Response Result ////////////////////////////////////

  Future getResultResponse(
      HomeWorks homeWork, ResultResponseTestCallBack callBack) async {
    String url = APIHelper.init().apiResponse(homeWork.orderId.toString());
    Response response = await Repositories.init()
        .sendRequest(APIHelper.GET, url, true)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == APIHelper.RESPONSE_OK) {
      Map<String, dynamic> resultMap = jsonDecode(response.body) ?? {};
      if (resultMap.isNotEmpty) {
        ResultResponse result = await _getResultResponse(resultMap);
        callBack.resultResponseDetail(result);
      } else {
        callBack.failToGetResultResponse("Fail to get your result response!");
      }
    } else {
      callBack.failToGetResultResponse(
          "Somthing went wrong when request. Try again!");
    }
  }

  Future<ResultResponse> _getResultResponse(
      Map<String, dynamic> resultMap) async {
    return ResultResponse(
      resultMap['id'] ?? '',
      resultMap['order_id'] ?? '',
      resultMap['overall_score'] ?? '',
      resultMap['fluency'] ?? '',
      resultMap['lexical_resource'] ?? '',
      resultMap['grammatical'] ?? '',
      resultMap['pronunciation'] ?? '',
      resultMap['overall_comment'] ?? '',
      resultMap['staff_created'] ?? '',
      resultMap['staff_updated'] ?? '',
      resultMap['updated_at'] ?? '',
      resultMap['created_at'] ?? '',
      resultMap['deleted_at'] ?? '',
      resultMap['status'] ?? '',
      await _getSkillsProblem(resultMap['fluency_problem'] ?? []) ?? [],
      await _getSkillsProblem(resultMap['lexical_resource_problem'] ?? []) ??
          [],
      await _getSkillsProblem(resultMap['grammatical_problem'] ?? []) ?? [],
      await _getSkillsProblem(resultMap['pronunciation_problem'] ?? []) ?? [],
      resultMap['order_type'] ?? '',
    );
  }

  Future<List<SkillProblem>?> _getSkillsProblem(
      List<dynamic> problemList) async {
    List<SkillProblem> skillsProblem = [];
    for (int i = 0; i < problemList.length; i++) {
      Map<String, dynamic> problemMap = problemList[i];
      skillsProblem.add(SkillProblem(
          problemMap['id'] ?? '',
          problemMap['problem'] ?? '',
          problemMap['solution'] ?? '',
          problemMap['type'] ?? '',
          problemMap['order_id'] ?? '',
          problemMap['component'] ?? '',
          problemMap['file_id'] ?? '',
          problemMap['example_text'] ?? '',
          problemMap['updated_at'] ?? '',
          problemMap['created_at'] ?? '',
          problemMap['deleted_at'] ?? '',
          problemMap['type_name'] ?? '',
          problemMap['file_name'] ?? '',
          await _getSkillFileDetail(problemMap['file'] ?? {}) ??
              SkillFileDetail()));
    }
    return skillsProblem;
  }

  Future<SkillFileDetail?> _getSkillFileDetail(
      Map<String, dynamic> fileMap) async {
    return SkillFileDetail(
      fileMap['id'] ?? '',
      fileMap['url'] ?? '',
      fileMap['file_name'] ?? '',
      fileMap['description'] ?? '',
      fileMap['type'] ?? '',
      fileMap['created_by'] ?? '',
      fileMap['updated_by'] ?? '',
      fileMap['updated_at'] ?? '',
      fileMap['created_at'] ?? '',
      fileMap['deleted_at'] ?? '',
      fileMap['staff_id'] ?? '',
      fileMap['distribute_code'] ?? '',
    );
  }

  ///////////////////////////HIGHLIGHT TEST/////////////////////////////////////
  Future getHighLightHomeWorks(String activityId, int typeTest,
      GetHomeWorksByTypeCallBack callBack) async {
    Users? user = await SharedRef.instance().getUser();
    String url = (typeTest == Status.HIGHTLIGHT.get)
        ? APIHelper.init()
            .apiHighLightHomeWork(user!.email.toString(), activityId)
        : APIHelper.init()
            .apiOtherHomeWorks(user!.email.toString(), activityId);
    Response response =
        await Repositories.init().sendRequest(APIHelper.GET, url, true);
    if (response.statusCode == APIHelper.RESPONSE_OK) {
      Map<String, dynamic> dataMap = jsonDecode(response.body);
      if (dataMap.isEmpty) {
        callBack.failToHomeWorksByType(
            'Something went wrong. Please contact to Admin Icorrect for support !');
      } else {
        List<StudentsResults> studentsResults =
            _studentResultsList(dataMap['data'] ?? []);
        callBack.homeworksByType(studentsResults);
      }
    } else {
      callBack
          .failToHomeWorksByType('Something went wrong when request to get !');
    }
  }

  List<StudentsResults> _studentResultsList(List<dynamic> resultsData) {
    List<StudentsResults> studentResults = [];
    for (int i = 0; i < resultsData.length; i++) {
      dynamic item = resultsData[i];
      Students studentInfo = _studentsInfo(item['student']);
      ActivityResult activity = _activityResult(item['activity']);
      studentResults.add(StudentsResults(
          item['id'] ?? '',
          item['activity_id'] ?? '',
          item['test_id'] ?? '',
          item['email'] ?? '',
          item['created_at'] ?? '',
          item['updated_at'] ?? '',
          item['order_id'] ?? '',
          item['publish_response'] ?? '',
          item['overall_score'] ?? '',
          item['pushlis'] ?? '',
          item['real_activity_id'] ?? '',
          item['example'] ?? '',
          item['teacher_id'] ?? '',
          item['ai_order'] ?? '',
          item['ai_score'] ?? '',
          studentInfo,
          activity,
          item['status'] ?? '',
          item['teacher_name'] ?? ''));
    }
    return studentResults;
  }

  Students _studentsInfo(dynamic itemData) {
    return Students(
        itemData['id'] ?? '',
        itemData['name'] ?? '',
        itemData['email'] ?? '',
        itemData['email_verified_at'] ?? '',
        itemData['created_at'] ?? '',
        itemData['updated_at'] ?? '',
        itemData['invite_code'] ?? '',
        itemData['phone'] ?? '',
        itemData['rule'] ?? '',
        itemData['age'] ?? '',
        itemData['address'] ?? '',
        itemData['deleted_at'] ?? '',
        itemData['center_id'] ?? '',
        itemData['api_id'] ?? '',
        itemData['class_id'] ?? '',
        itemData['uuid'] ?? '',
        itemData['can_create_mybank'] ?? '',
        itemData['student_class_name'] ?? '',
        itemData['province'] ?? '');
  }

  ActivityResult _activityResult(dynamic itemData) {
    return ActivityResult(
        itemData['id'] ?? '',
        itemData['name'] ?? '',
        itemData['type'] ?? '',
        itemData['test'] ?? '',
        itemData['start_date'] ?? '',
        itemData['start_time'] ?? '',
        itemData['end_time'] ?? '',
        itemData['end_date'] ?? '',
        itemData['giaotrinh_id'] ?? '',
        itemData['status'] ?? '',
        itemData['created_at'] ?? '',
        itemData['updated_at'] ?? '',
        itemData['activity_id'] ?? '',
        itemData['tips'] ?? '',
        itemData['cost'] ?? '',
        itemData['bank_clone'] ?? '',
        itemData['send_email'] ?? '',
        itemData['uuid'] ?? '',
        itemData['activity_bank_my_bank'] ?? '',
        itemData['package_id'] ?? '',
        itemData['bank'] ?? '',
        itemData['bank_name'] ?? '',
        itemData['question'] ?? '',
        itemData['bank_type'] ?? '',
        itemData['bank_distribute_code'] ?? '',
        itemData['is_tested'] ?? '',
        itemData['activity_type'] ?? '',
        itemData['question_index'] ?? '');
  }
}
