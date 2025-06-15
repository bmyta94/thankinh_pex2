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
        if (data is! Map) {
          debugPrint('Dữ liệu nhận được không phải dạng Map');
          return;
        }

        final sender = data["from"]?.toString() ?? 'Unknown';
        final receivedForm = data["form"];

        if (receivedForm == null) {
          debugPrint('Không có dữ liệu form');
          return;
        }

        final parsedForm = _parseFormData(receivedForm);

        await repo.YLenhRepository.add({
          "from": sender,
          "form": parsedForm
        });
      } catch (e) {
        debugPrint("Lỗi xử lý dữ liệu: $e");
        debugPrint("Dữ liệu gây lỗi: ${data.toString()}");
      }
    });
  }

  Map<String, dynamic> _parseFormData(dynamic formData) {
    final Map<String, dynamic> result = {};

    if (formData is Map) {
      formData.forEach((key, value) {
        final String safeKey = key?.toString() ?? 'null_key';
        
        if (value == null) {
          result[safeKey] = null;
        } else if (value is num || value is String || value is bool) {
          result[safeKey] = value;
        } else {
          result[safeKey] = value.toString();
        }
      });
    }

    return result;
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

class LoginScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navKey;
  const LoginScreen({super.key, required this.navKey});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedRole;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Chức danh',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Bác sĩ', child: Text('Bác sĩ')),
                  DropdownMenuItem(value: 'Điều dưỡng', child: Text('Điều dưỡng')),
                ],
                onChanged: (value) => setState(() => _selectedRole = value),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _handleLogin,
                child: const Text('Xác nhận'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_controller.text.isEmpty || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    if (_selectedRole == 'Bác sĩ') {
      widget.navKey.currentState!.pushReplacement(
        MaterialPageRoute(
          builder: (_) => FormScreen(hoTen: _controller.text),
        ),
      );
    } else if (_selectedRole == 'Điều dưỡng') {
      widget.navKey.currentState!.pushReplacement(
        MaterialPageRoute(
          builder: (_) => DanhSachYLenh(hoTen: _controller.text),
        ),
      );
    }
  }
}
