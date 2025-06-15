import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'form_screen.dart';
import 'danh_sach_y_lenh.dart';
import 'read_only_form.dart';
import 'network/wifi_broadcast.dart';
import 'repository/y_lenh_repository.dart' as repo;

void main() {
  runApp(const AppWrapper());
}

// Hàm hỗ trợ parse kiểu dữ liệu an toàn
int safeParseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? defaultValue;
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupWifiListener();
  }

  void _setupWifiListener() {
    WifiBroadcast.listen((data) async {
      try {
        if (data is! Map<String, dynamic>) {
          debugPrint('Invalid data format: Expected Map<String, dynamic>');
          return;
        }

        final sender = data["from"]?.toString() ?? 'Unknown';
        final receivedForm = data["form"];

        if (receivedForm == null) {
          debugPrint('Received null form data');
          return;
        }

        final parsedForm = _parseFormData(receivedForm);

        await repo.YLenhRepository.add({
          "from": sender,
          "form": parsedForm
        });
      } catch (e) {
        debugPrint("Error processing network data: ${e.toString()}");
      }
    });
  }

  Map<String, dynamic> _parseFormData(dynamic formData) {
    final Map<String, dynamic> result = {};

    if (formData is Map) {
      formData.forEach((key, value) {
        final String safeKey = key?.toString() ?? 'null_key';
        
        // Xử lý kiểu dữ liệu an toàn
        if (value == null) {
          result[safeKey] = null;
        } else if (value is int || value is double) {
          result[safeKey] = value;
        } else if (value is bool) {
          result[safeKey] = value;
        } else {
          // Đảm bảo không có trường hợp String -> int trực tiếp
          final strValue = value.toString();
          result[safeKey] = _isNumeric(strValue) ? safeParseInt(strValue) : strValue;
        }
      });
    }
    return result;
  }

  bool _isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navKey,
      debugShowCheckedModeBanner: false,
      home: LoginScreen(navKey: _navKey),
    );
  }
}

// ... (Phần LoginScreen giữ nguyên không thay đổi)
