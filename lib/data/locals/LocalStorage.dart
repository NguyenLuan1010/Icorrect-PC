import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../callbacks/AuthenticationCallBack.dart';
import '../../models/Enums.dart';
import '../../models/test_simulator/FileTopic.dart';
import '../../models/test_simulator/QuestionTopic.dart';
import '../../models/test_simulator/Topic.dart';
import '../../models/ui/AlertInfo.dart';
import '../api/APIHelper.dart';
import '../api/Repositories.dart';

class LocalStorage {
  LocalStorage._();
  static final LocalStorage _localStorage = LocalStorage._();
  factory LocalStorage.init() => _localStorage;

  static const VIDEO_FOLDER = "videos";
  static const RECORD_FOLER = "records";

///////////////////////////TEST DETAIL DOWNLOAD/////////////////////////////////

  Future<void> downloadData(Topic topic,
      {required DownloadFileCallback? callback}) async {
    List<String> allFiles = _getAllFiles(topic) ?? [];

    int countDownloaded = 0;

    for (String name in allFiles) {
      if (_isVideoFile(name) && !await _isExistVideoFile(name, VIDEO_FOLDER)) {
        Response response = await _sendRequestDownload(name);

        if (response.statusCode != APIHelper.RESPONSE_OK) {
          AlertInfo alertInfo = AlertInfo(
              'Fail to load file ',
              'Please check your internet and doing test again !',
              Alert.NETWORK_ERROR.type);
          callback!.downloadFail(alertInfo);
          return;
        }
        await _saveVideo(response, VIDEO_FOLDER, getNameFile(name));
      } else if (!_isVideoFile(name) &&
          !await _isExistRecordFile(name, RECORD_FOLER)) {
        try {
          Response response = await _sendRequestDownload(name);

          if (response.statusCode != APIHelper.RESPONSE_OK) {
            AlertInfo alertInfo = AlertInfo(
                'Fail to load file ',
                'Please check your internet and doing test again !',
                Alert.NETWORK_ERROR.type);
            callback!.downloadFail(alertInfo);
            return;
          }

          await _saveAudio(response, RECORD_FOLER, getNameFile(name));
        } on TimeoutException catch (e) {
          AlertInfo alertInfo = AlertInfo(
              'Fail to load file ',
              'Please check your internet and doing test again !',
              Alert.NETWORK_ERROR.type);
          callback!.downloadFail(alertInfo);
        } on SocketException catch (e) {
          AlertInfo alertInfo = AlertInfo(
              'Fail to load file ',
              'Please check your internet and doing test again !',
              Alert.NETWORK_ERROR.type);
          callback!.downloadFail(alertInfo);
        } on ClientException catch (e) {
          AlertInfo alertInfo = AlertInfo(
              'Fail to load file ',
              'Please check your internet and doing test again !',
              Alert.NETWORK_ERROR.type);
          callback!.downloadFail(alertInfo);
        }
      }

      countDownloaded++;

      callback!.downloadSuccess(
          topic, _getPercent(allFiles.length, countDownloaded));
    }
  }

  Future<Response> _sendRequestDownload(String name) async {
    String url = APIHelper.init().apiFile(name);
    return await Repositories.init()
        .sendRequest(APIHelper.GET, url, false)
        .timeout(const Duration(seconds: 10));
  }

  // Future<Database> _openLocalDatabase(var appDocumentDirectory) async {
  //   Database db;
  //   if (Platform.isWindows || Platform.isLinux) {
  //     sqfliteFfiInit();
  //     var databaseFactory = databaseFactoryFfi;
  //     db = await databaseFactory.openDatabase(inMemoryDatabasePath);
  //   } else {
  //     final path = '${appDocumentDirectory.path}/$DATABASE_NAME';
  //     db = await openDatabase(
  //       path,
  //       version: 1,
  //     );
  //   }
  //   return db;
  // }

  Future<void> _saveVideo(
      Response response, final folder, String nameFile) async {
    var appDocumentDirectory = await getApplicationSupportDirectory();
    String filePath = '${appDocumentDirectory.path}\\$folder';
    Directory hideDirectory = Directory(filePath);

    String hideFilePath = '${hideDirectory.path}\\$nameFile';

    File file = File(hideFilePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }

    file.writeAsBytes(response.bodyBytes);
  }

  Future<void> _saveAudio(
      Response response, final folder, String nameFile) async {
    if (!await _isExistRecordFile(nameFile, folder)) {
      var appDocumentDirectory = await getApplicationSupportDirectory();

      String filePath = '${appDocumentDirectory.path}\\$folder';
      Directory hideDirectory = Directory(filePath);

      String hideFilePath = '${hideDirectory.path}\\$nameFile';
      print(filePath);
      File file = File(hideFilePath);
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      file.writeAsBytes(response.bodyBytes);
    }
  }

