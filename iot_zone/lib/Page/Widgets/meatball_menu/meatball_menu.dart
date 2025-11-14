import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iot_zone/Page/Login/login_page.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import '../../AppConfig.dart';
import 'package:iot_zone/Page/api_helper.dart';

enum ProfileMenuAction { profile, changepassword, logout }

class UserProfileMenu extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function(Map<String, dynamic>)? onProfileUpdated;

  const UserProfileMenu({super.key, this.userData, this.onProfileUpdated});

  @override
  State<UserProfileMenu> createState() => _UserProfileMenuState();
}

class _UserProfileMenuState extends State<UserProfileMenu> {
  final ImagePicker _picker = ImagePicker();
  final String ip = AppConfig.serverIP;

  Widget _buildProfileEditableItem({
    required Widget icon,
    required String labelText,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(width: 20, height: 20, child: icon),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: labelText,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // PROFILE DIALOG
  // -----------------------------------------------------------
  Future<void> _showProfileAlert(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    final storedUsername = prefs.getString('username') ?? '';
    final storedName = prefs.getString('name') ?? '';
    final storedPhone = prefs.getString('phone') ?? '';
    final storedEmail = prefs.getString('email') ?? '';
    final storedImage = prefs.getString('image');

    File? pickedImage;
    final userC = TextEditingController(text: storedUsername);
    final nameC = TextEditingController(text: storedName);
    final phoneC = TextEditingController(text: storedPhone);
    final emailC = TextEditingController(text: storedEmail);

    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            Future<void> selectImage() async {
              final picked = await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );
              if (picked != null) {
                setStateDialog(() {
                  pickedImage = File(picked.path);
                });
              }
            }

            ImageProvider? getProfileImage() {
              if (pickedImage != null) return FileImage(pickedImage!);
              if (storedImage != null &&
                  storedImage.isNotEmpty &&
                  storedImage != "null") {
                return NetworkImage(
                  "http://$ip:3000$storedImage?v=${DateTime.now().millisecondsSinceEpoch}",
                );
              }
              return null;
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        "Profile",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: selectImage,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: getProfileImage(),
                          child: getProfileImage() == null
                              ? const Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey,
                                  size: 35,
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 12),
                      _buildProfileEditableItem(
                        icon: Image.asset("asset/icon/user.png"),
                        labelText: "Username",
                        controller: userC,
                      ),
                      _buildProfileEditableItem(
                        icon: Image.asset("asset/icon/id-card.png"),
                        labelText: "Full Name",
                        controller: nameC,
                      ),
                      _buildProfileEditableItem(
                        icon: Image.asset("asset/icon/phone.png"),
                        labelText: "Phone",
                        controller: phoneC,
                        keyboardType: TextInputType.phone,
                      ),
                      _buildProfileEditableItem(
                        icon: Image.asset("asset/icon/gmail.png"),
                        labelText: "Email",
                        controller: emailC,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    String? resizedPath;

                    if (pickedImage != null) {
                      final bytes = await pickedImage!.readAsBytes();
                      final decoded = img.decodeImage(bytes);
                      if (decoded != null) {
                        final resized = img.copyResize(decoded, width: 600);
                        final pngBytes = img.encodePng(resized);

                        final newFile = File(
                          "${pickedImage!.path}_resized.png",
                        );
                        await newFile.writeAsBytes(pngBytes);
                        resizedPath = newFile.path;
                      }
                    }

                    final response = await ApiHelper.callMultipartApi(
                      "/api/update-profile/$userId",
                      fields: {
                        "username": userC.text,
                        "name": nameC.text,
                        "phone": phoneC.text,
                        "email": emailC.text,
                      },
                      filePath: resizedPath,
                      fileField: "image",
                    );

                    if (response.statusCode == 200) {
                      final data = jsonDecode(response.body);

                      await prefs.setString('username', data["username"]);
                      await prefs.setString('name', data["name"]);
                      await prefs.setString('phone', data["phone"]);
                      await prefs.setString('email', data["email"]);
                      if (data["image"] != null) {
                        await prefs.setString('image', data["image"]);
                      }

                      widget.onProfileUpdated?.call(data);

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("✅ Profile updated")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("⚠ Update failed")),
                      );
                    }
                  },
                  child: const Text("Confirm"),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -----------------------------------------------------------
  // CHANGE PASSWORD
  // -----------------------------------------------------------
  Future<void> _showChangePasswordAlert(BuildContext context) async {
    final oldC = TextEditingController();
    final newC = TextEditingController();
    final confirmC = TextEditingController();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");

    final key = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              content: Form(
                key: key,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("asset/icon/padlock.png", width: 40),
                    const SizedBox(height: 10),
                    const Text(
                      "Change Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: oldC,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Current password",
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: newC,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "New password",
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: confirmC,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Confirm new password",
                      ),
                      validator: (v) {
                        if (v != newC.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () async {
                    if (!key.currentState!.validate()) return;

                    final res = await ApiHelper.callApi(
                      "/api/change-password/$userId",
                      method: "PUT",
                      body: {
                        "oldPassword": oldC.text,
                        "newPassword": newC.text,
                      },
                    );

                    if (res.statusCode == 200) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("✅ Password changed")),
                      );
                    } else {
                      final data = jsonDecode(res.body);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(data["message"] ?? "Update failed"),
                        ),
                      );
                    }
                  },
                  child: const Text("CONFIRM"),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("CANCEL"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // -----------------------------------------------------------
  // LOGOUT
  // -----------------------------------------------------------
  Future<void> _handleLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Do you really want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (ok == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  // -----------------------------------------------------------
  // POPUP MENU UI
  // -----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProfileMenuAction>(
      onSelected: (result) {
        if (result == ProfileMenuAction.profile) {
          _showProfileAlert(context);
        } else if (result == ProfileMenuAction.changepassword) {
          _showChangePasswordAlert(context);
        } else if (result == ProfileMenuAction.logout) {
          _handleLogout(context);
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: ProfileMenuAction.profile,
          child: Row(
            children: [
              Image.asset("asset/icon/user.png", width: 24),
              const SizedBox(width: 8),
              const Text("Profile"),
            ],
          ),
        ),
        PopupMenuItem(
          value: ProfileMenuAction.changepassword,
          child: Row(
            children: [
              Image.asset("asset/icon/padlock.png", width: 24),
              const SizedBox(width: 8),
              const Text("Change password"),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: ProfileMenuAction.logout,
          child: Row(
            children: [
              Image.asset("asset/icon/switch.png", width: 24),
              const SizedBox(width: 8),
              const Text("Log-out"),
            ],
          ),
        ),
      ],
      icon: const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Icon(Icons.more_horiz, color: Colors.white, size: 48),
      ),
    );
  }
}
