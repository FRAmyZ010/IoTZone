import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:iot_zone/Page/Widgets/meatball_menu/meatball_menu.dart';

// 🔧 import widget ย่อย
import 'Widgets/buildBotttom_nav_bar/bottom_nav_bar.dart';
import 'Widgets/buildTextContainer1/buildSlidehomepage_center.dart';
import 'Widgets/buildTextContainer1/buildSlidehomepage_leftlow.dart';
import 'Widgets/buildTextContainer1/buildSlidehomepage_rigthtop.dart';
import 'Widgets/buildTextContainer2/buildTextContainar_rigthlow.dart';
import 'Widgets/buildTextContainer2/buildTextContainer_rigthtop.dart';

/// 🏠 Homepage แสดงข้อมูลโปรไฟล์ + แบนเนอร์
class Homepage extends StatefulWidget {
  final Map<String, dynamic>? userData; // ✅ รับข้อมูลจาก StudentMain

  const Homepage({
    super.key,
    this.userData,
  }); // ✅ เหลือ constructor แค่บรรทัดนี้

  @override
  State<Homepage> createState() => _HomepageState();
}

/// 🔹 Extension: ทำให้ตัวอักษรแรกเป็นพิมพ์ใหญ่
extension StringCasing on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

class _HomepageState extends State<Homepage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        300,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ดึงข้อมูลผู้ใช้จาก userData
    final username = widget.userData?['username'] ?? 'Guest';
    final name = widget.userData?['name'] ?? username;
    final role = (widget.userData?['role'] ?? 'Student')
        .toString()
        .capitalize();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 ส่วนบน - โปรไฟล์
            Expanded(
              flex: 28,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 🔸 พื้นหลังรูปจาง
                  Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      'asset/img/homepage-banner.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // 🔸 ไล่สีพื้นหลัง
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

                  // 🔸 ข้อมูลโปรไฟล์
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ... ปุ่มเมนูด้านขวาบน
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // ✅ เรียกใช้ UserProfileMenu ที่นี่ได้เลย
                            UserProfileMenu(userData: widget.userData),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // ... แถวโปรไฟล์
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 26,
                              backgroundImage: AssetImage(
                                'asset/img/Icon_Profile.png',
                              ),
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

                        // 🔹 โลโก้
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
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

            // 🔹 ส่วนล่าง (carousel, ปุ่ม, etc.)
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
                        // Carousel 1
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

                        // ปุ่ม Browse Asset
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              StudentMain.of(context)?.changeTab(3);
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

                        // Carousel 2 (recommend)
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
