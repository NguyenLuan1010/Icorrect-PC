import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import '../callbacks/ViewMainCallBack.dart';
import '../data/api/APIHelper.dart';
import '../data/api/Repositories.dart';
import '../data/locals/SharedRef.dart';
import '../models/Enums.dart';
import '../models/others/HomeWorks.dart';
import '../models/others/Users.dart';
import '../models/ui/AlertInfo.dart';

class HomeWorkPresenter {
  AlertInfo alertServerError = AlertInfo(
      'Your test is empty',
      'Please contact to Icorrect team for assistance!',
      Alert.SERVER_ERROR.type);

  AlertInfo alertNetWork = AlertInfo(
      'Fail to load your homeworks',
      "Can not request to get your homeworks. Please check your internet connection and try again!",
      Alert.NETWORK_ERROR.type);

  Future getHomeWorks(GetHomeWorkCallBack callBack) async {
    Users? user = await SharedRef.instance().getUser();

    String url = APIHelper.init().apiHomeWorksList(<String, dynamic>{
      'email': user!.email,
      'status': Status.CORRECTED.get.toString()
    });

    try {
      Response response = await Repositories.init()
          .sendRequest(APIHelper.GET, url, true)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == APIHelper.RESPONSE_OK) {
        Map<String, dynamic> responseMap = jsonDecode(response.body);
        if (responseMap['error_code'] == APIHelper.RESPONSE_OK &&
            responseMap['status'] == APIHelper.RESPONSE_SUCCESS) {
          List<dynamic> dataFromApi =
              json.decode(response.body)['result'] ?? [];
          List<HomeWorks> homeworks = await _convertToHomeWorks(dataFromApi);
          callBack.getHomeWorksSuccess(homeworks);
        } else {
          callBack.failToGetHomework(alertServerError);
        }
      } else {
        callBack.failToGetHomework(alertNetWork);
      }
    } on TimeoutException {
      callBack.failToGetHomework(alertNetWork);
    } on SocketException {
      callBack.failToGetHomework(alertNetWork);
    } on ClientException {
      callBack.failToGetHomework(alertNetWork);
    }
  }

  Future<List<HomeWorks>> _convertToHomeWorks(List<dynamic> data) async {
    List<HomeWorks> homeWorks = [];
    for (int i = 0; i < data.length; i++) {
      dynamic item = data[i];
      homeWorks.add(HomeWorks(
          item['id'],
          item['ai_response_link'] ?? '',
          item['have_ai_reponse'] ?? 0,
          item['ai_score'] ?? 0,
          item['ai_order'] ?? 0,
          item['start_date'],
          item['end_date'],
          item['start'],
          item['end'],
          item['end_time'],
          item['start_time'],
          item['name'],
          item['tips'],
          item['test_option'],
          item['complete_status'],
          item['test_id'],
          item['order_id'],
          item['submited_date'],
          item['class_id'],
          item['class_name'],
          item['activity_type'],
          item['is_tested']));
    }
    return homeWorks;
  }

  List<HomeWorks> filterHomeWorks(
      String className, int status, List<HomeWorks> homeworks) {
    List<HomeWorks> filterHomeWorks = [];

    if (className == 'Alls' && status == -10) {
      return homeworks;
    }

    for (HomeWorks homework in homeworks) {
      if (homework.className.toString() == className &&
          homework.status == status) {
        filterHomeWorks.add(homework);
      } else if (className == 'Alls' && homework.status == status) {
        filterHomeWorks.add(homework);
      } else if (homework.className.toString() == className && status == -10) {
        filterHomeWorks.add(homework);
      }
    }
    return filterHomeWorks;
  }
}


// if (have_ai_reponse === 1) {
//           return " & AI Scored";
//         }


// if (testType === "homework") {
//         if (completeStatus === -2) {
//           return "Out of date";
//         }
//         if (completeStatus == -1) {
//           return "Late";
//         }
//         if (completeStatus == 0) {
//           return "Not completed";
//         }
//         if (completeStatus == 1) {
//           return "Submitted";
//         }
//         if (completeStatus == 2) {
//           return "Corrected";
//         }
//       }
//       // test type
//       if (testType === "test") {
//         // tested
//         if (isTested !== 1) {

//           if (completeStatus === -2) {
//             return "Out of date";
//           }
//           if (completeStatus == -1) {
//             return "Late";
//           }
//           if (completeStatus == 0) {
//             return "Not completed";
//           }
//           if (completeStatus == 1) {
//             return "Submitted";
//           }
//           if (completeStatus == 2) {
//             return "Corrected";
//           }
//         } else {
        
//           if (completeStatus === 2) {
//             return "Corrected";
//           }
//           if (completeStatus == -1) {
//             return "Late";
//           }
//           if (completeStatus == 1) {
//             return "Submitted";
//           }
