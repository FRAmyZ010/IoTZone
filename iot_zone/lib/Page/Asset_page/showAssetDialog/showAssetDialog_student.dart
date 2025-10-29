import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:iot_zone/Page/AppConfig.dart';

class BorrowAssetDialog extends StatefulWidget {
  final Map<String, dynamic> asset;

  const BorrowAssetDialog({super.key, required this.asset});

  @override
  State<BorrowAssetDialog> createState() => _BorrowAssetDialogState();
}

class _BorrowAssetDialogState extends State<BorrowAssetDialog> {
  DateTime? startDate;
  DateTime? endDate;
  final String ip = AppConfig.serverIP;

  // ✅ โหลดภาพแบบสมส่วน
  Widget _buildImage(String imagePath) {
    final borderRadius = BorderRadius.circular(16);
    return Container(
      height: 120,
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
            fit: BoxFit.contain,
            child:
                imagePath.startsWith('/uploads/') || imagePath.contains('http')
                ? Image.network(
                    'http://$ip:3000$imagePath',
                    height: 100,
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

  // ✅ ปฏิทินพร้อมโชว์วันยืมและวันคืน
  void _openCalendarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: StatefulBuilder(
              builder: (context, setInnerState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        "📅 Select Borrow & Return Date",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.deepPurpleAccent,
                      thickness: 1.2,
                    ),
                    const SizedBox(height: 6),

                    // ✅ แสดงวันยืมและวันคืนแบบสวยๆ
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                "Borrow Date",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                startDate != null
                                    ? DateFormat(
                                        'MMM d, yyyy',
                                      ).format(startDate!)
                                    : '--',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_right_alt_rounded,
                            color: Colors.deepPurpleAccent,
                          ),
                          Column(
                            children: [
                              const Text(
                                "Return Date",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                endDate != null
                                    ? DateFormat('MMM d, yyyy').format(endDate!)
                                    : '--',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ✅ ปฏิทิน Syncfusion
                    SfDateRangePicker(
                      selectionMode: DateRangePickerSelectionMode.range,
                      startRangeSelectionColor: Colors.deepPurpleAccent,
                      endRangeSelectionColor: Colors.deepPurpleAccent,
                      rangeSelectionColor: Colors.deepPurpleAccent.withOpacity(
                        0.25,
                      ),
                      todayHighlightColor: Colors.deepPurpleAccent,
                      minDate: DateTime.now(),
                      maxDate: DateTime.now().add(const Duration(days: 2)),
                      onSelectionChanged:
                          (DateRangePickerSelectionChangedArgs args) {
                            if (args.value is PickerDateRange) {
                              final PickerDateRange range = args.value;
                              setInnerState(() {
                                startDate = range.startDate;
                                endDate = range.endDate ?? range.startDate;
                              });
                            }
                          },
                    ),

                    const SizedBox(height: 16),

                    // ✅ ปุ่ม confirm/cancel
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (startDate == null || endDate == null) {
                              _showSelectAlert(context);
                              return;
                            }
                            final diff =
                                endDate!.difference(startDate!).inDays + 1;
                            if (diff > 2) {
                              _showLimitAlert(context);
                              return;
                            }

                            Navigator.of(context).pop();
                            Navigator.of(context).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '✅ Borrowed "${widget.asset['name']}" '
                                  'from ${DateFormat('MMM d').format(startDate!)} '
                                  'to ${DateFormat('MMM d').format(endDate!)}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text(
                            "Confirm",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 10,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                          label: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 10,
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 10),
            _buildImage(asset['image'] ?? ''),
            const SizedBox(height: 10),
            const Text(
              "*You can only borrow 1 asset per day",
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
                    backgroundColor: Colors.deepPurpleAccent,
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
                    backgroundColor: Colors.grey.shade600,
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

  // ✅ Alert แสดงเมื่อเลือกเกิน 2 วัน
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

  // ✅ Alert แสดงเมื่อยังไม่เลือกวัน
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
