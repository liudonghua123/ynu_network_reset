import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:ynu_network_reset/main.dart';

class Service {
  Service._internal();

  static final Service _service = Service._internal();

  factory Service() {
    return _service;
  }

  Dio _dio;
  String _accessToken;

  void init(String accessToken) {
    print('init dio with _accessToken: $accessToken');
    _accessToken = accessToken;
    var options = BaseOptions(
      baseUrl: config.apiHost,
      connectTimeout: 5000,
      receiveTimeout: 3000,
    );
    _dio = Dio(options);
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  Future<List<String>> listMacAuth(String username) async {
    try {
      var response =
          await _dio.get('/api/v1/base/list-mac-auth', queryParameters: {
        'access_token': _accessToken,
        'user_name': username,
      });
      if (response.statusCode != 200 || response?.data['code'] != 0) {
        print(
            'listMacAuth of $username failed with ${response?.data["message"]}');
        return null;
      }
      List<dynamic> macAddress = response?.data['data'];
      return macAddress.map((item) => item['mac_address'] as String).toList();
    } catch (e) {
      print('exception occured, ${e.toString()}');
      return null;
    }
  }

  Future<bool> deleteMacAuth(String username, String macAddress) async {
    try {
      var response =
          await _dio.post('/api/v1/base/delete-mac-auth', data: {
        'access_token': _accessToken,
        'user_name': username,
        'mac_address': macAddress,
      });
      if (response.statusCode != 200 || response?.data['code'] != 0) {
        print(
            'deleteMacAuth of $username/$macAddress failed with ${response?.data["message"]}');
        return false;
      }
      return true;
    } catch (e) {
      print('exception occured, ${e.toString()}');
      return false;
    }
  }

  Future<List<String>> onlineEquipment(String username) async {
    try {
      var response =
          await _dio.get('/api/v1/base/online-equipment', queryParameters: {
        'access_token': _accessToken,
        'user_name': username,
      });
      if (response.statusCode != 200 || response?.data['code'] != 0) {
        print(
            'listMacAuth of $username failed with ${response?.data["message"]}');
        return null;
      }
      return response?.data['data'] as List<String>;
    } catch (e) {
      print('exception occured, ${e.toString()}');
      return null;
    }
  }

  Future<bool> batchOnlineDrop(String username) async {
    try {
      var response =
          await _dio.post('/api/v1/base/batch-online-drop', data: {
        'access_token': _accessToken,
        'user_name': username,
      });
      if (response.statusCode != 200 || response?.data['code'] != 0) {
        print(
            'batchOnlineDrop of $username failed with ${response?.data["message"]}');
        return false;
      }
      return true;
    } catch (e) {
      print('exception occured, ${e.toString()}');
      return false;
    }
  }
}
