import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:iot_zone/Page/AppConfig.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final String ip = AppConfig.serverIP;
  int availableCount = 0;
  int pendingCount = 0;
  int disabledCount = 0;
  int borrowedCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAssetSummary();
  }

  // ✅ ดึงข้อมูลจาก API
  Future<void> fetchAssetSummary() async {
    try {
      final response = await http.get(
        Uri.parse('http://$ip:3000/api/dashboard-summary'),
      );
      print('📡 Response code: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          availableCount = int.parse(data['available'].toString());
          pendingCount = int.parse(data['pending'].toString());
          disabledCount = int.parse(data['disabled'].toString());
          borrowedCount = int.parse(data['borrowed'].toString());
          isLoading = false;
        });

        print('✅ availableCount: $availableCount');
        print('✅ pendingCount: $pendingCount');
        print('✅ disabledCount: $disabledCount');
        print('✅ borrowedCount: $borrowedCount');
      } else {
        throw Exception('Failed to load summary');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      appBar: AppBar(
        title: const Text(
          'Dashboard', // หัวข้อหน้า
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent, // พื้นหลัง AppBar
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today’s Asset Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusCard(
                        label: 'Available',
                        value: availableCount.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      StatusCard(
                        label: 'Disabled',
                        value: disabledCount.toString(),
                        icon: Icons.block,
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusCard(
                        label: 'Pending',
                        value: pendingCount.toString(),
                        icon: Icons.pending,
                        color: Colors.orange,
                      ),
                      StatusCard(
                        label: 'Borrowed',
                        value: borrowedCount.toString(),
                        icon: Icons.shopping_bag,
                        color: Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Asset Overview Chart",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // ✅ Bar Chart Section
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY:
                            [
                              availableCount,
                              disabledCount,
                              pendingCount,
                              borrowedCount,
                            ].reduce((a, b) => a > b ? a : b).toDouble() +
                            2,
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              // interval: 1, ปรับตัวเลขในแกน Y ให้เป็นทศนิยม
                              reservedSize: 25,
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0:
                                    return const Text('Available');
                                  case 1:
                                    return const Text('Disabled');
                                  case 2:
                                    return const Text('Pending');
                                  case 3:
                                    return const Text('Borrowed');
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          _buildBarGroup(
                            0,
                            availableCount.toDouble(),
                            const Color(0xFF6DBF73), // เขียวด้าน (Available)
                            const Color(0xFF6DBF73),
                          ),
                          _buildBarGroup(
                            1,
                            disabledCount.toDouble(),
                            const Color(0xFFE57373), // แดงพาสเทล (Disabled)
                            const Color(0xFFE57373),
                          ),
                          _buildBarGroup(
                            2,
                            pendingCount.toDouble(),
                            const Color(0xFFFFB74D), // ส้มด้าน (Pending)
                            const Color(0xFFFFB74D),
                          ),
                          _buildBarGroup(
                            3,
                            borrowedCount.toDouble(),
                            const Color(0xFF64B5F6), // ฟ้าอ่อน (Borrowed)
                            const Color(0xFF64B5F6),
                          ),
                        ],
                        groupsSpace: 10, // เอาไว้ปรับความห่างตัวเลขกับกราฟ
                        // ✅ Tooltip (รองรับ fl_chart 1.1.1)
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipBorderRadius: BorderRadius.circular(8),
                            tooltipBorder: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                            getTooltipColor: (group) => Colors.white,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${rod.toY.toInt()} items',
                                const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 800),
                      swapAnimationCurve: Curves.easeInOut,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(thickness: 1),
                  const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }

  // ✅ Helper function สำหรับสร้างแท่งใน Chart
  BarChartGroupData _buildBarGroup(
    int x,
    double value,
    Color startColor,
    Color endColor,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 30,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

// ✅ Card สำหรับสรุปสถานะ
class StatusCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatusCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

// ✅ Legend Widget
class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
