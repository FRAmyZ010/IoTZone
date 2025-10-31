import 'package:flutter/material.dart'; // นำเข้าแพ็กเกจ UI หลักของ Flutter
import 'package:intl/intl.dart'; // ใช้จัดรูปแบบวันที่/เวลา
import 'package:syncfusion_flutter_datepicker/datepicker.dart'; // ใช้ DateRangePicker ของ Syncfusion
import 'package:iot_zone/Page/AppConfig.dart'; // ดึงค่า config (เช่น server IP)

class BorrowAssetDialog extends StatefulWidget {
  // สร้างวิดเจ็ตแบบ Stateful สำหรับ dialog ยืมอุปกรณ์
  final Map<String, dynamic>
  asset; // รับข้อมูล asset เป็น Map (ชื่อ, รูป, คำอธิบาย ฯลฯ)

  const BorrowAssetDialog({
    super.key,
    required this.asset,
  }); // คอนสตรักเตอร์ รับ asset เป็น required

  @override
  State<BorrowAssetDialog> createState() => _BorrowAssetDialogState(); // ผูก state class
}

class _BorrowAssetDialogState extends State<BorrowAssetDialog> {
  // คลาส State สำหรับจัดการสถานะภายใน dialog
  DateTime? startDate; // วันที่เริ่มยืม (nullable)
  DateTime? endDate; // วันที่คืน (nullable)
  final String ip = AppConfig.serverIP; // IP ของเซิร์ฟเวอร์ จาก config

