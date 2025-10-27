import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'asset_listmap/asset_model.dart';
import 'showAssetDialog/showAssetDialog_staff.dart';

class AssetStaff extends StatefulWidget {
  const AssetStaff({super.key});

  @override
  State<AssetStaff> createState() => _AssetStaffState();
}

class _AssetStaffState extends State<AssetStaff> {
  final List<String> types = const [
    'Type',
    'Board',
    'Module',
    'Sensor',
    'Tool',
    'Component',
    'Measurement',
    'Logic',
  ];
  String selectedType = 'All';

  List<AssetModel> assets = [];
  bool isLoading = true;
  String? errorMessage;

  ImageProvider _buildImageProvider(String imagePath) {
    if (imagePath.isEmpty) return const AssetImage('asset/img/no_image.png');
    if (imagePath.startsWith('asset/')) return AssetImage(imagePath);
    if (!imagePath.startsWith('/uploads/') && !imagePath.contains('http')) {
      return AssetImage('asset/img/$imagePath');
    }
    if (imagePath.startsWith('/uploads/')) {
      return NetworkImage('http://10.0.2.2:3000$imagePath');
    }
    return const AssetImage('asset/img/no_image.png');
  }

  Future<void> fetchAssets() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/assets'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          assets = data.map((e) => AssetModel.fromMap(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to fetch data (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Connection error: $e';
      });
    }
  }

  Future<void> updateStatusInAPI(int id, String newStatus) async {
    int statusCode = switch (newStatus) {
      'Available' => 1,
      'Disabled' => 2,
      'Pending' => 3,
      'Borrowed' => 4,
      _ => 1,
    };

    await http.patch(
      Uri.parse('http://10.0.2.2:3000/assets/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': statusCode}),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchAssets();
  }

  Future<void> addAsset(AssetModel newAsset) async {
    await http.post(
      Uri.parse('http://10.0.2.2:3000/assets'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newAsset.toMap()),
    );
    fetchAssets();
  }

  Future<void> updateAsset(AssetModel asset) async {
    await http.put(
      Uri.parse('http://10.0.2.2:3000/assets/${asset.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(asset.toMap()),
    );
    fetchAssets();
  }

  Future<void> deleteAsset(int id) async {
    await http.delete(Uri.parse('http://10.0.2.2:3000/assets/$id'));
    fetchAssets();
  }

  void _openAssetDialog({AssetModel? asset}) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ShowAssetDialogStaff(asset: asset),
    );
    if (result is AssetModel) {
      if (asset == null) {
        addAsset(result);
      } else {
        updateAsset(result);
      }
    }
  }

  void _toggleStatus(AssetModel asset) async {
    final newStatus = asset.status == 'Disabled' ? 'Available' : 'Disabled';
    await updateStatusInAPI(asset.id, newStatus);

    setState(() {
      assets = assets.map((a) {
        if (a.id == asset.id) {
          return a.copyWith(
            status: newStatus,
            statusColorValue: newStatus == 'Available'
                ? Colors.green.value
                : Colors.redAccent.value,
          );
        }
        return a;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredAssets = selectedType == 'All'
        ? assets
        : assets.where((a) => a.type == selectedType).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asset (Staff)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      backgroundColor: const Color(0xFFF9F6FF),
      body: RefreshIndicator(
        onRefresh: fetchAssets,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurpleAccent,
                ),
              )
            : errorMessage != null
            ? Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Filter row
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => setState(() => selectedType = 'All'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: selectedType == 'All'
                                  ? const Color(0xFF8C6BFF)
                                  : Colors.grey.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: Text(
                            'All',
                            style: TextStyle(
                              color: selectedType == 'All'
                                  ? const Color(0xFF8C6BFF)
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.2,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value:
                                    (selectedType != 'All' &&
                                        selectedType != 'Type')
                                    ? selectedType
                                    : null,
                                hint: const Text(
                                  'Select Type',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                items: types.map((t) {
                                  return DropdownMenuItem<String>(
                                    value: t,
                                    child: Text(
                                      t,
                                      style: TextStyle(
                                        color: t == 'Type'
                                            ? Colors.grey
                                            : Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(
                                    () => selectedType = (v == 'Type')
                                        ? 'All'
                                        : v,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 🔍 Search + Add
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Search your item',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _openAssetDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            '+ Add item',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Asset List",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: GridView.builder(
                        itemCount: filteredAssets.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.59,
                            ),
                        itemBuilder: (context, index) {
                          final asset = filteredAssets[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image(
                                    image: _buildImageProvider(asset.image),
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  asset.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Status: ${asset.status}",
                                  style: TextStyle(color: asset.statusColor),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () =>
                                      _openAssetDialog(asset: asset),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                  ),
                                  child: const Text('EDIT'),
                                ),
                                const SizedBox(height: 6),
                                ElevatedButton(
                                  onPressed: () => _toggleStatus(asset),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: asset.status == 'Disabled'
                                        ? Colors.green
                                        : Colors.redAccent,
                                  ),
                                  child: Text(
                                    asset.status == 'Disabled'
                                        ? 'ENABLE'
                                        : 'DISABLE',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
