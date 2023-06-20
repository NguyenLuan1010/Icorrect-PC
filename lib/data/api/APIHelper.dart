
import '../../models/Enums.dart';

class APIHelper {
  APIHelper._();
  static final APIHelper _apiHelper = APIHelper._();
  factory APIHelper.init() => _apiHelper;

  static const RESPONSE_OK = 200;
  static const RESPONSE_SUCCESS = "success";

  static const API_DOMAIN = "http://api.ielts-correction.com/";
  static const ICORRECT_DOMAIN = "https://ielts-correction.com/";
  static const PUBLISH_DOMAIN = "http://public.icorrect.vn/";
  static const TOOL_DOMAIN = "http://tool.ielts-correction.com/";

  static const POST = 'POST';
  static const GET = 'GET';
  static const PATCH = 'PATCH';
  static const PUT = 'PUT';
  static const DELETE = 'DELETE';

  String apiLogin() {
    return "${API_DOMAIN}auth/login";
  }

  String apiUserInfo() {
    return "${API_DOMAIN}me";
  }

  String apiHomeWorksList(Map<String, dynamic> paramsMap) {
    return "${PUBLISH_DOMAIN}api/list-activity-v2?${Uri(queryParameters: paramsMap).query}";
  }

  String apiTopicDetail() {
    return "${API_DOMAIN}api/v1/ielts-test/syllabus/create";
  }

  String apiFile(String name) {
    return '${API_DOMAIN}file?filename=$name';
  }

  String apiSubmitHomeWork() {
    return '${ICORRECT_DOMAIN}api/v1/ielts-test/syllabus/submit';
  }

  String apiMyTestDetail(String testID) {
    return '${ICORRECT_DOMAIN}api/v1/ielts-test/show/$testID';
  }

  String apiResponse(String orderId) {
    return '${TOOL_DOMAIN}api/response?order_id=$orderId';
  }

  String apiAIResponse(String orderId) {
    return '${ICORRECT_DOMAIN}ai-response/index.html?order_id=$orderId';
  }

  String apiHighLightHomeWork(String email, String activityId) {
    return '${PUBLISH_DOMAIN}api/list-answers-activity?activity_id=$activityId&email=$email&status=${Status.ALL_HOMEWORK.get}&example=${Status.HIGHTLIGHT.get}&all=1';
  }

  String apiOtherHomeWorks(String email, String activityId) {
    return '${PUBLISH_DOMAIN}api/list-answers-activity?activity_id=$activityId&email=$email&status=${Status.ALL_HOMEWORK.get}&example=${Status.OTHERS.get}&all=1';
  }
}
