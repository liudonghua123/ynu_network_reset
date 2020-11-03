import 'package:dio/dio.dart';
import 'package:ynu_network_reset/main.dart';

class Service {
  Service._internal();

  static final Service _service = Service._internal();

  factory Service() {
    return _service;
  }

  Dio dio;
  String accessToken;

  void init(String accessToken) {
    accessToken = accessToken;
    var options = BaseOptions(
      baseUrl: config.apiHost,
      connectTimeout: 5000,
      receiveTimeout: 3000,
    );
    dio = Dio(options);
  }

  Future<List<String>> listMacAuth(String username) async {
    try {
      var response =
          await dio.get('/api/v1/base/list-mac-auth', queryParameters: {
        'access_token': accessToken,
        'user_name': username,
      });
      if (response.statusCode != 200 || response?.data['code'] != 0) {
        print(
            'listMacAuth of $username failed with ${response?.data["message"]}');
        return null;
      }
      List<Map> macAddress = response?.data['data'];
      return macAddress.map((item) => item['mac_address']);
    } catch (e) {
      print('exception occured, ${e.toString()}');
      return null;
    }
  }

  Future<bool> deleteMacAuth(String username, String macAddress) async {
    try {
      var response =
          await dio.post('/api/v1/base/delete-mac-auth', queryParameters: {
        'access_token': accessToken,
        'user_name': username,
        'mac_address': macAddress,
      });
      if (response.statusCode != 200 || response?.data['code'] != 0) {
        print(
            'deleteMacAuth of $username/$macAddress failed with ${response?.data["message"]}');
        return null;
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
          await dio.get('/api/v1/base/online-equipment', queryParameters: {
        'access_token': accessToken,
        'user_name': username,
      });
      if (response.statusCode != 200 || response?.data['code'] != 0) {
        print(
            'listMacAuth of $username failed with ${response?.data["message"]}');
        return null;
      }
      return response?.data['data'];
    } catch (e) {
      print('exception occured, ${e.toString()}');
      return null;
    }
  }

  Future<bool> batchOnlineDrop(String username) async {
    try {
      var response =
          await dio.post('/api/v1/base/batch-online-drop', queryParameters: {
        'access_token': accessToken,
        'user_name': username,
      });
      if (response.statusCode != 200 || response?.data['code'] != 0) {
        print(
            'batchOnlineDrop of $username failed with ${response?.data["message"]}');
        return null;
      }
      return true;
    } catch (e) {
      print('exception occured, ${e.toString()}');
      return false;
    }
  }
}
