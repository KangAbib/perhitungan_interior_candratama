import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class INV_Keranjang extends StatefulWidget {
  const INV_Keranjang({super.key});

  @override
  State<INV_Keranjang> createState() => _INV_Keranjang();
}

class _INV_Keranjang extends State<INV_Keranjang> {
  String nama = "Memuat...";
  String alamat = "";
  double subTotal = 0;
  double diskon = 0;
  double uangMuka = 0;
  double pelunasan = 0;
  List<Map<String, dynamic>> listKeranjang = [];
  final formatCurrency = NumberFormat("#,###", "id_ID");

  Future<void> ambilDataKeranjang() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection("pesanan_keranjang")
          .orderBy("timestamp", descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data();

        setState(() {
          nama = data["nama"] ?? "Nama tidak ditemukan";
          alamat = data["alamat"] ?? "";
          subTotal = (data["total_harga"] ?? 0).toDouble();
          diskon = (data["diskon_total"] ?? 0).toDouble();
          uangMuka = (data["uang_muka"] ?? 0).toDouble();
          pelunasan = (data["sisa_pembayaran"] ?? 0).toDouble();
          listKeranjang = List<Map<String, dynamic>>.from(data["items"] ?? []);
        });
      }
    } catch (e) {
      print("Error mengambil data pesanan: $e");
    }
  }

  String formatRupiah(double value) {
    return "Rp ${formatCurrency.format(value)}";
  }

  double getResponsiveFontSize(BuildContext context, {double factor = 0.05}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * factor;
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting("id_ID", null).then((_) {
      setState(() {});
    });
    ambilDataKeranjang();
  }

  @override
  Widget build(BuildContext context) {
    String todayDate =
        DateFormat("EEEE, dd MMM yyyy", "id_ID").format(DateTime.now());
    String noBayar = DateFormat("dd/MM/yyyy").format(DateTime.now());

    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Detail Pembayaran",
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(context, factor: 0.05),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Image.asset(
                    "assets/images/logo_inv1.png",
                    width: MediaQuery.of(context).size.width * 0.35,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              Divider(thickness: 1),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kepada :",
                          style: TextStyle(
                            fontSize:
                                getResponsiveFontSize(context, factor: 0.0355),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          nama,
                          style: TextStyle(
                            fontSize:
                                getResponsiveFontSize(context, factor: 0.03),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          alamat,
                          style: TextStyle(
                            fontSize:
                                getResponsiveFontSize(context, factor: 0.03),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16), // Jarak antara dua bagian
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tanggal :",
                        style: TextStyle(
                          fontSize:
                              getResponsiveFontSize(context, factor: 0.0355),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        todayDate,
                        style: TextStyle(
                          fontSize:
                              getResponsiveFontSize(context, factor: 0.03),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
  child: SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(2),
          },
          border: TableBorder.all(color: Colors.black),
          children: [
            _buildTableRow(["Kategori", "Harga"], isHeader: true, context: context), // Hanya dua kolom
            ...List<TableRow>.from(
              (listKeranjang
                    .where((item) => item["timestamp"] != null)
                    .toList()
                    ..sort((a, b) => b["timestamp"].compareTo(a["timestamp"])))
                  .map((item) => _buildTableRow([
                        item["nama"]?.toString() ?? "-",
                        formatRupiah((item["harga"] ?? 0).toDouble()),
                      ], context: context)),
            ),
          ],
        ),
      ],
    ),
  ),
),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pembayaran : ",
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(context, factor: 0.0355),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Sub Total : ${formatRupiah(subTotal)}",
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, factor: 0.03),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Diskon : ${formatRupiah(diskon)}",
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, factor: 0.03),
                      ),
                    ),
                    Text(
                      "Uang Muka : ${formatRupiah(uangMuka)}",
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, factor: 0.03),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 2,
                            color: Colors.black,
                            indent: MediaQuery.of(context).size.width * 0.7,
                            endIndent: 5,
                          ),
                        ),
                        Text(
                          "-",
                          style: TextStyle(
                            fontSize:
                                getResponsiveFontSize(context, factor: 0.04),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Pelunasan : ${formatRupiah(pelunasan)}",
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, factor: 0.03),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells,
      {bool isHeader = false, required BuildContext context}) {
    return TableRow(
      children: cells.map((text) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: TextStyle(
              fontSize: getResponsiveFontSize(context, factor: 0.0355),
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              
            ),
          ),
        );
      }).toList(),
    );
  }
}
