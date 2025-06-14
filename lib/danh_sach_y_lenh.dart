import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'form_dieu_duong.dart';
import 'lich_su_theo_doi.dart';

class YLenhRepository {
  static const _storageKey = 'y_lenh_list';

  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_storageKey) ?? [];
    return data.map((e) => json.decode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> save(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    final data = list.map((e) => json.encode(e)).toList();
    await prefs.setStringList(_storageKey, data);
  }

  static Future<void> add(Map<String, dynamic> yLenh) async {
    final list = await load();
    list.add(yLenh);
    await save(list);
  }

  static Future<void> delete(int index) async {
    final list = await load();
    list.removeAt(index);
    await save(list);
  }
}

class DanhSachYLenhScreen extends StatefulWidget {
  final String userTitle;
  final String userName;

  const DanhSachYLenhScreen({
    super.key,
    required this.userTitle,
    required this.userName,
  });

  @override
  State<DanhSachYLenhScreen> createState() => _DanhSachYLenhScreenState();
}

class _DanhSachYLenhScreenState extends State<DanhSachYLenhScreen> {
  List<Map<String, dynamic>> yLenhList = [];

  @override
  void initState() {
    super.initState();
    _loadYLenh();
  }

  Future<void> _loadYLenh() async {
    final list = await YLenhRepository.load();
    setState(() => yLenhList = list);
  }

  Future<void> _deleteYLenh(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xoá y lệnh"),
        content: const Text("Bạn có chắc chắn muốn xoá y lệnh này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Không")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Có")),
        ],
      ),
    );

    if (confirm == true) {
      await YLenhRepository.delete(index);
      await _loadYLenh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách y lệnh"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LichSuTheoDoiScreen()),
                );
              },
              child: const Text(
                'Lịch sử theo dõi',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: yLenhList.length,
        itemBuilder: (context, index) {
          final yLenh = yLenhList[index];
          final from = yLenh['from'] ?? 'Không rõ';

          return ListTile(
            title: Text("Y lệnh từ: $from"),
            subtitle: const Text("Nhấn để xem và nhập dữ liệu"),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteYLenh(index),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormDieuDuongScreen(
                    formData: Map<String, String>.from(yLenh['form']),
                    bacSi: from,
                    dieuDuong: "${widget.userTitle} - ${widget.userName}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
