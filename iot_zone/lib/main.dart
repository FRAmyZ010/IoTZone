import 'package:flutter/material.dart';
import 'package:iot_zone/Page/Asset_page/assetpage.dart';
import 'package:iot_zone/Page/Asset_page/assetstaff.dart';
import 'package:iot_zone/Page/Dashboard/borrow_requests_page.dart';
import 'package:iot_zone/Page/Login/login_page.dart';
import 'Page/Login/check_session_page.dart';
import 'package:iot_zone/Page/homepagestaff.dart';
import 'package:iot_zone/Page/homepagelender.dart';
import 'Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar.dart';
import 'Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar_staff.dart';
import 'Page/Widgets/buildBotttom_nav_bar/bottom_nav_bar_lender.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/check",
      routes: {
        "/check": (context) => const CheckSessionPage(),
        "/login": (context) => const LoginPage(),

        // 🔹 Main ของแต่ละ role
        "/studentMain": (context) => const StudentMain(),
        "/staffMain": (context) => const StaffMain(),
        "/lenderMain": (context) => const LenderMain(),

        // ⭐⭐ สำคัญมาก — เพิ่มหน้า asset ที่คุณลืมใส่ ⭐⭐
        "/asset": (context) => const Assetpage(), // Student
      },
    ),
  );
}
