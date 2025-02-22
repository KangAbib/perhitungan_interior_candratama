import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class INV_TipeStraight extends StatefulWidget {
  const INV_TipeStraight({super.key});

  @override
  State<INV_TipeStraight> createState() => _INV_TipeStraightState();
}

class _INV_TipeStraightState extends State<INV_TipeStraight> {
  String nama = "Memuat...";
  String alamat = "";

  @override
  void initState() {
    super.initState();
    ambilDataTerakhir();
  }

  void ambilDataTerakhir() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection("pesanan")
          .orderBy("tanggal", descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data();
        setState(() {
          nama = data["nama"] ?? "Nama tidak ditemukan";
          alamat = data["alamat"] ?? "Alamat tidak ditemukan";
        });
      } else {
        setState(() {
          nama = "Data tidak tersedia";
          alamat = "";
        });
      }
    } catch (e) {
      setState(() {
        nama = "Gagal memuat data";
        alamat = "";
      });
    }
  }

  double getResponsiveFontSize(BuildContext context, {double factor = 0.05}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * factor;
  }

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat("EEEE, dd MMM yyyy").format(DateTime.now());
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
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(2),
                  },
                  border: TableBorder.all(color: Colors.black),
                  children: [
                    _buildTableRow(["Keterangan", "Harga", "Jml (m)", "Total"],
                        isHeader: true, context: context),
                    _buildTableRow(["Kitchen atas", "", "", ""],
                        context: context),
                    _buildTableRow(["Kitchen bawah", "", "", ""],
                        context: context),
                    _buildTableRow(["Top Table", "", "", ""], context: context),
                    _buildTableRow(["Backsplash", "", "", ""],
                        context: context),
                    _buildTableRow(["Aksesoris", "", "", ""], context: context),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pembayaran : ${isTablet ? "Kitchen Straight" : "Straight"}",
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(context, factor: 0.0355),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Sub Total : Rp ",
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
                      "Uang Muka : Rp ",
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
                      "Pelunasan : Rp ",
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
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            cell,
            style: TextStyle(
              fontSize: getResponsiveFontSize(context, factor: 0.0355),
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: isHeader ? TextAlign.center : TextAlign.left,
          ),
        );
      }).toList(),
    );
  }
}
