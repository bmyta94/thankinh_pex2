
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class YLenhRepository {
  static const _key = 'danh_sach_y_lenh';

  static Future<void> add(Map<String, dynamic> yLenh) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode(yLenh));
    await prefs.setStringList(_key, list);
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  static Future<void> delete(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await prefs.setStringList(_key, list);
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
