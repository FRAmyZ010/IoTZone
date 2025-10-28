import 'package:flutter/material.dart';
import 'package:iot_zone/Page/homepagelender.dart';
import 'package:iot_zone/Page/homepagestaff.dart';
import 'package:iot_zone/Page/Dashboard/Dashboard-lecture.dart';
import 'package:iot_zone/Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar_lender.dart';
import 'package:iot_zone/Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar_staff.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: LenderMain()),
  );
}