  // ✅ โหลดภาพแบบสมส่วน
  Widget _buildImage(String imagePath) {
    // ฟังก์ชันสร้างวิดเจ็ตแสดงรูปภาพ
    final borderRadius = BorderRadius.circular(16); // กำหนดรัศมีขอบโค้ง
    return Container(
      // กล่องครอบรูป
      height: 120, // ความสูงคงที่
      width: double.infinity, // กว้างเต็ม
      decoration: BoxDecoration(
        // ตกแต่งกล่อง
        borderRadius: borderRadius, // มุมโค้ง
        color: Colors.white, // พื้นหลังขาว
      ),
      child: ClipRRect(
        // ตัดขอบลูกให้โค้งตาม
        borderRadius: borderRadius, // รัศมีขอบ
        child: Align(
          // จัดตำแหน่งรูปให้อยู่กลาง
          alignment: Alignment.center, // จัดกึ่งกลาง
          child: FittedBox(
            // ย่อ/ขยายรูปให้พอดี
            fit: BoxFit.contain, // รักษาอัตราส่วน
            child:
                imagePath.startsWith('/uploads/') ||
                    imagePath.contains(
                      'http',
                    ) // เช็คว่าเป็นรูปจากเซิร์ฟเวอร์/URL ไหม
                ? Image.network(
                    // ถ้าใช่ โหลดจาก network
                    'http://$ip:3000$imagePath', // สร้าง URL เต็ม (กรณี path /uploads/...)
                    height: 100, // จำกัดความสูงรูป
                    width: 100, // จำกัดความกว้างรูป
                    fit: BoxFit.contain, // รักษาอัตราส่วนไม่ครอป
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      // ฟอลแบ็กเมื่อโหลดรูปไม่ได้
                      Icons.broken_image, // ไอคอนรูปเสีย
                      size: 60, // ขนาดไอคอน
                      color: Colors.grey, // สีเทา
                    ),
                  )
                : Image.asset(
                    // ไม่ใช่ network แสดงรูปจาก asset ภายในแอป
                    imagePath, // path ในโปรเจ็กต์
                    height: 100, // จำกัดความสูง
                    width: 100, // จำกัดความกว้าง
                    fit: BoxFit.contain, // ย่อ/ขยายพอดี
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      // ฟอลแบ็กเมื่อหาไฟล์ไม่เจอ
                      Icons.image_not_supported_outlined, // ไอคอนไม่รองรับรูป
                      size: 60, // ขนาดไอคอน
                      color: Colors.grey, // สีเทา
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ✅ ปฏิทินพร้อมโชว์วันยืมและวันคืน
  void _openCalendarDialog() {
    // ฟังก์ชันเปิดไดอะล็อกเลือกช่วงวันที่
    showDialog(
      // แสดง dialog ซ้อน
      context: context, // คอนเท็กซ์ของหน้าปัจจุบัน
      builder: (context) {
        // สร้างเนื้อหา dialog
        return Dialog(
          // ตัว dialog หลัก
          backgroundColor: Colors.white, // สีพื้นหลัง
          shape: RoundedRectangleBorder(
            // กำหนดรูปร่างขอบ
            borderRadius: BorderRadius.circular(20), // มุมโค้ง 20
          ),
          child: Padding(
            // ระยะห่างรอบใน
            padding: const EdgeInsets.all(18), // ทุกด้าน 18
            child: StatefulBuilder(
              // ใช้ StatefulBuilder เพื่อ setState ภายใน dialog ย่อยได้
              builder: (context, setInnerState) {
                // รับ setInnerState สำหรับอัปเดตสถานะใน dialog นี้
                return Column(
                  // จัดวางแนวตั้ง
                  mainAxisSize: MainAxisSize.min, // ให้สูงเท่าที่จำเป็น
                  children: [
                    Container(
                      // ส่วนหัวของไดอะล็อก
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ), // เว้นบนล่าง 8
                      child: const Text(
                        // ข้อความหัวเรื่อง
                        "Select Borrow & Return Date", // ข้อความบอกให้เลือกวันยืม/คืน
                        style: TextStyle(
                          // สไตล์ตัวอักษร
                          fontWeight: FontWeight.bold, // หนา
                          fontSize: 18, // ขนาด 18
                          color: Colors.deepPurpleAccent, // สีม่วง
                        ),
                      ),
                    ),
                    const Divider(
                      // เส้นคั่น
                      color: Colors.deepPurpleAccent, // สีม่วง
                      thickness: 1.2, // ความหนา 1.2
                    ),
                    const SizedBox(height: 6), // เว้นระยะ 6
                    // ✅ แสดงวันยืมและวันคืนแบบสวยๆ
                    Container(
                      // กล่องแถบโชว์วันเริ่ม/วันจบที่เลือก
                      decoration: BoxDecoration(
                        // ตกแต่งกล่อง
                        color: Colors.deepPurple.shade50, // พื้นหลังม่วงอ่อนมาก
                        borderRadius: BorderRadius.circular(14), // มุมโค้ง 14
                      ),
                      padding: const EdgeInsets.all(10), // เว้นระยะภายใน 10
                      child: Row(
                        // วางข้อมูล 2 ฝั่ง
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround, // กระจายเท่า ๆ กัน
                        children: [
                          Column(
                            // คอลัมน์ฝั่งวันยืม
                            children: [
                              const Text(
                                // หัวข้อ
                                "Borrow Date", // ข้อความ "วันยืม"
                                style: TextStyle(
                                  // สไตล์
                                  fontWeight: FontWeight.bold, // หนา
                                  color: Colors.black54, // เทาเข้ม
                                ),
                              ),
                              const SizedBox(height: 4), // เว้น 4
                              Text(
                                // แสดงวันที่เริ่มยืม
                                startDate !=
                                        null // ถ้ามีค่าเริ่ม
                                    ? DateFormat(
                                        // ฟอร์แมตวันที่
                                        'MMM d, yyyy', // รูปแบบ เช่น Oct 29, 2025
                                      ).format(
                                        startDate!,
                                      ) // ฟอร์แมตด้วย startDate
                                    : '--', // ถ้ายังไม่เลือก แสดง --
                                style: const TextStyle(
                                  // สไตล์ตัวอักษร
                                  fontSize: 15, // ขนาด 15
                                  color: Colors.black87, // สีดำอ่อน
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            // ไอคอนลูกศรชี้ไปขวา
                            Icons.arrow_right_alt_rounded, // ลูกศรโค้ง
                            color: Colors.deepPurpleAccent, // สีม่วง
                          ),
                          Column(
                            // คอลัมน์ฝั่งวันคืน
                            children: [
                              const Text(
                                // หัวข้อ
                                "Return Date", // ข้อความ "วันคืน"
                                style: TextStyle(
                                  // สไตล์
                                  fontWeight: FontWeight.bold, // หนา
                                  color: Colors.black54, // เทาเข้ม
                                ),
                              ),
                              const SizedBox(height: 4), // เว้น 4
                              Text(
                                // แสดงวันที่คืน
                                endDate !=
                                        null // ถ้ามีค่าวันคืน
                                    ? DateFormat('MMM d, yyyy').format(
                                        endDate!,
                                      ) // ฟอร์แมตวันคืน
                                    : '--', // ยังไม่เลือก แสดง --
                                style: const TextStyle(
                                  // สไตล์ตัวอักษร
                                  fontSize: 15, // ขนาด 15
                                  color: Colors.black87, // สีดำอ่อน
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14), // เว้น 14
                    // ✅ ปฏิทิน Syncfusion
                    SfDateRangePicker(
                      // วิดเจ็ตเลือกช่วงวันที่
                      selectionMode: DateRangePickerSelectionMode
                          .range, // โหมดเลือกเป็นช่วง
                      startRangeSelectionColor:
                          Colors.deepPurpleAccent, // สีวันเริ่ม
                      endRangeSelectionColor:
                          Colors.deepPurpleAccent, // สีวันจบ
                      rangeSelectionColor: Colors.deepPurpleAccent.withOpacity(
                        // สีไฮไลท์ช่วงกลาง
                        0.25, // โปร่งใส 25%
                      ),
                      todayHighlightColor:
                          Colors.deepPurpleAccent, // สีวงวันนี้
                      minDate: DateTime.now(), // วันที่เลือกได้ต่ำสุด = วันนี้
                      maxDate: DateTime.now().add(
                        const Duration(days: 2),
                      ), // เลือกได้สูงสุด +2 วัน
                      onSelectionChanged: // callback เมื่อมีการเลือกช่วง
                      (DateRangePickerSelectionChangedArgs args) {
                        // รับอาร์กิวเมนต์
                        if (args.value is PickerDateRange) {
                          // ถ้าเป็นช่วงวันที่จริง
                          final PickerDateRange range =
                              args.value; // แคสต์เป็น PickerDateRange
                          setInnerState(() {
                            // อัปเดตสถานะภายใน dialog (ไม่กระทบ widget หลัก)
                            startDate = range.startDate; // เซ็ตวันเริ่ม
                            endDate =
                                range.endDate ??
                                range
                                    .startDate; // ถ้าไม่เลือกวันจบ ให้เท่ากับวันเริ่ม
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16), // เว้น 16
                    // ✅ ปุ่ม confirm/cancel
                    Row(
                      // แถวปุ่ม 2 ปุ่ม
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly, // เว้นห่างเท่ากัน
                      children: [
                        ElevatedButton.icon(
                          // ปุ่มยืนยันพร้อมไอคอน
                          onPressed: () {
                            // เมื่อกดปุ่ม
                            if (startDate == null || endDate == null) {
                              // ถ้ายังไม่เลือกวัน
                              _showSelectAlert(context); // แจ้งเตือนให้เลือกวัน
                              return; // ออก
                            }
                            final diff =
                                endDate!.difference(startDate!).inDays +
                                1; // คำนวณจำนวนวันรวมปลายทาง (บวก 1)
                            if (diff > 2) {
                              // ถ้าเกิน 2 วัน
                              _showLimitAlert(context); // แจ้งเตือนเกินที่กำหนด
                              return; // ออก
                            }

                            Navigator.of(context).pop(); // ปิด dialog ปฏิทิน
                            Navigator.of(context).pop(); // ปิด dialog หลักยืม

                            ScaffoldMessenger.of(context).showSnackBar(
                              // แสดง SnackBar แจ้งยืมสำเร็จ
                              SnackBar(
                                content: Text(
                                  // เนื้อหาแจ้งผล
                                  '✅ Borrowed "${widget.asset['name']}" ' // ชื่อสินค้าที่ถูกยืม
                                  'from ${DateFormat('MMM d').format(startDate!)} ' // วันที่เริ่ม
                                  'to ${DateFormat('MMM d').format(endDate!)}', // วันที่จบ
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ), // สีตัวอักษรขาว
                                ),
                                backgroundColor: Colors.green, // พื้นหลังเขียว
                                duration: const Duration(
                                  seconds: 4,
                                ), // แสดง 4 วินาที
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.check,
                            color: Colors.white,
                          ), // ไอคอนถูก สีขาว
                          label: const Text(
                            // ป้ายข้อความปุ่ม
                            "Confirm", // ยืนยัน
                            style: TextStyle(
                              color: Colors.white,
                            ), // ตัวอักษรสีขาว
                          ),
                          style: ElevatedButton.styleFrom(
                            // สไตล์ปุ่ม
                            backgroundColor: Colors.green, // พื้นหลังเขียว
                            shape: RoundedRectangleBorder(
                              // รูปทรงโค้ง
                              borderRadius: BorderRadius.circular(
                                25,
                              ), // มุมโค้ง 25
                            ),
                            padding: const EdgeInsets.symmetric(
                              // ระยะขอบในปุ่ม
                              horizontal: 22, // ซ้ายขวา 22
                              vertical: 10, // บนล่าง 10
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          // ปุ่มยกเลิกพร้อมไอคอน
                          onPressed: () => Navigator.pop(
                            context,
                          ), // ปิด dialog ปฏิทิน (หรือ dialog ปัจจุบัน)
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ), // ไอคอนกากบาท สีขาว
                          label: const Text(
                            // ข้อความปุ่ม
                            "Cancel", // ยกเลิก
                            style: TextStyle(
                              color: Colors.white,
                            ), // ตัวอักษรขาว
                          ),
                          style: ElevatedButton.styleFrom(
                            // สไตล์ปุ่ม
                            backgroundColor:
                                Colors.redAccent, // สีพื้นแดงอมชมพู
                            shape: RoundedRectangleBorder(
                              // รูปทรงโค้ง
                              borderRadius: BorderRadius.circular(
                                25,
                              ), // มุมโค้ง 25
                            ),
                            padding: const EdgeInsets.symmetric(
                              // ระยะขอบใน
                              horizontal: 22, // ซ้ายขวา 22
                              vertical: 10, // บนล่าง 10
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // บิลด์เนื้อหา dialog หลัก
    final asset = widget.asset; // ดึงข้อมูล asset จากพร็อพของวิดเจ็ต

    return Dialog(
      // แสดงเป็น Dialog หลัก
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ), // ขอบโค้ง 22
      backgroundColor: Colors.white, // พื้นหลังขาว
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 60,
      ), // ระยะห่างจากขอบจอ
      child: Padding(
        // เว้นระยะภายใน dialog
        padding: const EdgeInsets.all(20), // ทุกด้าน 20
        child: Column(
          // จัดวางแนวตั้ง
          mainAxisSize: MainAxisSize.min, // สูงเท่าที่จำเป็น
          crossAxisAlignment: CrossAxisAlignment.center, // จัดกึ่งกลางแนวนอน
          children: [
            Text(
              // ชื่ออุปกรณ์
              asset['name'] ?? "Unknown Asset", // ถ้าไม่มี name แสดง Unknown
              style: const TextStyle(
                // สไตล์ชื่อ
                fontSize: 20, // ขนาด 20
                fontWeight: FontWeight.bold, // หนา
                color: Colors.deepPurpleAccent, // สีม่วง
              ),
            ),
            const SizedBox(height: 10), // เว้น 10
            _buildImage(
              asset['image'] ?? '',
            ), // แสดงรูปอุปกรณ์ (ฟอลแบ็กค่าว่างเป็น '')
            const SizedBox(height: 10), // เว้น 10
            const Text(
              // ข้อความเตือนจำนวนยืม
              "*You can only borrow 1 asset per day", // จำกัด 1 ชิ้น/วัน
              style: TextStyle(
                color: Colors.red,
                fontSize: 13,
              ), // สีแดง ตัวเล็ก
            ),
            const SizedBox(height: 10), // เว้น 10
            Text(
              // แสดงคำอธิบาย
              "Description :\n${asset['description'] ?? 'No description'}", // ถ้าไม่มี description แสดง No description
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ), // สไตล์ตัวอักษร
              textAlign: TextAlign.center, // จัดกลาง
            ),
            const SizedBox(height: 20), // เว้น 20
            Row(
              // ปุ่ม Borrow / Cancel
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // เว้นห่างเท่ากัน
              children: [
                ElevatedButton(
                  // ปุ่ม Borrow
                  onPressed: _openCalendarDialog, // กดแล้วเปิดไดอะล็อกปฏิทิน
                  style: ElevatedButton.styleFrom(
                    // สไตล์ปุ่ม
                    backgroundColor: Colors.deepPurpleAccent, // สีม่วง
                    shape: RoundedRectangleBorder(
                      // ขอบโค้ง
                      borderRadius: BorderRadius.circular(20), // มุมโค้ง 20
                    ),
                    padding: const EdgeInsets.symmetric(
                      // ระยะขอบใน
                      horizontal: 35, // ซ้ายขวา 35
                      vertical: 12, // บนล่าง 12
                    ),
                  ),
                  child: const Text(
                    // ข้อความในปุ่ม
                    'Borrow', // ยืม
                    style: TextStyle(
                      color: Colors.white, // ตัวอักษรขาว
                      fontWeight: FontWeight.bold, // หนา
                    ),
                  ),
                ),
                ElevatedButton(
                  // ปุ่ม Cancel
                  onPressed: () => Navigator.pop(context), // ปิด dialog
                  style: ElevatedButton.styleFrom(
                    // สไตล์ปุ่ม
                    backgroundColor: Colors.grey.shade600, // เทาเข้ม
                    shape: RoundedRectangleBorder(
                      // ขอบโค้ง
                      borderRadius: BorderRadius.circular(20), // มุมโค้ง 20
                    ),
                    padding: const EdgeInsets.symmetric(
                      // ระยะขอบใน
                      horizontal: 35, // ซ้ายขวา 35
                      vertical: 12, // บนล่าง 12
                    ),
                  ),
                  child: const Text(
                    // ข้อความในปุ่ม
                    'Cancel', // ยกเลิก
                    style: TextStyle(
                      color: Colors.white, // ตัวอักษรขาว
                      fontWeight: FontWeight.bold, // หนา
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Alert แสดงเมื่อเลือกเกิน 2 วัน
  void _showLimitAlert(BuildContext context) {
    // ฟังก์ชันแสดง SnackBar เมื่อเลือกเกิน 2 วัน
    ScaffoldMessenger.of(context).showSnackBar(
      // แสดง SnackBar
      const SnackBar(
        content: Text(
          // เนื้อหาแจ้งเตือน
          "⚠️ You can borrow only 1–2 days!", // ข้อจำกัดสูงสุด 2 วัน
          style: TextStyle(color: Colors.white), // ตัวอักษรขาว
        ),
        backgroundColor: Colors.orange, // พื้นหลังส้ม
        duration: Duration(seconds: 2), // แสดง 2 วินาที
      ),
    );
  }

  // ✅ Alert แสดงเมื่อยังไม่เลือกวัน
  void _showSelectAlert(BuildContext context) {
    // ฟังก์ชันแสดง SnackBar เมื่อยังไม่เลือกวัน
    ScaffoldMessenger.of(context).showSnackBar(
      // แสดง SnackBar
      const SnackBar(
        content: Text(
          // เนื้อหาแจ้งเตือน
          "⚠️ Please select borrow and return dates!", // ให้เลือกวันยืมและวันคืนก่อน
          style: TextStyle(color: Colors.white), // ตัวอักษรขาว
        ),
        backgroundColor: Colors.orange, // พื้นหลังส้ม
        duration: Duration(seconds: 2), // แสดง 2 วินาที
      ),
    );
  }
}
