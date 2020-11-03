import 'package:flutter/material.dart';
import 'package:ynu_network_reset/app.dart';
import 'package:ynu_network_reset/flutter_configuration.dart';

/// global configuration from yaml
FlutterConfiguration config;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  config = await FlutterConfiguration.fromAsset('assets/config.yaml');
  runApp(App());
}
