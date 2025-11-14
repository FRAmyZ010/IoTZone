import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:iot_zone/Page/AppConfig.dart';

class ApiHelper {
  static final String baseUrl = AppConfig.baseUrl;

  // ---------------------------
  // ดึง token
  // ---------------------------
  static Future<Map<String, String?>> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "access": prefs.getString("accessToken"),
      "refresh": prefs.getString("refreshToken"),
    };
  }

  // ---------------------------
  // save access token ใหม่
  // ---------------------------
  static Future<void> saveAccessToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", newToken);
  }

  // ----------------------------------------------------------
  // 📌 1) Multipart API + auto refresh token
  // ----------------------------------------------------------
  static Future<http.Response> callMultipartApi(
    String endpoint, {
    required Map<String, String> fields,
    String? filePath,
    String fileField = "file",
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final ip = AppConfig.serverIP;

    String? accessToken = prefs.getString("accessToken");
    String? refreshToken = prefs.getString("refreshToken");

    // ----------------- ฟังก์ชันยิง request -----------------
    Future<http.Response> sendRequest(String token) async {
      var uri = Uri.parse("http://$ip:3000$endpoint");
      var request = http.MultipartRequest("PUT", uri);

      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      if (filePath != null && File(filePath).existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath(fileField, filePath),
        );
      }

      request.headers["Authorization"] = "Bearer $token";

      final streamed = await request.send();
      return await http.Response.fromStream(streamed);
    }

    // ---------- 1st request ----------
    http.Response res = await sendRequest(accessToken ?? "");

    // ไม่ได้หมดอายุ → return
    if (res.statusCode != 401) return res;

    // อ่าน error
    final data = jsonDecode(res.body);
    if (data["message"] != "access_token_expired") {
      return res;
    }

    // ---------- refresh ----------
    final refreshRes = await http.post(
      Uri.parse("http://$ip:3000/refresh"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    if (refreshRes.statusCode != 200) return res;

    final newAccess = jsonDecode(refreshRes.body)["accessToken"];
    await prefs.setString("accessToken", newAccess);

    // ยิงใหม่ด้วย token ใหม่
    return await sendRequest(newAccess);
  }

  // ----------------------------------------------------------
  // 📌 2) Normal API + auto refresh
  // ----------------------------------------------------------
  static Future<http.Response> callApi(
    String endpoint, {
    String method = "GET",
    Map<String, dynamic>? body,
  }) async {
    final tokens = await getTokens();
    String? accessToken = tokens["access"];
    String? refreshToken = tokens["refresh"];

    Uri url = Uri.parse("$baseUrl$endpoint");

    Map<String, String> headers = {
      "Content-Type": "application/json",
      if (accessToken != null) "Authorization": "Bearer $accessToken",
    };

    // ---------- ยิงครั้งแรก ----------
    http.Response response = await _request(method, url, headers, body);

    // ถ้าไม่ใช่ 401 → token valid
    if (response.statusCode != 401) return response;

    // อ่าน error message
    final data = jsonDecode(response.body);
    if (data["message"] != "access_token_expired") {
      return response;
    }

    // ---------- refresh ----------
    final newToken = await refreshAccessToken(refreshToken);

    if (newToken == null) return response;

    // เก็บ token ใหม่
    await saveAccessToken(newToken);

    // ยิงใหม่ด้วย token ใหม่
    headers["Authorization"] = "Bearer $newToken";
    return await _request(method, url, headers, body);
  }

  // ----------------------------------------------------------
  // 📌 3) base request
  // ----------------------------------------------------------
  static Future<http.Response> _request(
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
      case "DELETE":
        return await http.delete(url, headers: headers);
      default:
        return await http.get(url, headers: headers);
    }
  }

  // ----------------------------------------------------------
  // 📌 4) Refresh Token
  // ----------------------------------------------------------
  static Future<String?> refreshAccessToken(String? refreshToken) async {
    if (refreshToken == null) return null;

    final res = await http.post(
      Uri.parse("$baseUrl/refresh"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    if (res.statusCode != 200) return null;

    return jsonDecode(res.body)["accessToken"];
  }
}
