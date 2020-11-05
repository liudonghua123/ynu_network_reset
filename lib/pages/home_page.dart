import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:simple_throttle_debounce/simple_throttle_debounce.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ynu_network_reset/constants.dart';
import 'package:ynu_network_reset/service.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

enum STATUS {
  INITIAL,
  PROCESSING,
  DONE,
}

class UserDetails {
  String username;
  STATUS macCleaned = STATUS.INITIAL;
  STATUS onlineDropped = STATUS.INITIAL;

  UserDetails({this.username, this.macCleaned, this.onlineDropped});
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final TextEditingController _accessTokenController = TextEditingController();
  List<UserDetails> userDetails = [];

  List<UserDetails> _parseUserUsernames(String usernames) {
    var usernameRegExp = RegExp(r'^.*?(?<username>\w+).*?$');
    return usernames
        .split(RegExp(r'\r?\n'))
        .map((item) {
          var match = usernameRegExp.firstMatch(item);
          if (match == null) {
            return UserDetails(username: '');
          }
          var username = match.namedGroup('username');
          return UserDetails(username: username);
        })
        .where((item) => item.username.isNotEmpty)
        .toList();
  }

  Widget _buildProgressIndicator(UserDetails userDetail) {
    var iconSize = 20.0;
    Widget macCleanedIndicator =
        Icon(FontAwesome.dot_circle_o, color: Colors.grey, size: iconSize);
    if (userDetail.macCleaned == STATUS.PROCESSING) {
      macCleanedIndicator = SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(strokeWidth: 3),
      );
    }
    if (userDetail.macCleaned == STATUS.DONE) {
      macCleanedIndicator =
          Icon(FontAwesome.check_circle_o, color: Colors.green, size: iconSize);
    }
    Widget onlineDroppedIndicator =
        Icon(FontAwesome.dot_circle_o, color: Colors.grey, size: iconSize);
    if (userDetail.onlineDropped == STATUS.PROCESSING) {
      onlineDroppedIndicator = SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(strokeWidth: 3),
      );
    }
    if (userDetail.onlineDropped == STATUS.DONE) {
      onlineDroppedIndicator =
          Icon(FontAwesome.check_circle_o, color: Colors.green, size: iconSize);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('清除MAC: '),
        macCleanedIndicator,
        SizedBox(width: DEFAULT_EDGEINSETS),
        Text('下线: '),
        onlineDroppedIndicator,
      ],
    );
  }

  Future _handleOnlineDrop(UserDetails userDetail, BuildContext context) async {
    setState(() {
      userDetail.onlineDropped = STATUS.PROCESSING;
    });
    var result = await Service().batchOnlineDrop(userDetail.username);
    setState(() {
      userDetail.onlineDropped = STATUS.DONE;
    });
    result
        ? showSimpleNotification(
            Text('${userDetail.username} 下线成功'),
            background: Colors.green,
            position: NotificationPosition.bottom,
          )
        : showSimpleNotification(
            Text('${userDetail.username} 下线失败'),
            background: Colors.red,
            position: NotificationPosition.bottom,
          );
  }

  Future _handleMacClean(UserDetails userDetail, BuildContext context) async {
    setState(() {
      userDetail.macCleaned = STATUS.PROCESSING;
    });
    var result = false;
    var macAddresses = await Service().listMacAuth(userDetail.username) ?? [];
    print('got macAddresses: $macAddresses');
    for (var macAddress in macAddresses) {
      result = await Service().deleteMacAuth(userDetail.username, macAddress);
      if (!result) {
        break;
      }
    }
    setState(() {
      userDetail.macCleaned = STATUS.DONE;
    });
    result
        ? showSimpleNotification(
            Text('${userDetail.username} 清除MAC绑定成功'),
            background: Colors.green,
            position: NotificationPosition.bottom,
          )
        : showSimpleNotification(
            Text('${userDetail.username} 清除MAC绑定失败'),
            background: Colors.red,
            position: NotificationPosition.bottom,
          );
  }

  @override
  Widget build(BuildContext context) {
    dynamic debouncedAccessTokenTask = debounce((text) {
      print('got changed accessToken: $text');
      Service().init(_accessTokenController.text);
    }, 500);
    dynamic debouncedUsernamesTask = debounce((text) {
      print('got changed usernames: $text');
      setState(() {
        userDetails = _parseUserUsernames(text);
      });
    }, 500);
    var appBarHeight = AppBar().preferredSize.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () async {
                const url =
                    'https://github.com/liudonghua123/ynu_network_reset';
                if (await canLaunch(url)) {
                  await launch(url);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(DEFAULT_EDGEINSETS),
                child: Lottie.asset(
                  'assets/35785-preloader-wifiish-by-fendah-cyberbryte.json',
                  height: appBarHeight - 2 * DEFAULT_EDGEINSETS,
                ),
              ),
            ),
            Text(
              'ynu_network_reset',
              style: TextStyle(color: Colors.black45),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(DEFAULT_EDGEINSETS),
        child: SingleChildScrollView(
          child: Column(
            children: [
              FormBuilder(
                key: _fbKey,
                child: Column(
                  children: <Widget>[
                    // token
                    Focus(
                      onFocusChange: (focusd) {
                        print('accessToken onFocusChange: $focusd');
                        if (!focusd && _accessTokenController.text != '') {
                          Service().init(_accessTokenController.text);
                        }
                      },
                      child: FormBuilderTextField(
                        controller: _accessTokenController,
                        attribute: 'accessToken',
                        decoration: InputDecoration(labelText: 'accessToken'),
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                        onChanged: (text) async {
                          if (text != '') {
                            debouncedAccessTokenTask(text);
                          }
                        },
                      ),
                    ),
                    // usernames
                    Focus(
                      onFocusChange: (focusd) {
                        print('usernames onFocusChange: $focusd');
                      },
                      child: FormBuilderTextField(
                        attribute: 'usernames',
                        decoration: InputDecoration(labelText: 'usernames'),
                        validators: [
                          FormBuilderValidators.required(),
                        ],
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onChanged: (text) async {
                          debouncedUsernamesTask(text);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // action buttons
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: DEFAULT_EDGEINSETS),
                child: Row(
                  children: [
                    RaisedButton(
                      child: Text(
                        '批量重置',
                        style: defaultWhiteTextStyle,
                      ),
                      onPressed: () async {
                        for (var userDetail in userDetails) {
                          await _handleMacClean(userDetail, context);
                          await _handleOnlineDrop(userDetail, context);
                        }
                      },
                      color: Colors.red,
                    ),
                    SizedBox(width: DEFAULT_EDGEINSETS),
                    RaisedButton(
                      child: Text(
                        '批量清除MAC绑定',
                        style: defaultWhiteTextStyle,
                      ),
                      onPressed: () async {
                        for (var userDetail in userDetails) {
                          await _handleMacClean(userDetail, context);
                        }
                      },
                      color: Colors.red,
                    ),
                    SizedBox(width: DEFAULT_EDGEINSETS),
                    RaisedButton(
                      child: Text(
                        '批量下线',
                        style: defaultWhiteTextStyle,
                      ),
                      onPressed: () async {
                        for (var userDetail in userDetails) {
                          await _handleOnlineDrop(userDetail, context);
                        }
                      },
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              // list of details
              Column(
                children: [
                  for (var userDetail in userDetails)
                    Card(
                      elevation: 5,
                      child: ListTile(
                        title: Text(userDetail.username),
                        subtitle: _buildProgressIndicator(userDetail),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RaisedButton(
                              color: Colors.red,
                              child: Text(
                                '清除MAC绑定',
                                style: defaultWhiteTextStyle,
                              ),
                              onPressed: () async {
                                await _handleMacClean(userDetail, context);
                              },
                            ),
                            SizedBox(width: DEFAULT_EDGEINSETS),
                            RaisedButton(
                              color: Colors.blue,
                              child: Text(
                                '下线',
                                style: defaultWhiteTextStyle,
                              ),
                              onPressed: () async {
                                await _handleOnlineDrop(userDetail, context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
