import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:path/path.dart';

import '../locals/SharedRef.dart';
import 'APIHelper.dart';

class Repositories {
  Repositories._();
  static final Repositories _repositories = Repositories._();
  factory Repositories.init() => _repositories;

  Future<Response> sendRequest(method, String url, bool hasToken,
      {Object? body, Encoding? encoding}) async {
    Map<String, String> headers = {
      // 'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      // 'Authorization': 'Bearer $token',
    };

    if (hasToken == true) {
      var token = await getToken();
      headers['Authorization'] = 'Bearer $token';
    }

    if (method == APIHelper.GET) {
      return get(Uri.parse(url), headers: headers);
    }

    if (method == APIHelper.POST) {
      return post(Uri.parse(url),
          headers: headers, body: body, encoding: encoding);
    }

    if (method == APIHelper.PUT) {
      return put(Uri.parse(url),
          headers: headers, body: body, encoding: encoding);
    }
    if (method == APIHelper.PATCH) {
      return patch(Uri.parse(url),
          headers: headers, body: body, encoding: encoding);
    }

    if (method == APIHelper.DELETE) {
      return delete(Uri.parse(url),
          headers: headers, body: body, encoding: encoding);
    }

    return get(Uri.parse(url), headers: headers);
  }

  Future<StreamedResponse> pushFileWAV(
      String url, Map<String, String> formData, List<File> files) async {
    var request = http.MultipartRequest(APIHelper.POST, Uri.parse(url));

    String accessToken = await getToken() ?? '';
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $accessToken'
    });

    for (File file in files) {
      File audioFile = File('${file.path}.wav');
      request.files
          .add(await http.MultipartFile.fromPath('audio', audioFile.path));
    }
    request.fields.addAll(formData);

    return await request.send();
  }

  Future<String?> getToken() async {
    print(await SharedRef.instance().getAccessToken());
    return SharedRef.instance().getAccessToken();
  }
}
