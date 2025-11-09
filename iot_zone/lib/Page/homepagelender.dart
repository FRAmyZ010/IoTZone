import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'Widgets/buildBotttom_nav_bar/bottom_nav_bar_lender.dart';
import 'Widgets/buildTextContainer2/buildTextContainar_rigthlow.dart';
import 'Widgets/buildTextContainer2/buildTextContainer_rigthtop.dart';
import 'Widgets/buildTextContainer1/buildSlidehomepage_center.dart';
import 'Widgets/buildTextContainer1/buildSlidehomepage_rigthtop.dart';
import 'Widgets/buildTextContainer1/buildSlidehomepage_leftlow.dart';
import 'Widgets/meatball_menu/meatball_menu.dart';
import 'AppConfig.dart';

class Homepagelender extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const Homepagelender({super.key, this.userData});

  @override
  State<Homepagelender> createState() => _HomepagelenderState();
}

extension StringCasing on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

class _HomepagelenderState extends State<Homepagelender> {
  final ScrollController _scrollController = ScrollController();
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    _userData = Map<String, dynamic>.from(widget.userData ?? {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        300,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  // ✅ เมื่อมีการอัปเดตโปรไฟล์จากเมนู
  void _onProfileUpdated(Map<String, dynamic> updatedData) {
    setState(() {
      _userData.addAll(updatedData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final username = _userData['username'] ?? 'Guest';
    final name = _userData['name'] ?? username;
    final role = (_userData['role'] ?? 'Student').toString().capitalize();
    final imageUrl = _userData['image'];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 ส่วนบน (โปรไฟล์)
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
                        // 🔸 ปุ่ม 3 จุด (Meatball Menu)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            UserProfileMenu(
                              userData: _userData,
                              onProfileUpdated: _onProfileUpdated,
                            ),
                          ],
                        ),

                        // 🔸 แสดงโปรไฟล์ผู้ใช้
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  (imageUrl != null &&
                                      imageUrl.toString().isNotEmpty &&
                                      imageUrl.toString() != "null")
                                  ? NetworkImage(
                                      'http://${AppConfig.serverIP}:3000$imageUrl?v=${DateTime.now().millisecondsSinceEpoch}',
                                    )
                                  : const AssetImage(
                                          'asset/img/Icon_Profile.png',
                                        )
                                        as ImageProvider,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
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

                        // 🔸 โลโก้ IoT Zone
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
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

            // 🔹 ส่วนล่าง (Carousel + Recommend)
            Expanded(
              flex: 72,
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
                        // 🔹 Carousel
                        SizedBox(
                          height: 200,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 200,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 10),
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

                        // 🔹 ปุ่ม Browse Asset
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              LenderMain.of(context)?.changeTab(4);
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

                        // 🔹 Carousel Recommend
                        SizedBox(
                          height: 250,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 200,
                              enableInfiniteScroll: false,
                              enlargeCenterPage: true,
                              viewportFraction: 0.75,
                              padEnds: true,
                              autoPlay: false,
                              initialPage: 1,
                            ),
                            items: [
                              BuildTextContainerRightTop(
                                text:
                                    'Manage smarter, live easier. All your tools, sensors, and modules — right at your fingertips.',
                                color: Colors.deepPurple[100]!,
                                imagePath: 'asset/img/LAB_ROOM.jpg',
                              ),
                              BuildTextContainerRightLow(
                                text:
                                    '“Think ahead. Work smarter. SAFEAREA — The next generation of asset management.”',
                                color: Colors.deepPurple[100]!,
                                imagePath: 'asset/img/LAB_ROOM2.jpg',
                              ),
                              BuildTextContainerRightTop(
                                text:
                                    '“Power up your lab. Manage smart. Borrow easy. Your tools, your control — anytime, anywhere.”',
                                color: Colors.deepPurple[100]!,
                                imagePath: 'asset/img/LAB_ROOM3.jpg',
                              ),
                            ],
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
