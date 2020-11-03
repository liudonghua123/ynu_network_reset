import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml_config/yaml_config.dart';
import 'package:http/http.dart' as http;

class FlutterConfiguration extends YamlConfig {
  String apiHost;

  @override
  void init() {
    var environment = 'debug';
    if (kReleaseMode) {
      environment = 'production';
    }
    var environmentConfigs = get('$environment');
    apiHost = environmentConfigs['apiHost'];
    print('config parsed with result: ${this}');
  }

  FlutterConfiguration(String text) : super(text);

  static Future<FlutterConfiguration> fromAsset(String asset) async {
    var text = await rootBundle.loadString(asset);
    return FlutterConfiguration(text);
  }

  static Future<FlutterConfiguration> fromAssetUrl(String assetUrl) async {
    var response = await http.get(assetUrl);
    return FlutterConfiguration(response.body);
  }

  @override
  String toString() {
    return 'FlutterConfiguration{apiHost: $apiHost}';
  }
}
