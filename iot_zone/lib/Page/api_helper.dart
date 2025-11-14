import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'AppConfig.dart';

class ApiHelper {
  static final String baseUrl = AppConfig.baseUrl;
  static final ip = AppConfig.serverIP;

  // -----------------------------
  // 📌 ดึง Token จาก storage
  // -----------------------------
  static Future<Map<String, String?>> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "access": prefs.getString("accessToken"),
      "refresh": prefs.getString("refreshToken"),
    };
  }

  // -----------------------------
  // 📌 เซฟ access ใหม่
  // -----------------------------
  static Future<void> saveAccessToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", newToken);
  }

  // -----------------------------
  // 📌 Logout ให้หมด
  // -----------------------------
  static Future<void> forceLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Session expired. Please login again.")),
    );
  }

  // ----------------------------------------------------------
  // 📌 1) Multipart API (Upload + Token Refresh)
  // ----------------------------------------------------------
  static Future<http.Response> callMultipartApi(
    String endpoint, {
    required Map<String, String> fields,
    String method = "POST", // ← เพิ่มตรงนี้ด้วย
    String? filePath,
    String fileField = "image",
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? access = prefs.getString("accessToken");
    String? refresh = prefs.getString("refreshToken");

    Future<http.Response> send(String accessToken) async {
      var uri = Uri.parse("http://$ip:3000$endpoint");

      var request = http.MultipartRequest(method, uri);
      request.headers["Authorization"] = "Bearer $accessToken";

      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      if (filePath != null && File(filePath).existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath(fileField, filePath),
        );
      }

      final streamed = await request.send();
      return await http.Response.fromStream(streamed);
    }

    // ยิงครั้งแรก
    http.Response res = await send(access ?? "");

    if (res.statusCode != 401) return res;

    final msg = _readMessage(res);
    if (msg != "access_token_expired") return res;

    // refresh
    final newToken = await refreshAccessToken(refresh);
    if (newToken == null) return res;

    await saveAccessToken(newToken);

    return await send(newToken);
  }

  // ----------------------------------------------------------
  // 📌 2) Normal API (GET / POST / PUT / DELETE)
  // ----------------------------------------------------------
  static Future<http.Response> callApi(
    String endpoint, {
    String method = "GET",
    Map<String, dynamic>? body,
  }) async {
    final tokens = await getTokens();
    String? access = tokens["access"];
    String? refresh = tokens["refresh"];

    Uri url = Uri.parse("$baseUrl$endpoint");

    Map<String, String> headers = {
      "Content-Type": "application/json",
      if (access != null) "Authorization": "Bearer $access",
    };

    http.Response res = await _send(method, url, headers, body);

    if (res.statusCode != 401) return res;

    final msg = _readMessage(res);
    if (msg != "access_token_expired") return res;

    // refresh
    final newToken = await refreshAccessToken(refresh);
    if (newToken == null) return res;

    await saveAccessToken(newToken);

    headers["Authorization"] = "Bearer $newToken";
    return await _send(method, url, headers, body);
  }

  // -----------------------------
  // 📌 Base request
  // -----------------------------
  static Future<http.Response> _send(
    String method,
    Uri url,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) async {
    switch (method) {
      case "POST":
        return await http.post(url, headers: headers, body: jsonEncode(body));
      case "PUT":
        return await http.put(url, headers: headers, body: jsonEncode(body));
      case "PATCH":
        return await http.patch(url, headers: headers, body: jsonEncode(body));
      case "DELETE":
        return await http.delete(url, headers: headers);
      default:
        return await http.get(url, headers: headers);
    }
  }

  // ----------------------------------------------------------
  // 📌 3) Refresh Token (ตัวจริง)
  // ----------------------------------------------------------
  static Future<String?> refreshAccessToken(String? refreshToken) async {
    if (refreshToken == null) return null;

    final res = await http.post(
      Uri.parse("$baseUrl/refresh-token"), // ← ถูกต้องตรงกับ server.js
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    if (res.statusCode != 200) return null;

    return jsonDecode(res.body)["accessToken"];
  }

  // ----------------------------------------------------------
  // 📌 4) อ่านข้อความ error
  // ----------------------------------------------------------
  static String? _readMessage(http.Response res) {
    try {
      return jsonDecode(res.body)["message"];
    } catch (e) {
      return null;
    }
  }
  
}
