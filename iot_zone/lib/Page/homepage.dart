import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'Widgets/bottom_nav_bar.dart';
import 'Widgets/buildTextContainer2/buildTextContainar_rigthlow.dart';
import 'Widgets/buildTextContainer2/buildTextContainer_rigthtop.dart';
import 'Widgets/buildTextContainer1/buildSlidehomepage_center.dart';
import 'Widgets/buildTextContainer1/buildSlidehomepage_rigthtop.dart';
import 'Widgets/buildTextContainer1/buildSlidehomepage_leftlow.dart';
import 'package:iot_zone/Page/Asset_page/assetpage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 ส่วนบน 20% พร้อมรูปจาง + Gradient + โปรไฟล์
            Expanded(
              flex: 25,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      './asset/img/homepage-banner.jpg',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                                size: 40,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 26,
                              backgroundImage: AssetImage(
                                './asset/img/Icon_Profile.png',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Doi_za007',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Student',
                                  style: TextStyle(
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
                          padding: const EdgeInsets.only(top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "asset/img/iot.png",
                                width: 60,
                                height: 60,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  "Zone",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
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
              flex: 75,
              child: Container(
                color: Colors.white,
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SingleChildScrollView(
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Assetpage(),
                                ),
                              );
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
                                    'Manage smarter Live easier All your tools sensors and modules. right at your fingertips Fast. Clean. Powerful.',
                                color: Colors.deepPurple[100]!,
                                imagePath: 'asset/img/LAB_ROOM.jpg',
                              ),
                              BuildTextContainerRightLow(
                                text:
                                    '“Think ahead\nWork smarter.\nSAFEAREA — The next generation of asset management.”',
                                color: Colors.deepPurple[100]!,
                                imagePath: 'asset/img/LAB_ROOM2.jpg',
                              ),
                              BuildTextContainerRightTop(
                                text:
                                    '“Power up your lab.\nManage smart.\n Borrow easy.\nYour tools, your control — anytime, anywhere.”',
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

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0, // หน้าปัจจุบัน (Home)
        onTap: (index) {
          setState(() {
            // index ที่เลือก (0 = Home, 1 = History, 2 = Menu)
            print("Tapped index: $index");
          });

          // ✅ ตัวอย่างการลิงก์ไปหน้าอื่น
          if (index == 1) {
            Navigator.pushNamed(context, '/history');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/menu');
          }
        },
      ),
    );
  }
}
