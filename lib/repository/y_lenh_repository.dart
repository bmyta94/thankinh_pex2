import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class YLenhRepository {
  static const _storageKey = 'received_y_lenh_list';

  /// Thêm một y lệnh mới vào danh sách đã nhận
  static Future<void> add(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();

    final rawList = prefs.getStringList(_storageKey) ?? [];
    rawList.add(jsonEncode(item));

    await prefs.setStringList(_storageKey, rawList);
  }

  /// Lấy toàn bộ danh sách y lệnh đã nhận
  static Future<List<Map<String, dynamic>>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? [];

    return rawList
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  /// Xoá y lệnh theo index
  static Future<void> removeAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey) ?? [];

    if (index >= 0 && index < rawList.length) {
      rawList.removeAt(index);
      await prefs.setStringList(_storageKey, rawList);
    }
  }

  /// Xoá toàn bộ y lệnh
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

