import 'dart:convert';

import 'package:http/http.dart';

import '../callbacks/ViewMainCallBack.dart';
import '../data/api/APIHelper.dart';
import '../data/api/Repositories.dart';
import '../data/locals/SharedRef.dart';
import '../models/Enums.dart';
import '../models/others/Users.dart';
import '../models/test_simulator/FileTopic.dart';
import '../models/test_simulator/QuestionTopic.dart';
import '../models/test_simulator/TestDetail.dart';
import '../models/test_simulator/Topic.dart';

class TestPresenter {
  Future<void> requestTopicDetail(
      String activityId, CreateActivityCallBack callBack) async {
    String url = APIHelper.init().apiTopicDetail();
    Users? user = await SharedRef.instance().getUser();
    Response response = await Repositories.init().sendRequest(
        APIHelper.POST, url, true, body: <String, dynamic>{
      'activity_id': activityId,
      'distribute_code': user!.distributeCode.toString()
    });

    if (response.statusCode == APIHelper.RESPONSE_OK) {
      Map<String, dynamic> dataMap = json.decode(response.body)['data'] ?? [];

      if (dataMap.isNotEmpty) {
        
      } else {
        callBack.failToCreateActivity('Please contact with Admin to support !');
      }
    } else {
      callBack.failToCreateActivity('Something went wrong !');
    }
  }

  Future<TestDetail> getEachTopic(Map<String, dynamic> dataMap) async {
    TestDetail testDetail = TestDetail();
    testDetail.testId = jsonEncode(dataMap['test_id'] ?? '');
    testDetail.checkSum = jsonEncode(dataMap['check_sum'] ?? '');
    testDetail.domainName = jsonEncode(dataMap['domain_name'] ?? '');

    if (dataMap['introduce'] ?? {}.isNotEmpty) {
      Topic introduceTopic =
          getEachPart(PartOfTest.INTRODUCE.get, dataMap['introduce'] ?? {});
      testDetail.introduce = introduceTopic;
    }

    if (dataMap['part1'] ?? [].isNotEmpty) {
      List<Topic> topicPart1 =
          getPartI(PartOfTest.PART1.get, dataMap['part1'] ?? []);
      testDetail.part1 = topicPart1;
    }

    if (dataMap['part2'] ?? {}.isNotEmpty) {
      Topic topicPart2 =
          getEachPart(PartOfTest.PART2.get, dataMap['part2'] ?? {});
      testDetail.part2 = topicPart2;
    }

    if (dataMap['part3'] ?? {}.isNotEmpty) {
      Topic topicPart3 =
          getEachPart(PartOfTest.PART3.get, dataMap['part3'] ?? {});
      testDetail.part3 = topicPart3;
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
        FileTopic dd =FileTopic(id, url: 'd', type: '');

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
}
