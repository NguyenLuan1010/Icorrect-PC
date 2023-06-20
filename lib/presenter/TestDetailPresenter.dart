import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';


import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../callbacks/AuthenticationCallBack.dart';
import '../callbacks/ViewMainCallBack.dart';
import '../data/api/APIHelper.dart';
import '../data/api/Repositories.dart';
import '../data/locals/DeviceStorage.dart';
import '../data/locals/LocalStorage.dart';
import '../data/locals/SharedRef.dart';
import 'package:http/http.dart' as http;

import '../models/Enums.dart';
import '../models/others/Users.dart';
import '../models/test_simulator/FileTopic.dart';
import '../models/test_simulator/QuestionTopic.dart';
import '../models/test_simulator/TestDetail.dart';
import '../models/test_simulator/Topic.dart';
import 'package:path/path.dart';

import '../models/ui/AlertInfo.dart';
import '../provider/VariableProvider.dart';

class TestDetailPresenter {
  AlertInfo alertInfo = AlertInfo('Fail to get your test',
      'Please check your internet and try again !', Alert.NETWORK_ERROR.type);
  Future requestTestDetail(
      String activityId, RequestTestDetailCallBack callBack) async {
    String url = APIHelper.init().apiTopicDetail();
    Users? user = await SharedRef.instance().getUser();
    try {
      Response response = await Repositories.init().sendRequest(
          APIHelper.POST, url, true, body: <String, dynamic>{
        'activity_id': activityId,
        'distribute_code': user!.distributeCode.toString()
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == APIHelper.RESPONSE_OK) {
        Map<String, dynamic> dataMap = json.decode(response.body)['data'] ?? [];

        if (dataMap.isNotEmpty) {
          callBack.startDownloadFile(dataMap);
        } else {
          AlertInfo alertInfo = AlertInfo(
              'Your test is empty',
              'Please contact to Icorrect team for assistance!',
              Alert.SERVER_ERROR.type);
          callBack.errorRequestTestDetail(alertInfo);
        }
      } else {
        callBack.errorRequestTestDetail(alertInfo);
      }
    } on TimeoutException {
      callBack.errorRequestTestDetail(alertInfo);
    } on SocketException {
      callBack.errorRequestTestDetail(alertInfo);
    } on ClientException {
      callBack.errorRequestTestDetail(alertInfo);
    }
  }

  Future<TestDetail> getTestDetail(
      Map<String, dynamic> dataMap, DownloadFileListener listener) async {
    List<FileTopic> filesTopic = [];

    TestDetail testDetail = TestDetail();

    testDetail.testId = jsonEncode(dataMap['test_id']);
    testDetail.checkSum = jsonEncode(dataMap['check_sum']);
    testDetail.domainName = jsonEncode(dataMap['domain_name']);

    if (dataMap['introduce'] != null) {
      Topic introduceTopic =
          _getTopic(PartOfTest.INTRODUCE.get, dataMap['introduce'] ?? {});
      testDetail.introduce = introduceTopic;

      filesTopic.addAll(allfilesOfTopic(introduceTopic));
    }

    if (dataMap['part1'] != null) {
      List<dynamic> part1 = dataMap['part1'] ?? [];
      List<Topic> listPart1 = [];
      for (int i = 0; i < part1.length; i++) {
        Topic topicDetail = _getTopic(PartOfTest.PART1.get, part1[i] ?? {});
        listPart1.add(topicDetail);
        filesTopic.addAll(allfilesOfTopic(topicDetail));
      }
      testDetail.part1 = listPart1;
    }

    if (dataMap['part2'] != null && dataMap['part2']['id'] != null) {
      Topic topicPart2 =
          _getTopic(PartOfTest.PART2.get, dataMap['part2'] ?? {});
      testDetail.part2 = topicPart2;
      filesTopic.addAll(allfilesOfTopic(topicPart2));
    }

    if (dataMap['part3'] != null) {
      Topic topicPart3 =
          _getTopic(PartOfTest.PART3.get, dataMap['part3'] ?? {});
      testDetail.part3 = topicPart3;

      filesTopic.addAll(allfilesOfTopic(topicPart3));
    }

    DeviceStorage.init().downloadFiles(testDetail, filesTopic, listener);
    return testDetail;
  }

  List<FileTopic> allfilesOfTopic(Topic topic) {
    List<FileTopic> allFiles = [];
    allFiles.addAll(topic.files ?? []);
    for (QuestionTopic q in topic.questions ?? []) {
      allFiles.add(q.files!.first);
      allFiles.addAll(q.answers ?? []);
    }
    for (QuestionTopic q in topic.followUp ?? []) {
      allFiles.add(q.files!.first);
      allFiles.addAll(q.answers ?? []);
    }
    if (topic.fileEndOfTest!.url.toString().isNotEmpty) {
      allFiles.add(topic.fileEndOfTest!);
    }

    return allFiles;
  }

  Topic _getTopic(int numOfPart, Map<String, dynamic> dataMap) {
    String id = dataMap['id'].toString();
    String title = dataMap['title'].toString();
    String description = dataMap['description'].toString();
    String topicType = dataMap['topic_type'].toString();
    String status = dataMap['status'].toString();
    String level = dataMap['level'].toString();
    String staffCreated = dataMap['staff_created'].toString();
    String staffUpdated = dataMap['staff_updated'].toString();
    String updatedAt = dataMap['updated_at'].toString();
    String createdAt = dataMap['created_at'].toString();
    String deletedAt = dataMap['deleted_at'].toString();
    String distributeCode = dataMap['distribute_code'].toString();

    List<QuestionTopic> questions = [];
    if (dataMap['questions'] != null) {
      questions = _questionsTopic(numOfPart, dataMap['questions'] ?? []);
    }

    List<FileTopic> files = _getIntroFile(dataMap['files'] ?? []);

    List<QuestionTopic> followUp = [];
    if (dataMap['followup'] != null) {
      followUp = (dataMap['followup'].toString().isNotEmpty)
          ? _questionsTopic(numOfPart, dataMap['followup'] ?? [])
          : [];
    }

    Map<String, dynamic> endOfTest =
        dataMap['end_of_take_note'] ?? dataMap['end_of_test'] ?? {};

    FileTopic fileEnd;
    if (endOfTest.isNotEmpty) {
      print('end of test: ${endOfTest['url'].toString()}');
      fileEnd = FileTopic(endOfTest['id'] ?? '',
          url: endOfTest['url'] ?? '', type: endOfTest['type'] ?? '');
    } else {
      fileEnd = FileTopic('', url: '', type: '');
    }

    return Topic(
        numOfPart,
        id,
        title,
        description,
        topicType,
        status,
        level,
        staffCreated,
        staffUpdated,
        updatedAt,
        createdAt,
        deletedAt,
        distributeCode,
        jsonEncode(dataMap),
        followUp,
        endOfTest,
        fileEnd,
        questions,
        files);
  }

  List<QuestionTopic> _questionsTopic(int numPart, List<dynamic> data) {
    List<QuestionTopic> questions = [];
    for (int i = 0; i < data.length; i++) {
      dynamic item = data[i];

      String id = item['id'].toString();
      String content = item['content'].toString();
      String type = item['type'].toString();
      String topicId = item['topic_id'].toString();
      String isFollowUp = item['is_follow_up'].toString();
      String cueCard =
          (item['cue_card'] != null) ? item['cue_card'].toString() : '';
      String tips = (item['tips'] != null) ? item['tips'].toString() : '';
      String tipType = item['tip_type'].toString();
      List<FileTopic> files = _getIntroFile(item['files'] ?? []);

      List<FileTopic> answers =
          (item['answer'] != null) ? _getAnswerFile(item['answer']) : [];

      int reanswer = (item['reanswer'] != null)
          ? int.parse(item['reanswer'].toString())
          : 0;

      questions.add(QuestionTopic(id, content, type, reanswer, topicId, false,
          cueCard, tips, tipType, answers, files, numPart));
    }
    return questions;
  }

////////////////////////////////////////////////////////////////////////////////

  AlertInfo alertTestDetailNetWork = AlertInfo('Fail to get Test Detail',
      'Please check your internet and try again !', Alert.NETWORK_ERROR.type);
  AlertInfo alertErrorByServer = AlertInfo(
      'Fail to get Test Detail',
      'Something went wrong. Please contact with admin to support!',
      Alert.SERVER_ERROR.type);
  Future<Map<String, dynamic>> requestTopicDetail(
      String activityId, GetTopicDetailCallBack callBack) async {
    String url = APIHelper.init().apiTopicDetail();
    Users? user = await SharedRef.instance().getUser();

    try {
      Response response = await Repositories.init().sendRequest(
          APIHelper.POST, url, true, body: <String, dynamic>{
        'activity_id': activityId,
        'distribute_code': user!.distributeCode.toString()
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode != APIHelper.RESPONSE_OK) {
        callBack.errorWhenLoad(alertTestDetailNetWork);
        return {};
      }
      Map<String, dynamic> dataMap = json.decode(response.body)['data'] ?? [];

      if (dataMap.isEmpty) {
        callBack.errorWhenLoad(alertErrorByServer);
        return {};
      }
      return dataMap;
    } on TimeoutException {
      callBack.errorWhenLoad(alertTestDetailNetWork);
    } on SocketException {
      callBack.errorWhenLoad(alertTestDetailNetWork);
    } on ClientException {
      callBack.errorWhenLoad(alertTestDetailNetWork);
    }
    return {};
  }

  Future<TestDetail> getTestPart(
      Map<String, dynamic> dataMap, GetTopicDetailCallBack callBack,
      {int? goDownLoad}) async {
    TestDetail testDetail = TestDetail();

    testDetail.testId = jsonEncode(dataMap['test_id']);
    testDetail.checkSum = jsonEncode(dataMap['check_sum']);
    testDetail.domainName = jsonEncode(dataMap['domain_name']);

    String strIntroduce = jsonEncode(dataMap['introduce']);
    if (strIntroduce.isNotEmpty && goDownLoad == PartOfTest.INTRODUCE.get) {
      Topic introduceTopic =
          getEachPart(PartOfTest.INTRODUCE.get, dataMap['introduce'] ?? {});
      testDetail.introduce = introduceTopic;
      callBack.getIntroduce(introduceTopic);
    }

    if (dataMap['part1'] != null) {
      List<dynamic> part1 = dataMap['part1'] ?? [];
      if (part1.isNotEmpty) {
        List<Topic> topicPart1 = getPartI(PartOfTest.PART1.get, part1);
        testDetail.part1 = topicPart1;
        (topicPart1.isNotEmpty) ? callBack.getPartI(topicPart1) : {};
      }
    }

    if (dataMap['part2'] != null) {
      String part2 = jsonEncode(dataMap['part2'] ?? '');
      if (part2.isNotEmpty) {
        Topic topicPart2 =
            getEachPart(PartOfTest.PART2.get, dataMap['part2'] ?? {});
        testDetail.part2 = topicPart2;
        (topicPart2.id != null) ? callBack.getpartII(topicPart2) : {};
      }
    }

    if (dataMap['part3'] != null) {
      String part3 = jsonEncode(dataMap['part3'] ?? '');
      if (part3.isNotEmpty) {
        Topic topicPart3 =
            getEachPart(PartOfTest.PART3.get, dataMap['part3'] ?? {});
        testDetail.part3 = topicPart3;
        (topicPart3.id != null) ? callBack.getPartIII(topicPart3) : {};
      }
    }

    return testDetail;
  }

  Topic getEachPart(int numOfPart, Map<String, dynamic> dataMap) {
    String id = dataMap['id'].toString();
    String title = dataMap['title'].toString();
    String description = dataMap['description'].toString();
    String topicType = dataMap['topic_type'].toString();
    String status = dataMap['status'].toString();
    String level = dataMap['level'].toString();
    String staffCreated = dataMap['staff_created'].toString();
    String staffUpdated = dataMap['staff_updated'].toString();
    String updatedAt = dataMap['updated_at'].toString();
    String createdAt = dataMap['created_at'].toString();
    String deletedAt = dataMap['deleted_at'].toString();
    String distributeCode = dataMap['distribute_code'].toString();

    List<QuestionTopic> questions =
        _getQuestion(numOfPart, dataMap['questions'] ?? []);

    List<FileTopic> files = _getIntroFile(dataMap['files'] ?? []);

    List<QuestionTopic> followUp = (dataMap['followup'].toString().isNotEmpty)
        ? _getQuestion(numOfPart, dataMap['followup'] ?? [])
        : [];

    Map<String, dynamic> endOfTest =
        dataMap['end_of_take_note'] ?? dataMap['end_of_test'] ?? {};
    FileTopic dd = FileTopic(id, url: url, type: '');
    return Topic(
        numOfPart,
        id,
        title,
        description,
        topicType,
        status,
        level,
        staffCreated,
        staffUpdated,
        updatedAt,
        createdAt,
        deletedAt,
        distributeCode,
        jsonEncode(dataMap),
        followUp,
        endOfTest,
        dd,
        questions,
        files);
  }

  List<QuestionTopic> _getQuestion(int numPart, List<dynamic> data) {
    List<QuestionTopic> questions = [];
    for (int i = 0; i < data.length; i++) {
      dynamic item = data[i];

      String id = item['id'].toString();
      String content = item['content'].toString();
      String type = item['type'].toString();
      String topicId = item['topic_id'].toString();
      String isFollowUp = item['is_follow_up'].toString();
      String cueCard =
          (item['cue_card'] != null) ? item['cue_card'].toString() : '';
      String tips = (item['tips'] != null) ? item['tips'].toString() : '';
      String tipType = item['tip_type'].toString();
      List<FileTopic> files = _getIntroFile(item['files']);

      List<FileTopic> answers =
          (item['answer'] != null) ? _getAnswerFile(item['answer']) : [];

      int reanswer = (item['reanswer'] != null)
          ? int.parse(item['reanswer'].toString())
          : 0;

      questions.add(QuestionTopic(id, content, type, reanswer, topicId, false,
          cueCard, tips, tipType, answers, files, numPart));
    }
    return questions;
  }

  List<FileTopic> _getIntroFile(List<dynamic> data) {
    List<FileTopic> files = [];
    for (int i = 0; i < data.length; i++) {
      dynamic item = data[i];
      files.add(FileTopic(item['id'], url: item['url'], type: item['type']));
    }
    return files;
  }

  List<FileTopic> _getAnswerFile(List<dynamic> data) {
    int defaultValue = 0;
    List<FileTopic> files = [];
    for (int i = 0; i < data.length; i++) {
      dynamic item = data[i];
      files.add(FileTopic(item['file_id'],
          url: item['file_link'], type: defaultValue));
    }
    return files;
  }

  List<Topic> getPartI(int numOfPart, List<dynamic> data) {
    List<Topic> listPartI = [];
    for (int i = 0; i < data.length; i++) {
      Topic topicDetail = getEachPart(numOfPart, data[i] ?? {});
      listPartI.add(topicDetail);
    }
    return listPartI;
  }

  Future<void> fileIntroPlayer(
      List<FileTopic> files, FilesIntroListener listener) async {
    if (files.isNotEmpty) {
      FileTopic file = files.first;

      String nameFile =
          DeviceStorage.init().nameFileConvert(file.getUrl.toString());
      bool isExistFile =
          await DeviceStorage.init().isExistFile(nameFile, DeviceStorage.VIDEO);
      String pathFile = await _videoPath(nameFile);
      print('introduce path : $pathFile');
      if (isExistFile) {
        String pathFile = await _videoPath(nameFile);
        listener.playIntro(pathFile);
      } else {
        listener.nothingFileIntroduce();
      }
    } else {
      print('nothing icorr 2');
      listener.nothingIntroduce();
    }
  }

  Future<void> fileQuestionsPlayer(
      Topic test, List<QuestionTopic> questions, FilesQuestionListener listener,
      {required int index, required bool isReanswer}) async {
    if (questions.isNotEmpty) {
      QuestionTopic question = questions.elementAt(index);
      FileTopic file = (isReanswer)
          ? ((question.files!.length >= 2)
              ? question.files![1]
              : question.files![0])
          : question.files![0];

      String nameFile =
          DeviceStorage.init().nameFileConvert(file.getUrl.toString());
      String pathFile = await _videoPath(nameFile);
      print('question path : $pathFile');
      bool isExistFile =
          await DeviceStorage.init().isExistFile(nameFile, DeviceStorage.VIDEO);
      if (isExistFile) {
        String pathFile = await _videoPath(nameFile);
        listener.playQuestion(question, pathFile);
      } else {
        print('nothing question');

        listener.nothingFileQuestion();
      }
    } else {
      print('nothing question');

      listener.nothingQuestion();
    }
  }

  Future<void> fileEndOfTest(Topic topic, EndOfTestListener listener) async {
    FileTopic data = topic.fileEndOfTest!;
    print('part end : ${topic.numPart.toString()}');

    if (data.getUrl.toString().isNotEmpty) {
      String nameFile =
          DeviceStorage.init().nameFileConvert(data.getUrl.toString());
      bool isExistFile =
          await DeviceStorage.init().isExistFile(nameFile, DeviceStorage.VIDEO);
      String pathFile = await _videoPath(nameFile);
      print('end of test path : $pathFile');
      if (isExistFile) {
        String pathFile = await _videoPath(nameFile);
        listener.playEndOfTest(pathFile);
      } else {
        print('nothing end of test 1');
        listener.nothingFileEndOfTest();
      }
    } else {
      print('nothing end of test 2');
      listener.nothingEndOfTest();
    }
  }

  Future<String> _videoPath(String nameFile) async {
    // ignore: prefer_interpolation_to_compose_strings
    return await DeviceStorage.init().rootPath() +
        '\\${DeviceStorage.VIDEO}' +
        '\\${DeviceStorage.init().nameFileConvert(nameFile)}';
  }

  Timer startCountDown(
      BuildContext context, int count, CountDownListener listener) {
    const oneSec = Duration(seconds: 1);
    return Timer.periodic(oneSec, (Timer timer) {
      if (count < 1) {
        timer.cancel();
      } else {
        count = count - 1;
      }

      dynamic minutes = count ~/ 60;
      dynamic seconds = count % 60;

      dynamic minuteStr = minutes.toString().padLeft(2, '0');
      dynamic secondStr = seconds.toString().padLeft(2, '0');

      listener.onCountDown("$minuteStr:$secondStr");

      if (count == 0) {
        listener.onSkip();
      }
    });
  }

  ///////////////////////////////SUBMIT HOMEWORK////////////////////////////////

  AlertInfo alertServerError = AlertInfo(
      'Fail to save the homework.',
      "Please contact to Icorrect Admin for support !",
      Alert.SERVER_ERROR.type);

  AlertInfo alertNetWorkError = AlertInfo('Fail to save the homework.',
      "Please check your internet and try again !", Alert.NETWORK_ERROR.type);

  Future<void> submitHomeWork(
      String testId,
      String activityId,
      List<QuestionTopic> answerQuestions,
      SubmitHomeWorkCallBack callBack) async {
    Map<String, String> formData = {};
    String url = APIHelper.init().apiSubmitHomeWork();
    var request = http.MultipartRequest(APIHelper.POST, Uri.parse(url));

    String accessToken = await Repositories.init().getToken() ?? '';

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $accessToken'
    });

    formData.addEntries([MapEntry('test_id', testId)]);
    formData.addEntries([MapEntry('activity_id', activityId)]);

    if (Platform.isMacOS) {
      formData.addEntries([const MapEntry('os', "macos")]);
    } else {
      formData.addEntries([const MapEntry('os', "windows")]);
    }
    formData.addEntries([const MapEntry('app_version', '2.0.2')]);
    String format = '';
    String reanswerFormat = '';
    String endFormat = '';
    for (QuestionTopic q in answerQuestions) {
      String questionId = q.id.toString();
      if (q.numPart == PartOfTest.INTRODUCE.get) {
        format = 'introduce[$questionId]';
        reanswerFormat = 'reanswer_introduce[$questionId]';
      }

      if (q.numPart == PartOfTest.PART1.get) {
        format = 'part1[$questionId]';
      
        reanswerFormat = 'reanswer_part1[$questionId]';
      }

      if (q.numPart == PartOfTest.PART2.get) {
        format = 'part2[$questionId]';
        reanswerFormat = 'reanswer_part2[$questionId]';
      }

      if (q.numPart == PartOfTest.PART3.get && !q.is_follows_up!) {
        format = 'part3[$questionId]';
        reanswerFormat = 'reanswer_part3[$questionId]';
      }
      if (q.numPart == PartOfTest.PART3.get && q.is_follows_up!) {
        format = 'followup[$questionId]';
        reanswerFormat = 'reanswer_followup[$questionId]';
      }

      formData
          .addEntries([MapEntry(reanswerFormat, q.reanswer_count.toString())]);

      for (int i = 0; i < q.answers!.length; i++) {
        print('audio send: ${q.answers!.elementAt(i).getUrl.toString()}');
        endFormat = '$format[$i]';
        File audioFile =
            File('${q.answers!.elementAt(i).getUrl.toString()}.wav');

        if (await audioFile.exists()) {
          request.files.add(
              await http.MultipartFile.fromPath(endFormat, audioFile.path));

          formData.addEntries([MapEntry(endFormat, basename(audioFile.path))]);
        }
      }
    }

    request.fields.addAll(formData);

    try {
      StreamedResponse strResponse =
          await request.send().timeout(const Duration(seconds: 10));

      if (strResponse.statusCode == APIHelper.RESPONSE_OK) {
        var response = await http.Response.fromStream(strResponse)
            .timeout(const Duration(seconds: 10));
        Map<String, dynamic> resMap = jsonDecode(response.body) ?? {};
        if (resMap['error_code'] == APIHelper.RESPONSE_OK &&
            resMap['status'] == APIHelper.RESPONSE_SUCCESS) {
          callBack.submitHomeWorkSuccess("Save the homework successfully !");
        } else {
          callBack.submitHomeWorkFail(alertServerError);
        }
        // var responseData = await strResponse.stream.toBytes();
        // var responseString = utf8.decode(responseData);
        // print(responseString);
      } else {
        callBack.submitHomeWorkFail(alertNetWorkError);
      }
    } on TimeoutException {
      callBack.submitHomeWorkFail(alertNetWorkError);
    } on SocketException {
      callBack.submitHomeWorkFail(alertNetWorkError);
    } on ClientException {
      callBack.submitHomeWorkFail(alertNetWorkError);
    }
  }
}
