import 'dart:convert';
import 'dart:io';
import 'package:udp/udp.dart';
import 'dart:async';

class WifiBroadcast {
  static const String _multicastAddress = "239.1.2.3";
  static const int _port = 4567;

  static String _deviceName = "unknown"; // Tên thiết bị dùng họ tên người dùng

  /// Đăng ký tên thiết bị – gọi khi người dùng đăng nhập
  static void register(String name) {
    _deviceName = name;
  }

  static String get deviceName => _deviceName;

  /// Gửi dữ liệu dạng Map (biểu mẫu y lệnh) tới toàn bộ thiết bị trong mạng LAN
  static Future<void> sendForm(Map<String, dynamic> formData) async {
    final udp = await UDP.bind(Endpoint.any(port: Port(0)));

    final payload = {
      "from": _deviceName,
      "form": formData,
    };

    final message = utf8.encode(json.encode(payload));

    await udp.send(message, Endpoint.multicast(
      InternetAddress(_multicastAddress),
      port: Port(_port),
    ));

    await udp.close();
  }

  /// Lắng nghe dữ liệu nhận được từ thiết bị khác
  static Future<void> listen(Function(String from, Map<String, dynamic> formData) onReceived) async {
    final udp = await UDP.bind(
      Endpoint.multicast(
        InternetAddress(_multicastAddress),
        port: Port(_port),
      ),
    );

    udp.asStream().listen((datagram) {
      try {
        final str = utf8.decode(datagram?.data ?? []);
        final jsonData = json.decode(str);
        final from = jsonData["from"] ?? "Không rõ";
        final form = Map<String, dynamic>.from(jsonData["form"] ?? {});
        onReceived(from, form);
      } catch (_) {
        // Bỏ qua lỗi
      }
    });
  }
}
