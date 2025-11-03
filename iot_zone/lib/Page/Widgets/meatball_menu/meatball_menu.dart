import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iot_zone/Page/Login/login_page.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img; // ✅ ใช้แปลงภาพเป็น PNG
import '../../AppConfig.dart';

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

  // ----------------------------------------------------------
  // ✅ ช่อง input
  // ----------------------------------------------------------
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20, height: 20, child: icon),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                labelText: labelText,
                labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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

  // ----------------------------------------------------------
  // ✅ Alert แก้ไขโปรไฟล์ (พร้อมอัปเดตรูปทันที)
  // ----------------------------------------------------------
  Future<void> _showProfileAlert(BuildContext context) async {
    String initialUsername = widget.userData?['username'] ?? 'Unknown';
    String initialFullName = widget.userData?['name'] ?? 'N/A';
    String initialPhone = widget.userData?['phone'] ?? 'N/A';
    String initialEmail = widget.userData?['email'] ?? 'N/A';
    String? profileImageUrl = widget.userData?['image'];

    File? _tempImageFile;
    String? _tempFileName;

    final userController = TextEditingController(text: initialUsername);
    final nameController = TextEditingController(text: initialFullName);
    final phoneController = TextEditingController(text: initialPhone);
    final emailController = TextEditingController(text: initialEmail);

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            // ✅ ใช้ setDialogState() เพื่ออัปเดตรูปใน dialog ทันที
            Future<void> _alertPickImage(ImageSource source) async {
              final pickedFile = await _picker.pickImage(
                source: source,
                imageQuality: 85,
              );
              if (pickedFile != null) {
                setDialogState(() {
                  _tempImageFile = File(pickedFile.path);
                  _tempFileName = path.basename(pickedFile.path);
                });
              }
            }

            void _alertShowChoiceDialog() {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext sheetContext) {
                  return SafeArea(
                    child: Wrap(
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Gallery'),
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            _alertPickImage(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }

            ImageProvider<Object>? _getProfileImage() {
              if (_tempImageFile != null) {
                return FileImage(_tempImageFile!);
              } else if (profileImageUrl != null &&
                  profileImageUrl.isNotEmpty &&
                  profileImageUrl != "null") {
                return NetworkImage(
                  'http://$ip:3000$profileImageUrl?v=${DateTime.now().millisecondsSinceEpoch}',
                );
              } else {
                return null;
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              content: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _alertShowChoiceDialog,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: _getProfileImage(),
                            child: _getProfileImage() == null
                                ? const Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildProfileEditableItem(
                          icon: Image.asset(
                            'asset/icon/user.png',
                            width: 5,
                            height: 5,
                          ),
                          labelText: 'Username',
                          controller: userController,
                        ),
                        _buildProfileEditableItem(
                          icon: Image.asset(
                            'asset/icon/id-card.png',
                            width: 5,
                            height: 5,
                          ),
                          labelText: 'Full Name',
                          controller: nameController,
                        ),
                        _buildProfileEditableItem(
                          icon: Image.asset(
                            'asset/icon/phone.png',
                            width: 5,
                            height: 5,
                          ),
                          labelText: 'Phone',
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildProfileEditableItem(
                          icon: Image.asset(
                            'asset/icon/gmail.png',
                            width: 5,
                            height: 5,
                          ),
                          labelText: 'Email',
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        var request = http.MultipartRequest(
                          'PUT',
                          Uri.parse(
                            'http://$ip:3000/api/update-profile/${widget.userData?['id']}',
                          ),
                        );

                        request.fields['username'] = userController.text;
                        request.fields['name'] = nameController.text;
                        request.fields['phone'] = phoneController.text;
                        request.fields['email'] = emailController.text;

                        if (_tempImageFile != null) {
                          final bytes = await _tempImageFile!.readAsBytes();
                          final decoded = img.decodeImage(bytes);
                          if (decoded != null) {
                            final resized = img.copyResize(decoded, width: 600);
                            final pngBytes = img.encodePng(resized);
                            final newFile = File('${_tempImageFile!.path}.png');
                            await newFile.writeAsBytes(pngBytes);

                            var stream = http.ByteStream(newFile.openRead());
                            var length = await newFile.length();
                            var multipartFile = http.MultipartFile(
                              'image',
                              stream,
                              length,
                              filename:
                                  '${path.basenameWithoutExtension(_tempImageFile!.path)}.png',
                            );
                            request.files.add(multipartFile);
                          }
                        }

                        var response = await request.send();
                        if (response.statusCode == 200) {
                          final resData = jsonDecode(
                            await response.stream.bytesToString(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("✅ Profile updated successfully"),
                            ),
                          );

                          if (widget.onProfileUpdated != null) {
                            widget.onProfileUpdated!(resData);
                          }

                          await Future.delayed(const Duration(seconds: 1));
                          Navigator.of(context).pop();
                        } else {
                          final resData = jsonDecode(
                            await response.stream.bytesToString(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "⚠️ ${resData['message'] ?? 'Update failed'}",
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
                      }
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF37E451),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2147),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------------
  // ✅ Change Password
  // ----------------------------------------------------------
  Future<void> _showChangePasswordAlert(BuildContext context) async {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget buildPasswordField({
              required TextEditingController controller,
              required String labelText,
            }) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: controller,
                  obscureText: true,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: labelText,
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter $labelText';
                    }
                    if (labelText == 'Confirm new password' &&
                        newPassController.text != confirmPassController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'asset/icon/padlock.png',
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Change Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildPasswordField(
                      controller: oldPassController,
                      labelText: 'Current password',
                    ),
                    buildPasswordField(
                      controller: newPassController,
                      labelText: 'New password',
                    ),
                    buildPasswordField(
                      controller: confirmPassController,
                      labelText: 'Confirm new password',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FilledButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                final response = await http.put(
                                  Uri.parse(
                                    'http://$ip:3000/api/change-password/${widget.userData?['id']}',
                                  ),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({
                                    'oldPassword': oldPassController.text
                                        .trim(),
                                    'newPassword': newPassController.text
                                        .trim(),
                                  }),
                                );

                                if (response.statusCode == 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "✅ Password changed successfully",
                                      ),
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                } else {
                                  final resData = jsonDecode(response.body);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "⚠️ ${resData['message'] ?? 'Update failed'}",
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("❌ Error: $e")),
                                );
                              }
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF37E451),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('CONFIRM'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF2147),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('CANCEL'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------------
  // ✅ เมนูหลัก
  // ----------------------------------------------------------
  void _onSelected(BuildContext context, ProfileMenuAction result) {
    if (result == ProfileMenuAction.profile) {
      _showProfileAlert(context);
    } else if (result == ProfileMenuAction.meatball) {
      
    } else if (result == ProfileMenuAction.changepassword) {
      _showChangePasswordAlert(context);
    } else if (result == ProfileMenuAction.logout) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProfileMenuAction>(
      onSelected: (result) => _onSelected(context, result),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ProfileMenuAction.profile,
          child: Row(
            children: [
              Image.asset('asset/icon/user.png', width: 24, height: 24),
              const SizedBox(width: 8),
              const Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: ProfileMenuAction.changepassword,
          child: Row(
            children: [
              Image.asset('asset/icon/padlock.png', width: 24, height: 24),
              const SizedBox(width: 8),
              const Text('Change password'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: ProfileMenuAction.logout,
          child: Row(
            children: [
              Image.asset('asset/icon/switch.png', width: 24, height: 24),
              const SizedBox(width: 8),
              const Text('Log-out'),
            ],
          ),
        ),
      ],
      icon: const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Icon(Icons.more_horiz, color: Colors.white, size: 48),
      ),
      color: Colors.white,
      elevation: 8,
    );
  }
}
