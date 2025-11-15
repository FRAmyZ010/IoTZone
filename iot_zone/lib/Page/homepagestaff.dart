import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'AppConfig.dart';
import 'Widgets/buildBotttom_nav_bar/bottom_nav_bar_staff.dart';
import 'Widgets/buildTextContainer2/buildTextContainar_rigthlow.dart';
import 'Widgets/buildTextContainer2/buildTextContainer_rigthtop.dart';
import 'Widgets/buildTextContainer1/buildSlidehomepage_center.dart';
import 'Widgets/buildTextContainer1/buildSlidehomepage_rigthtop.dart';
import 'Widgets/buildTextContainer1/buildSlidehomepage_leftlow.dart';
import 'Widgets/meatball_menu/meatball_menu.dart';
import 'package:iot_zone/Page/Asset_page/asset_listmap/asset_model.dart';
import 'package:iot_zone/Page/api_helper.dart';
import 'dart:convert';

class Homepagestaff extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const Homepagestaff({super.key, this.userData});

  @override
  State<Homepagestaff> createState() => _HomepagestaffState();
}

extension StringCasing on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

class _HomepagestaffState extends State<Homepagestaff> {
  final ScrollController _scrollController = ScrollController();
  late Map<String, dynamic> _userData;

  List<AssetModel> latestAssets = [];
  bool isLoadingLatest = true;

  String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty || imagePath == "null") {
      return "";
    }

    // 📌 ถ้าเป็นรูปใน asset/flutter (local)
    if (imagePath.startsWith("asset/") || imagePath.startsWith("assets/")) {
      return imagePath; // จะใช้ Image.asset แทน
    }

    // 📌 ถ้าเป็นรูปจาก upload (server)
    return "http://${AppConfig.serverIP}:3000$imagePath";
  }

  @override
  void initState() {
    super.initState();
    _userData = Map<String, dynamic>.from(widget.userData ?? {});

    // ⭐ ดึง asset ที่นี่!
    _loadLatestAssets();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        300,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<List<AssetModel>> fetchAssets() async {
    try {
      final response = await ApiHelper.callApi("/assets", method: "GET");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => AssetModel.fromMap(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("❌ Error loading assets: $e");
      return [];
    }
  }

  Future<void> _loadLatestAssets() async {
    setState(() => isLoadingLatest = true);

    final allAssets = await fetchAssets();

    // เรียง id ใหม่สุด → เก่าสุด
    allAssets.sort((a, b) => b.id.compareTo(a.id));

    // เอาแค่ 5 รายการล่าสุด
    final latest = allAssets.take(3).toList();

    setState(() {
      latestAssets = latest;
      isLoadingLatest = false;
    });
  }

  Widget buildAssetImage(String? imagePath) {
    final fullPath = getFullImageUrl(imagePath);

    // ถ้าเป็นรูป asset (local)
    if (fullPath.startsWith("asset/") || fullPath.startsWith("assets/")) {
      return Image.asset(fullPath, width: double.infinity, fit: BoxFit.cover);
    }

    // ถ้าเป็นรูปจาก server
    return Image.network(
      fullPath,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          "asset/img/no_image.png",
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }

  // ✅ อัปเดตข้อมูลหลังแก้ไขโปรไฟล์
  void _onProfileUpdated(Map<String, dynamic> updatedData) {
    setState(() {
      _userData.addAll(updatedData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final username = _userData['username'] ?? 'Guest';
    final name = _userData['name'] ?? username;
    final role = (_userData['role'] ?? 'staff').toString().capitalize();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 ส่วนบน
            Expanded(
              flex: 28,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      'asset/img/homepage-banner.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF4D5DFF).withOpacity(0.9),
                          const Color(0xFFC368FF).withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 เมนูมุมขวา
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            UserProfileMenu(
                              userData: _userData,
                              onProfileUpdated: _onProfileUpdated,
                            ),
                          ],
                        ),

                        // 🔹 โปรไฟล์ผู้ใช้
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  _userData['image'] != null &&
                                      _userData['image']
                                          .toString()
                                          .isNotEmpty &&
                                      _userData['image'].toString() != 'null'
                                  ? NetworkImage(
                                      'http://${AppConfig.serverIP}:3000${_userData['image']}?v=${DateTime.now().millisecondsSinceEpoch}',
                                    )
                                  : const AssetImage(
                                          'asset/img/Icon_Profile.png',
                                        )
                                        as ImageProvider,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  role,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "asset/img/iot.png",
                                width: 60,
                                height: 60,
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                "Zone",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 ส่วนล่าง
            Expanded(
              flex: 70,
              child: Container(
                color: Colors.white,
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Carousel 1
                        SizedBox(
                          height: 200,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 175,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 5),
                              enlargeCenterPage: true,
                              viewportFraction: 0.78,
                              padEnds: true,
                            ),
                            items: [
                              BuildSlideHomepage(
                                text:
                                    '"Simplify your workflow. Amplify your efficiency."',
                                color: Colors.deepPurple[200]!,
                                imagePath: 'asset/img/LAB_ROOM7.jpg',
                              ),
                              BuildslidehomepageRigthtop(
                                text:
                                    '"Empowering smart operations for smarter people."',
                                color: Colors.deepPurple[400]!,
                                imagePath: 'asset/img/LAB_ROOM5.webp',
                              ),
                              Buildslidehomepageleftlow(
                                text:
                                    '"Control the chaos. Own your space. Welcome to the future of smart management."',
                                color: Colors.deepPurple[600]!,
                                imagePath: 'asset/img/LAB_ROOM6.webp',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              // ✅ เปลี่ยนแท็บไปหน้า Asset โดยใช้ context ของ StaffMain
                              final parent = StaffMain.of(context);
                              if (parent != null) {
                                parent.changeTab(4); // tab index 4 = Asset
                              } else {
                                debugPrint('⚠️ StaffMain not found in context');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B45FF),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "BROWSE ASSET",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          'Recommended Equipment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),

                        SizedBox(
                          height: 250,
                          child: isLoadingLatest
                              ? const Center(child: CircularProgressIndicator())
                              : latestAssets.isEmpty
                              ? const Center(
                                  child: Text(
                                    "There is no latest equipment information.",
                                  ),
                                )
                              : CarouselSlider(
                                  options: CarouselOptions(
                                    height: 500,
                                    enableInfiniteScroll: false,
                                    enlargeCenterPage: true,
                                    viewportFraction: 0.55,
                                    padEnds: true,
                                    autoPlay: false,
                                    initialPage: 1,
                                  ),
                                  items: latestAssets.map((asset) {
                                    return Builder(
                                      builder: (context) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.05,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // 🔹 แสดงรูป (รองรับ asset + upload)
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                        top: Radius.circular(
                                                          16,
                                                        ),
                                                      ),
                                                  child: buildAssetImage(
                                                    asset.image,
                                                  ),
                                                ),
                                              ),

                                              // 🔹 ชื่อ + ID
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  20.0,
                                                ),
                                                child: Container(
                                                  width: double
                                                      .infinity, // ให้ container กว้างสุด
                                                  alignment: Alignment
                                                      .center, // 👈 บังคับให้ลูกอยู่ตรงกลาง
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        asset.name,
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
