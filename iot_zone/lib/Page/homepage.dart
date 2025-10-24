import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 ส่วนบน 20% พร้อมรูปจาง + Gradient + โปรไฟล์
            Expanded(
              flex: 2, // เทียบสัดส่วน 20%
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 🔹 รูปพื้นหลัง
                  Opacity(
                    opacity: 0.5, // ทำให้รูปจางลง 50%
                    child: Image.asset(
                      './asset/img/homepage-banner.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // 🔹 Gradient ไล่สีจากล่างเข้ม → บนอ่อน
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔹 แถวบน: ปุ่มเมนู (ขวาบน)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 28,
                              ),
                              padding:
                                  EdgeInsets.zero, // ✅ ตัด padding ของปุ่มออก
                              constraints:
                                  const BoxConstraints(), // ✅ ไม่เว้นพื้นที่รอบปุ่ม
                              onPressed: () {
                                // TODO: เพิ่มฟังก์ชันเมื่อกดปุ่มเมนู
                              },
                            ),
                          ],
                        ),

                        // 🔹 แถวล่าง: โปรไฟล์ + ชื่อ + ตำแหน่ง (ติดกันเลย)
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
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 🔹 โลโก้แอป (กลางล่าง)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'IoT',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyanAccent[200],
                              ),
                            ),
                            const TextSpan(
                              text: 'Zone',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20), // เว้นระยะห่างเล็กน้อย
            // 🔹 ส่วนล่าง 80%
            Expanded(
              flex: 8, // ส่วนล่าง 80%
              child: Container(
                color: Colors.white,
                alignment: Alignment.topCenter, // ✅ ชิดบน
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min, // ✅ ให้ขนาดเล็กพอดี ไม่ขยายเต็ม
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
                            viewportFraction: 0.88,
                          ),
                          items: [
                            // ✅ Slide 1
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.deepPurple[200],
                              ),
                              child: const Center(
                                child: Text(
                                  'Slide 1',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            // ✅ Slide 2
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.deepPurple[400],
                              ),
                              child: const Center(
                                child: Text(
                                  'Slide 2',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            // ✅ Slide 3
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.deepPurple[600],
                              ),
                              child: const Center(
                                child: Text(
                                  'Slide 3',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ), // ระยะห่างเล็กน้อยระหว่างสไลด์กับปุ่ม
                      // 🔹 ปุ่ม BROWSE ASSET
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: เพิ่มฟังก์ชันเมื่อกดปุ่ม
                          print("Browse Asset Clicked!");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B45FF), // 💜 สีม่วง
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

                        label: const Text(
                          "BROWSE ASSET",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
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
