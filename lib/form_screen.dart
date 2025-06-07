import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class PexFormScreen extends StatefulWidget {
  final String userTitle;
  final String userName;

  const PexFormScreen({
    super.key,
    required this.userTitle,
    required this.userName,
  });

  @override
  State<PexFormScreen> createState() => _PexFormScreenState();
}

class _PexFormScreenState extends State<PexFormScreen> {
  final Map<String, String> formData = {};
  final SignatureController doctorSign = SignatureController(penStrokeWidth: 2);
  final SignatureController nurseSign = SignatureController(penStrokeWidth: 2);

  bool isSigning = false;
  Offset? signaturePosition;

  Widget _buildInput(String label, String key, {double? width}) {
    return Row(
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          width: width ?? 150,
          child: GestureDetector(
            onTap: () async {
              if (isSigning) return;
              final result = await showDialog<String>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(label),
                  content: TextField(
                    autofocus: true,
                    onChanged: (value) => formData[key] = value,
                    controller: TextEditingController(text: formData[key]),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, formData[key]),
                        child: const Text("OK"))
                  ],
                ),
              );
              if (result != null) setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Text(formData[key] ?? "", style: const TextStyle(fontSize: 14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignature(String label, SignatureController controller, String infoText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Container(
          height: 100,
          decoration: BoxDecoration(border: Border.all()),
          child: Signature(
            controller: controller,
            backgroundColor: Colors.white,
          ),
        ),
        Text(
          infoText,
          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phiếu theo dõi PEX'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (isSigning) {
                  isSigning = false;
                } else {
                  isSigning = true;
                  signaturePosition = null;
                }
              });
            },
            child: Text(
              isSigning ? "Xác nhận" : "Ký tên",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMainForm(),
          if (isSigning)
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (details) {
                  setState(() {
                    signaturePosition = details.localPosition;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  child: signaturePosition == null
                      ? null
                      : Stack(
                          children: [
                            Positioned(
                              left: signaturePosition!.dx - 12,
                              top: signaturePosition!.dy - 12,
                              child: const Icon(Icons.edit, color: Colors.black),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          if (!isSigning && signaturePosition != null)
            Positioned(
              left: signaturePosition!.dx,
              top: signaturePosition!.dy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Ký", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    "${widget.userTitle} - ${widget.userName}",
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainForm() {
    return SingleChildScrollView(
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
          _buildInput("Họ tên BN", "tenBN"),
          _buildInput("Tuổi", "tuoi"),
          _buildInput("Giới", "gioi"),
          _buildInput("Chẩn đoán", "chanDoan"),
          _buildInput("Dịch lọc", "dichLoc"),
          _buildInput("Giờ ngay", "gioNgay"),
          _buildInput("Sở", "so"),
          _buildInput("Dịch bạn", "dichBan"),
          _buildInput("Lợi", "loi"),
          const Divider(),
          const Text("Cài đặt ban đầu:", style: TextStyle(fontWeight: FontWeight.bold)),
          _buildInput("Tốc độ máu", "tocDoMau"),
          _buildInput("Dịch RF", "dichRF"),
          _buildInput("Dịch DF", "dichDF"),
          _buildInput("Heparin", "heparin"),
          _buildInput("Duy trì", "duyTri"),
          const SizedBox(height: 16),
          _buildSignature("Bác sĩ chỉ định", doctorSign, "${widget.userTitle} - ${widget.userName}"),
          const SizedBox(height: 16),
          const Text("Thông số trong lọc:", style: TextStyle(fontWeight: FontWeight.bold)),
          Table(
            border: TableBorder.all(),
            children: [
              const TableRow(
                children: ["Giờ", "M", "HA", "T°", "BPE", "UF", "LF", "TMP"]
                    .map((e) => Padding(
                          padding: EdgeInsets.all(4),
                          child: Center(child: Text(e, style: TextStyle(fontWeight: FontWeight.bold))),
                        ))
                    .toList(),
              ),
              ...List.generate(
                5,
                (_) => TableRow(
                  children: List.generate(
                    8,
                    (i) => GestureDetector(
                      onTap: () async {
                        if (isSigning) return;
                        final key = "ts_${_}_$i";
                        final result = await showDialog<String>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            content: TextField(
                              autofocus: true,
                              onChanged: (value) => formData[key] = value,
                              controller: TextEditingController(text: formData[key]),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, formData[key]),
                                  child: const Text("OK"))
                            ],
                          ),
                        );
                        if (result != null) setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          formData["ts_${_}_$i"] ?? "",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInput("Kết thúc lọc", "ketThuc"),
          _buildInput("Tổng thời gian lọc", "tongThoiGian"),
          _buildInput("UF", "ufTong"),
          _buildInput("Tổng dịch lọc", "tongDichLoc"),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSignature("Bác sĩ", doctorSign, "${widget.userTitle} - ${widget.userName}")),
              const SizedBox(width: 16),
              Expanded(child: _buildSignature("Điều dưỡng", nurseSign, "${widget.userTitle} - ${widget.userName}")),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadOnlyFormScreen(
          formData: formData,
          userTitle: widget.userTitle,
          userName: widget.userName,
        ),
      ),
    );
  },
  child: const Text("Tạo y lệnh"),
),

        ],
      ),
    );
  }
}
