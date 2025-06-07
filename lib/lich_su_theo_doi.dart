import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LichSuTheoDoiScreen extends StatefulWidget {
  const LichSuTheoDoiScreen({super.key});

  @override
  State<LichSuTheoDoiScreen> createState() => _LichSuTheoDoiScreenState();
}

class _LichSuTheoDoiScreenState extends State<LichSuTheoDoiScreen> {
  List<Map<String, dynamic>> lichSu = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('y_lenh_da_tra_loi') ?? [];

    setState(() {
      lichSu = stored.map((e) => json.decode(e)).toList().cast<Map<String, dynamic>>();
    });
  }

  Future<void> _xoaItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('y_lenh_da_tra_loi') ?? [];

    stored.removeAt(index);
    await prefs.setStringList('y_lenh_da_tra_loi', stored);

    setState(() {
      lichSu.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử theo dõi")),
      body: lichSu.isEmpty
          ? const Center(child: Text("Chưa có biểu mẫu nào được lưu."))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: lichSu.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = lichSu[index];
                final time = item["time"] ?? "";
                final bacSi = item["bacSi"] ?? "";
                final dieuDuong = item["dieuDuong"] ?? "";
                final tenBN = item["form"]["tenBN"] ?? "";

                return ListTile(
                  title: Text("Bệnh nhân: $tenBN"),
                  subtitle: Text("Bác sĩ: $bacSi\nĐiều dưỡng: $dieuDuong\nThời gian: $time"),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Xác nhận xoá"),
                          content: const Text("Bạn có chắc muốn xoá biểu mẫu này?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Không")),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Có")),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        _xoaItem(index);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}

