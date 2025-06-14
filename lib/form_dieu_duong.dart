import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FormDieuDuongScreen extends StatefulWidget {
  final Map<String, String> formData;
  final String bacSi;
  final String dieuDuong;

  const FormDieuDuongScreen({
    super.key,
    required this.formData,
    required this.bacSi,
    required this.dieuDuong,
  });

  @override
  State<FormDieuDuongScreen> createState() => _FormDieuDuongScreenState();
}

class _FormDieuDuongScreenState extends State<FormDieuDuongScreen> {
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    for (var entry in widget.formData.entries) {
      controllers[entry.key] = TextEditingController(text: entry.value);
    }

    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 8; col++) {
        final key = "ts_${row}_$col";
        if (!controllers.containsKey(key)) {
          controllers[key] = TextEditingController();
        }
      }
    }

    for (var key in ["ketThuc", "tongThoiGian", "ufTong", "tongDichLoc"]) {
      controllers.putIfAbsent(key, () => TextEditingController());
    }
  }

  Widget _buildRow(String label, String key, {bool enabled = false}) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text("$label:")),
        Expanded(
          child: TextField(
            controller: controllers[key],
            enabled: enabled,
            decoration: const InputDecoration(isDense: true),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableHeader() {
    const headers = ["Giờ", "M", "HA", "T°", "BPE", "UF", "LF", "TMP"];
    return TableRow(
      children: headers
          .map((e) => Padding(
                padding: const EdgeInsets.all(4),
                child: Center(child: Text(e, style: const TextStyle(fontWeight: FontWeight.bold))),
              ))
          .toList(),
    );
  }

  TableRow _buildTableRow(int row) {
    return TableRow(
      children: List.generate(
        8,
        (i) {
          final key = "ts_${row}_$i";
          return Padding(
            padding: const EdgeInsets.all(4),
            child: TextField(
              controller: controllers[key],
              decoration: const InputDecoration(isDense: true),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  Future<void> _luuLichSu() async {
    final submittedForm = <String, String>{};
    controllers.forEach((key, value) {
      submittedForm[key] = value.text;
    });

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList('y_lenh_da_tra_loi') ?? [];

    existing.add(json.encode({
      "bacSi": widget.bacSi,
      "dieuDuong": widget.dieuDuong,
      "form": submittedForm,
      "time": DateTime.now().toIso8601String(),
    }));

    await prefs.setStringList('y_lenh_da_tra_loi', existing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phiếu theo dõi")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "PHIẾU THEO DÕI BỆNH NHÂN THAY HUYẾT TƯƠNG",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            _buildRow("Họ tên BN", "tenBN"),
            _buildRow("Tuổi", "tuoi"),
            _buildRow("Giới", "gioi"),
            _buildRow("Chẩn đoán", "chanDoan"),
            _buildRow("Dịch lọc", "dichLoc"),
            _buildRow("Giờ ngay", "gioNgay"),
            _buildRow("Sở", "so"),
            _buildRow("Dịch bạn", "dichBan"),
            _buildRow("Lợi", "loi"),

            const Divider(),
            const Text("Cài đặt ban đầu:", style: TextStyle(fontWeight: FontWeight.bold)),
            _buildRow("Tốc độ máu", "tocDoMau"),
            _buildRow("Dịch RF", "dichRF"),
            _buildRow("Dịch DF", "dichDF"),
            _buildRow("Heparin", "heparin"),
            _buildRow("Duy trì", "duyTri"),

            const SizedBox(height: 16),
            Text("Bác sĩ chỉ định: Ký", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.bacSi, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),

            const SizedBox(height: 16),
            const Text("Thông số trong lọc:", style: TextStyle(fontWeight: FontWeight.bold)),
            Table(
              border: TableBorder.all(),
              children: [
                _buildTableHeader(),
                ...List.generate(5, _buildTableRow),
              ],
            ),

            const SizedBox(height: 16),
            _buildRow("Kết thúc lọc", "ketThuc", enabled: true),
            _buildRow("Tổng thời gian lọc", "tongThoiGian", enabled: true),
            _buildRow("UF", "ufTong", enabled: true),
            _buildRow("Tổng dịch lọc", "tongDichLoc", enabled: true),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Bác sĩ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(widget.bacSi, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Điều dưỡng", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(widget.dieuDuong, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _luuLichSu();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã lưu vào Lịch sử theo dõi.")),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Xác nhận"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