  double _getPercent(int total, int success) {
    return (success / total);
  }

  List<String> _getAllFiles(Topic topic) {
    List<String> videosList = [];

    List<String> filesIntro = _getFileIntro(topic) ?? [];
    List<String> filesQuestion = _getFileQuestions(topic) ?? [];
    List<String> filesFollowUp = _getFileFollowUp(topic) ?? [];
    Map<String, dynamic> endOfTest = topic.endOfTest ?? {};
    String fileEndOfTest = endOfTest['url'].toString();

    videosList.addAll(filesIntro);
    videosList.addAll(filesQuestion);
    videosList.addAll(filesFollowUp);
    videosList.add(fileEndOfTest);

    return videosList;
  }

  List<String> _getFileIntro(Topic topic) {
    List<String> files = [];
    List<FileTopic> filesIntroPart = topic.files ?? [];
    for (int i = 0; i < filesIntroPart.length; i++) {
      FileTopic file = filesIntroPart[i];
      files.add(file.getUrl);
    }
    return files;
  }

  List<String> _getFileQuestions(Topic topic) {
    List<FileTopic> filesQuestions = [];
    List<FileTopic> fileAnswers = [];
    List<QuestionTopic> questions = topic.questions ?? [];
    for (QuestionTopic q in questions) {
      filesQuestions.addAll(q.files ?? []);
      fileAnswers.addAll(q.answers ?? []);
    }

    List<String> files = [];
    for (FileTopic f in filesQuestions) {
      files.add(f.getUrl);
    }

    for (FileTopic f in fileAnswers) {
      files.add(f.getUrl);
      print('answer: ${f.getUrl}');
    }

    return files;
  }

  List<String> _getFileFollowUp(Topic topic) {
    List<FileTopic> filesFollowUp = [];
    List<FileTopic> filesAnswer = [];
    List<QuestionTopic> followUp = topic.followUp ?? [];
    for (QuestionTopic q in followUp) {
      filesFollowUp.addAll(q.files ?? []);
      filesAnswer.addAll(q.answers ?? []);
    }

    List<String> files = [];
    for (FileTopic f in filesFollowUp) {
      files.add(f.getUrl);
    }

    for (FileTopic f in filesAnswer) {
      files.add(f.getUrl);
    }

    return files;
  }

  Future<bool> _isExistVideoFile(String name, String folder) async {
    if ((await getAllVideoFiles(folder)).isNotEmpty) {
      for (File file in await getAllVideoFiles(folder)) {
        if (file.absolute.toString().contains(name)) {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> _isExistRecordFile(String name, String folder) async {
    if ((await getRecordFile(folder)).isNotEmpty) {
      for (File file in await getRecordFile(folder)) {
        if (file.absolute.toString().contains(name)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _isVideoFile(String filePath) {
    String fileExtension = filePath.split('.').last.toLowerCase();
    if (fileExtension == 'mp4' ||
        fileExtension == 'mov' ||
        fileExtension == 'avi') {
      return true;
    }
    // } else if (fileExtension == 'wav' ||
    //     fileExtension == 'mp3' ||
    //     fileExtension == 'aac') {
    //   return false;
    // } else {
    return false;
  }

  String getNameFile(String nameFile) {
    var files = nameFile.split("/");
    return files.last;
  }

  Future<String> rootPath() async {
    var appDocumentDirectory = await getApplicationSupportDirectory();
    return appDocumentDirectory.path;
  }

  Future<List<File>> getAllVideoFiles(String folder) async {
    var appDocumentDirectory = await getApplicationSupportDirectory();
    String filePath = '${appDocumentDirectory.path}\\$folder';

    Directory localAppDataDirectory = Directory(filePath);
    if (localAppDataDirectory.existsSync()) {
      final List<FileSystemEntity> entities =
          localAppDataDirectory.listSync(recursive: true);
      final List<File> files = entities.whereType<File>().toList();

      return files;
    }
    return [];
  }

  Future<List<File>> getRecordFile(String folderPath) async {
    var appDocumentDirectory = await getApplicationSupportDirectory();
    String filePath = '${appDocumentDirectory.path}\\$folderPath';
    Directory directory = Directory(filePath);

    if (directory.existsSync()) {
      final List<FileSystemEntity> entities =
          directory.listSync(recursive: true);
      final List<File> files = entities.whereType<File>().toList();
      return files;
    }

    return [];
  }
}
