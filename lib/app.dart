import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:ynu_network_reset/pages/home_page.dart';

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        builder: OneContext().builder,
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          // fontFamily: 'FZLanTingYuan',
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
      ),
    );
  }
}
