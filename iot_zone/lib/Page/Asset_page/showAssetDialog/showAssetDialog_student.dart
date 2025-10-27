import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class BorrowAssetDialog extends StatefulWidget {
  final Map<String, dynamic> asset;

  const BorrowAssetDialog({super.key, required this.asset});

  @override
  State<BorrowAssetDialog> createState() => _BorrowAssetDialogState();
}

class _BorrowAssetDialogState extends State<BorrowAssetDialog> {
  DateTime? startDate;
  DateTime? endDate;
  String ip = '192.168.1.125';

  // ✅ โหลดภาพจาก server หรือ asset (สมส่วน + โค้ง + เงา + loading)
  // ✅ โหลดภาพจาก asset หรือ server (แสดงสมส่วน)
  Widget _buildImage(String imagePath) {
    final borderRadius = BorderRadius.circular(16);

    return Container(
      height: 120, // ✅ จำกัดความสูงสูงสุดของภาพใน card
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Align(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.contain, // ✅ ปรับขนาดให้พอดีโดยไม่ครอปหรือบีบ
            child:
                imagePath.startsWith('/uploads/') || imagePath.contains('http')
                ? Image.network(
                    'http://$ip:3000$imagePath',
                    height: 100, // ✅ จำกัดขนาดภายในอีกชั้น
                    width: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey,
                    ),
                  )
                : Image.asset(
                    imagePath,
                    height: 100,
                    width: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ✅ ฟังก์ชันเปิดปฏิทินเลือกวันยืม
  void _openCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Choose borrow and return date",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Container(height: 2, color: Colors.blueAccent),
                const SizedBox(height: 10),
                SfDateRangePicker(
                  selectionMode: DateRangePickerSelectionMode.range,
                  startRangeSelectionColor: Colors.blue,
                  endRangeSelectionColor: Colors.blue,
                  rangeSelectionColor: Colors.blue.withOpacity(0.25),
                  todayHighlightColor: Colors.blue,
                  minDate: DateTime.now(),
                  maxDate: DateTime.now().add(const Duration(days: 2)),
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                        if (args.value is PickerDateRange) {
                          final PickerDateRange range = args.value;
                          setState(() {
                            startDate = range.startDate;
                            endDate = range.endDate ?? range.startDate;
                          });
                        }
                      },
                ),
                const SizedBox(height: 16),
                if (startDate != null && endDate != null) ...[
                  Text(
                    "Borrow date : ${DateFormat('MMMM d, yyyy').format(startDate!)}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    "Return date : ${DateFormat('MMMM d, yyyy').format(endDate!)}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (startDate == null || endDate == null) {
                      _showSelectAlert(context);
                      return;
                    }
                    final diff = endDate!.difference(startDate!).inDays + 1;
                    if (diff > 2) {
                      _showLimitAlert(context);
                      return;
                    }

                    Navigator.of(context).pop(); // ปิดปฏิทิน
                    Navigator.of(context).pop(); // ปิด dialog หลัก

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✅ You borrowed "${widget.asset['name']}" '
                          'from ${DateFormat('MMMM d, yyyy').format(startDate!)} '
                          'to ${DateFormat('MMMM d, yyyy').format(endDate!)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Confirm Borrow"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              asset['name'] ?? "Unknown Asset",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildImage(asset['image'] ?? ''),
            const SizedBox(height: 10),
            const Text(
              "*You can only borrow 1 asset a day",
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Text(
              "Description :\n${asset['description'] ?? 'No description'}",
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _openCalendarDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Borrow',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  void _showLimitAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "⚠️ You can borrow only 1–2 days!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSelectAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "⚠️ Please select borrow and return dates!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
