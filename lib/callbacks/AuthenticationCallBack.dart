
import '../models/others/Users.dart';
import '../models/test_simulator/TestDetail.dart';
import '../models/test_simulator/Topic.dart';
import '../models/ui/AlertInfo.dart';

abstract class LoginCallBack {
  void loginSuccess(Users user, String accessToken, String message);

  void loginWarning(String message);

  void loginFail(AlertInfo info);
}

abstract class RegisterCallBack {
  void registerSuccess(String message);
  void registerWarning(String message);
  void registerFail(String message);
}

abstract class DownloadFileCallback {
  void downloadSuccess(Topic topic, double progress);
  void downloadFail(AlertInfo info);
}

////////////////////////////////////////////////////////////////////////////////

abstract class RequestTestDetailCallBack {
  void startDownloadFile(Map<String, dynamic> dataMap);
  void errorRequestTestDetail(AlertInfo alertInfo);
}

abstract class DownloadFileListener {
  void successDownload(TestDetail testDetail, String nameFile, double progress);
  void failDownload(AlertInfo info);
}
