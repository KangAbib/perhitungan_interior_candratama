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
  List<Map<String, dynamic>> listKeranjang = [];
  final formatCurrency = NumberFormat("#,###", "id_ID");

  Future<void> ambilDataKeranjang() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection("pesanan_keranjang")
          .orderBy("timestamp", descending: true)
          .limit(1) // Ambil pesanan terbaru
          .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data();

        setState(() {
          nama = data["nama"] ?? "Nama tidak ditemukan";
          alamat = data["alamat"] ?? "";
          subTotal = (data["totalHarga"] ?? 0).toDouble();
          diskon = (data["diskon"] ?? 0).toDouble();
          uangMuka = (data["uangMuka"] ?? 0).toDouble();
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
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
                                  getResponsiveFontSize(context, factor: 0.03)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          alamat,
                          style: TextStyle(
                              fontSize:
                                  getResponsiveFontSize(context, factor: 0.03)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
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
                                getResponsiveFontSize(context, factor: 0.03)),
                      ),
                      Text(
                        "No Bayar :",
                        style: TextStyle(
                          fontSize:
                              getResponsiveFontSize(context, factor: 0.0355),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        noBayar,
                        style: TextStyle(
                            fontSize:
                                getResponsiveFontSize(context, factor: 0.03)),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3), // Nama
                      1: FlexColumnWidth(2), // Harga
                      2: FlexColumnWidth(2), // Total
                    },
                    border: TableBorder.all(color: Colors.black),
                    children: [
                      _buildTableRow(["Nama", "Harga", "Total"],
                          isHeader: true, context: context),
                      ...listKeranjang.map((item) {
                        return _buildTableRow([
                          item["nama"],
                          item["harga"],
                          item["total"],
                        ], context: context);
                      }).toList(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
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
                      "Sub Total : $subTotal",
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
                      "Uang Muka : $uangMuka",
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
                      "Pelunasan : ",
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
