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

    WifiBroadcast.listen((data) async {
      final sender = data["from"];
      final receivedForm = data["form"];

      final parsedForm = <String, dynamic>{};
      (receivedForm as Map).forEach((key, value) {
        parsedForm[key.toString()] = value;
      });

      await repo.YLenhRepository.add({"from": sender, "form": parsedForm});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navKey,
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
                decoration: const InputDecoration(labelText: 'Họ và tên'),
              ),
              DropdownButton<String>(
                value: _selectedRole,
                hi
