import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'AppConfig.dart';

class ApiHelper {
  static final String baseUrl = AppConfig.baseUrl;
  static final ip = AppConfig.serverIP;

  // ----------------------------------------------------------
  // 📌 ดึง Token จาก storage
  // ----------------------------------------------------------
  static Future<Map<String, String?>> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "access": prefs.getString("accessToken"),
      "refresh": prefs.getString("refreshToken"),
    };
  }

  // ----------------------------------------------------------
  // 📌 เซฟ Access Token ใหม่
  // ----------------------------------------------------------
  // -----------------------------
  // 📌 เซฟ access ใหม่ (Log ทุกครั้ง!)
  // -----------------------------
  static Future<void> saveAccessToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", newToken);

    debugPrint("🔐 [REAL-TIME] New Access Token Saved:");
    debugPrint("➡️ $newToken");
  }

  // ----------------------------------------------------------
  // 📌 Force Logout
  // ----------------------------------------------------------
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
  // 📌 Normal API (GET / POST / PUT / DELETE) + Logging
  // ----------------------------------------------------------
  static Future<http.Response> callApi(
    String endpoint, {
    String method = "GET",
    Map<String, dynamic>? body,
  }) async {
    final tokens = await getTokens();
    String? access = tokens["access"];
    String? refresh = tokens["refresh"];

    debugPrint("🌐 API CALL → $method $endpoint");
    debugPrint("🔑 Access Token (short) → ${access?.substring(0, 100)}...");

    Uri url = Uri.parse("$baseUrl$endpoint");

    Map<String, String> headers = {
      "Content-Type": "application/json",
      if (access != null) "Authorization": "Bearer $access",
    };

    // 🚀 ยิง API ครั้งแรก
    http.Response res = await _send(method, url, headers, body);

    debugPrint("📥 RESPONSE → ${res.statusCode}");
    debugPrint("📄 BODY → ${res.body}");

    // ❌ ไม่ใช่ 401 → return เลย
    if (res.statusCode != 401) return res;

    // 🔍 อ่าน error message
    final msg = _readMessage(res);
    if (msg != "access_token_expired") return res;

    debugPrint("⏳ Access Token expired → Refreshing...");

    // 🔁 Refresh Token
    final newToken = await refreshAccessToken(refresh);
    if (newToken == null) {
      debugPrint("❌ Refresh Token FAILED");
      return res;
    }

    debugPrint("✅ Refresh Token SUCCESS → Saving new token");

    await saveAccessToken(newToken);

    headers["Authorization"] = "Bearer $newToken";

    debugPrint("🔄 Retrying API with new Access Token…");

    return await _send(method, url, headers, body);
  }

  // ----------------------------------------------------------
  // 📌 Multipart API (Upload files)
  // ----------------------------------------------------------
  static Future<http.Response> callMultipartApi(
    String endpoint, {
    required Map<String, String> fields,
    String method = "POST",
    String? filePath,
    String fileField = "image",
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? access = prefs.getString("accessToken");
    String? refresh = prefs.getString("refreshToken");

    debugPrint("📤 MULTIPART API → $method $endpoint");
    debugPrint("📦 Fields: $fields");
    debugPrint("🖼 File: $filePath");

    Future<http.Response> send(String accessToken) async {
      var uri = Uri.parse("$baseUrl$endpoint");

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
      return http.Response.fromStream(streamed);
    }

    http.Response res = await send(access ?? "");

    debugPrint("📥 MULTIPART RESPONSE → ${res.statusCode}");

    if (res.statusCode != 401) return res;

    final msg = _readMessage(res);
    if (msg != "access_token_expired") return res;

    final newToken = await refreshAccessToken(refresh);
    if (newToken == null) return res;

    await saveAccessToken(newToken);

    return await send(newToken);
  }

  // ----------------------------------------------------------
  // 📌 Base Request (ส่งจริง)
  // ----------------------------------------------------------
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
  // 📌 อ่านข้อความ error
  // ----------------------------------------------------------
  static String? _readMessage(http.Response res) {
    try {
      return jsonDecode(res.body)["message"];
    } catch (e) {
      return null;
    }
  }

  // ----------------------------------------------------------
  // 📌 Refresh Token API
  // ----------------------------------------------------------

  static Future<String?> refreshAccessToken(String? refreshToken) async {
    if (refreshToken == null) return null;

    debugPrint("🔁 Calling /refresh-token");

    final res = await http.post(
      Uri.parse("$baseUrl/refresh-token"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    debugPrint("📥 Refresh Response → ${res.statusCode} ${res.body}");

    if (res.statusCode != 200) return null;

    final newToken = jsonDecode(res.body)["accessToken"];
    await saveAccessToken(newToken);

    return newToken;
  }
}
