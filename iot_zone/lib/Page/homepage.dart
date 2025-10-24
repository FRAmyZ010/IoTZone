import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
              flex: 2,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.menu,
                                color: Colors.white,
                                size: 28,
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

            const SizedBox(height: 20),

            // 🔹 ส่วนล่าง (Carousel + Recommend)
            Expanded(
              flex: 8,
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
                              _buildSlide('Slide 1', Colors.deepPurple[200]!),
                              _buildSlide('Slide 2', Colors.deepPurple[400]!),
                              _buildSlide('Slide 3', Colors.deepPurple[600]!),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 🔹 ปุ่ม Browse Asset
                        Center(
                          child: ElevatedButton(
                            onPressed: () {},
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

                        // 🔹 Recommend
                        const Padding(
                          padding: EdgeInsets.only(left: 20, top: 10),
                          child: Text(
                            "Recommend",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 🔹 Carousel Recommend
                        SizedBox(
                          height: 300,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 300,
                              enableInfiniteScroll: false,
                              enlargeCenterPage: true,
                              viewportFraction: 0.75,
                              padEnds: true,
                              autoPlay: false,
                              initialPage: 1,
                            ),
                            items: [
                              _buildRecommend(
                                'Item 1',
                                Colors.deepPurple[100]!,
                              ),
                              _buildRecommend(
                                'Item 2',
                                Colors.deepPurple[300]!,
                              ),
                              _buildRecommend(
                                'Item 3',
                                Colors.deepPurple[500]!,
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

      // 🔹 Navigation Bar ด้านล่าง
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 💜 Gradient Border (พื้นหลัง)
            Container(
              height: 63,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4D5DFF), Color(0xFFC368FF)],
                ),
              ),
            ),

            // ⚪ พื้นขาวข้างใน (ลดขนาดลงเล็กน้อย)
            Container(
              height: 54,
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => print("Home clicked"),
                      icon: const Icon(
                        Icons.home,
                        size: 26,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => print("History clicked"),
                      icon: const Icon(
                        Icons.history,
                        size: 26,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => print("Menu clicked"),
                      icon: const Icon(
                        Icons.list_alt,
                        size: 26,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ฟังก์ชันย่อยสร้างสไลด์
  Widget _buildSlide(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  // ✅ ฟังก์ชันย่อยสร้าง Recommend item
  Widget _buildRecommend(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
