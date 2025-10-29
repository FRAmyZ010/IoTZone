import 'package:flutter/material.dart';

import 'package:iot_zone/Page/Asset_page/assetpage.dart';
import 'package:iot_zone/Page/History_page/history_lender.dart';
import 'package:iot_zone/Page/History_page/history_staff.dart';
import 'package:iot_zone/Page/History_page/history_student.dart';

void main() {
  runApp(
    MaterialApp(home: HistoryLenderPage(), debugShowCheckedModeBanner: false),
  );
}
