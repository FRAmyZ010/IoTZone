import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class BorrowAssetDialog extends StatefulWidget {
  final Map<String, dynamic> asset;

  const BorrowAssetDialog({super.key, required this.asset});

  @override
  State<BorrowAssetDialog> createState() => _BorrowAssetDialogState();
}

class _BorrowAssetDialogState extends State<BorrowAssetDialog> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
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

              // 🔹 ปฏิทินเลือกช่วงวันที่
              SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.range,
                startRangeSelectionColor: Colors.blue,
                endRangeSelectionColor: Colors.blue,
                rangeSelectionColor: Colors.blue.withOpacity(0.25),
                todayHighlightColor: Colors.blue,
                minDate: DateTime.now(),
                maxDate: DateTime.now().add(const Duration(days: 2)),
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
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

              // 🔹 แสดงวันยืมและวันคืน
              if (startDate != null && endDate != null) ...[
                Text(
                  "Borrow date : ${DateFormat('MMMM d, yyyy').format(startDate!)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Return date : ${DateFormat('MMMM d, yyyy').format(endDate!)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 25),

              // 🔹 ปุ่ม Borrow / Cancel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ✅ Borrow
                  ElevatedButton(
                    onPressed: () {
                      if (startDate != null && endDate != null) {
                        final diff = endDate!.difference(startDate!).inDays + 1;
                        if (diff <= 2) {
                          Navigator.of(context).pop();
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
                        } else {
                          _showLimitAlert(context);
                        }
                      } else {
                        _showSelectAlert(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 35,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Borrow',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                  // ❌ Cancel
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 35,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
