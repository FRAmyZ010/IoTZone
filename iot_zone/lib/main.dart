import 'package:flutter/material.dart';
import 'package:iot_zone/Page/Asset_page/assetpage.dart';
import 'package:iot_zone/Page/Asset_page/assetstaff.dart';
import 'package:iot_zone/Page/Login/login_page.dart';
import 'Page/Login/check_session_page.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CheckSessionPage(),
  ));
}
