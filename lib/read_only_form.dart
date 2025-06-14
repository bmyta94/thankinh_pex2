import 'package:flutter/material.dart';
import 'network/wifi_broadcast.dart'; 

class ReadOnlyFormScreen extends StatelessWidget {
  final Map<String, String> formData;
  final String userTitle;
  final String userName;

  const ReadOnlyFormScreen({
    super.key,
    required this.formData,
    required this.userTitle,
    required this.userName,
  });

  Widget _buildRow(String label, String key, {double? width}) {
    return Row(
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          width: width ?? 200,
          child: Text(formData[key] ?? "", style: const TextStyle(fontSize: 14)),
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
                child: Center(
                    child: Text(e, style: const TextStyle(fontWeight: FontWeight.bold))),
              ))
          .toList(),
    );
  }

  TableRow _buildDataRow(int row) {
    return TableRow(
      children: List.generate(
        8,
        (i) => Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            formData["ts_${row}_$i"] ?? "",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xem lại y lệnh"),
        actions: [
          TextButton(
            onPressed: () async {
              await WifiBroadcast.sendForm({
                "from": "$userTitle - $userName",
                "form": formData,
              });

              if (!context.mounted) return;

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  content: const Text("Đã gửi y lệnh thành công."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // đóng dialog
                        Navigator.of(context).pop(); // về form_screen
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
            child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
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
              Text(
                "Bác sĩ chỉ định: Ký",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "$userTitle - $userName",
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              const Text("Thông số trong lọc:", style: TextStyle(fontWeight: FontWeight.bold)),
              Table(
                border: TableBorder.all(),
                children: [
                  _buildTableHeader(),
                  ...List.generate(5, _buildDataRow),
                ],
              ),
              const SizedBox(height: 16),
              _buildRow("Kết thúc lọc", "ketThuc"),
              _buildRow("Tổng thời gian lọc", "tongThoiGian"),
              _buildRow("UF", "ufTong"),
              _buildRow("Tổng dịch lọc", "tongDichLoc"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Bác sĩ", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("$userTitle - $userName",
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Điều dưỡng", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("$userTitle - $userName",
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
