import 'dart:async';
import 'dart:io';

import 'package:http/http.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../callbacks/AuthenticationCallBack.dart';
import '../../models/Enums.dart';
import '../../models/test_simulator/FileTopic.dart';
import '../../models/test_simulator/TestDetail.dart';
import '../../models/ui/AlertInfo.dart';
import '../api/APIHelper.dart';
import '../api/Repositories.dart';

class DeviceStorage {
  DeviceStorage._();
  static final DeviceStorage _storage = DeviceStorage._();
  factory DeviceStorage.init() => _storage;

  static const VIDEO = "videos";
  static const AUDIO = "audios";

  AlertInfo alertInfo = AlertInfo(
      'Fail to load your test',
      "Can not request to load video. Please try again!",
      Alert.NETWORK_ERROR.type);

  Future downloadFiles(TestDetail testDetail, List<FileTopic> filesTopic,
      DownloadFileListener listener) async {
    int progress = 0;

    loop:
    for (FileTopic f in filesTopic) {
      String fileTopic = f.getUrl.toString();
      String newFileName = nameFileConvert(fileTopic);
      if (filesTopic.isNotEmpty) {
        String fileType = _fileType(fileTopic);
        if (fileType.isNotEmpty &&
            !await isExistFile(newFileName, fileType) &&
            filesTopic.isNotEmpty) {
          try {
            Response response = await _sendRequest(fileTopic);

            if (response.statusCode == APIHelper.RESPONSE_OK) {
              _saveFile(response, fileType, newFileName);
              progress++;

              listener.successDownload(testDetail, newFileName,
                  _getPercent(filesTopic.length, progress));
            } else {
              listener.failDownload(alertInfo);
              break loop;
            }
          } on TimeoutException {
            listener.failDownload(alertInfo);
          } on SocketException {
            listener.failDownload(alertInfo);
          } on ClientException {
            listener.failDownload(alertInfo);
          }
        } else {
          progress++;
          listener.successDownload(
              testDetail, fileTopic, _getPercent(filesTopic.length, progress));
        }
      }
    }
  }

  Future<Response> _sendRequest(String name) async {
    String url = APIHelper.init().apiFile(name);
    return await Repositories.init()
        .sendRequest(APIHelper.GET, url, false)
        .timeout(const Duration(seconds: 10));
  }

  String _fileType(String filePath) {
    String fileExtension = filePath.split('.').last.toLowerCase();
    if (fileExtension == 'mp4' ||
        fileExtension == 'mov' ||
        fileExtension == 'avi') {
      return VIDEO;
    }
    if (fileExtension == 'wav' ||
        fileExtension == 'mp3' ||
        fileExtension == 'aac') {
      return AUDIO;
    }
    return '';
  }

  Future<bool> isExistFile(String name, String folder) async {
    if ((await allDeviceFiles(folder)).isNotEmpty) {
      for (File file in await allDeviceFiles(folder)) {
        if (basename(file.path).toString() == name) {
          return true;
        }
      }
    }
    return false;
  }

  String nameFileConvert(String nameFile) {
    String letter = '/';
    String newLetter = '_';
    if (nameFile.contains(letter)) {
      nameFile = nameFile.replaceAll(letter, newLetter);
    }

    return nameFile;
  }

  double _getPercent(int total, int success) {
    return (success / total);
  }

  Future<String> rootPath() async {
    var appDocumentDirectory = await getApplicationSupportDirectory();
    return appDocumentDirectory.path;
  }

  Future<void> _saveFile(
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

  Future<List<File>> allDeviceFiles(String folder) async {
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
}
