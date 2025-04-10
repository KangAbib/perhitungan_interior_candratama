import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class INV_Partisi extends StatefulWidget {
  const INV_Partisi({super.key});

  @override
  State<INV_Partisi> createState() => _INV_Partsi();
}

class _INV_Partsi extends State<INV_Partisi> {
  String nama = "Memuat...";
  String alamat = "";
  String hargaPartisi = "";
  String jumlahAtas = "";
  String ukuranPartisi = "";
  String uangMuka = "";
  String subTotal = "";
  String pelunasan = "";
  String tanggal = "";
  String biayaSurvey = "";

  double parseCurrency(String text) {
    String cleanedText = text.replaceAll("Rp ", "").replaceAll(".", "").trim();
    return double.tryParse(cleanedText) ?? 0.0;
  }

  void ambilDataTerakhir() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection("pesanan Partisi")
          .orderBy("tanggal", descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data();

        double jumlahAtasValue = parseCurrency(data["jumlahAtas"] ?? "Rp 0");

        setState(() {
          nama = data["nama"] ?? "Nama tidak ditemukan";
          alamat = data["alamat"] ?? "Alamat tidak ditemukan";
          hargaPartisi = data["hargaPartisi"] ?? "Rp 0";
          jumlahAtas = data["jumlahAtas"] ?? "Rp 0";
          ukuranPartisi = data["jumlahKali"] ?? "0";
          uangMuka = data["uangMuka"] ?? "Rp 0";
          biayaSurvey = data["biayaSurvey"] ?? "Rp 0";
          subTotal =
              "Rp ${NumberFormat("#,###", "id_ID").format(jumlahAtasValue)}";
          pelunasan = data["pelunasan"] ?? "Rp 0";

          var timestamp = data["tanggal"];
          if (timestamp is Timestamp) {
            tanggal = DateFormat("EEEE, dd MMM yyyy", "id_ID")
                .format(timestamp.toDate());
          } else {
            tanggal = "Tanggal tidak ditemukan";
          }
        });
      } else {
        setState(() {
          nama = "Data tidak tersedia";
          alamat = "";
          hargaPartisi = "Rp 0";
          jumlahAtas = "Rp 0";
          ukuranPartisi = "0";
          uangMuka = "Rp 0";
          subTotal = "Rp 0";
          pelunasan = "Rp 0";
          biayaSurvey = "Rp 0";
        });
      }
    } catch (e) {
      setState(() {
        nama = "Gagal memuat data";
        alamat = "";
        hargaPartisi = "Rp 0";
        jumlahAtas = "Rp 0";
        ukuranPartisi = "0";
        uangMuka = "Rp 0";
        subTotal = "Rp 0";
        pelunasan = "Rp 0";
        biayaSurvey = "Rp 0";
      });
    }
  }

  double getResponsiveFontSize(BuildContext context, {double factor = 0.05}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * factor;
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting().then((_) {
      ambilDataTerakhir();
    });
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
                    "INVOICE",
                    style: GoogleFonts.roboto(
                      fontSize: getResponsiveFontSize(context, factor: 0.065),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Image.asset(
                    "assets/images/logo_inv2.png",
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
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.8),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(2),
                  },
                  border: TableBorder.all(color: Colors.black),
                  children: [
                    _buildTableRow(["Keterangan", "Harga", "Jml (m)", "Total"],
                        isHeader: true, context: context),
                    _buildTableRow([
                      "Partisi",
                      hargaPartisi,
                      ukuranPartisi,
                      jumlahAtas
                    ], context: context),
                    _buildTableRow(["", "", "", ""], context: context),
                    _buildTableRow(["", "", "", ""], context: context),
                    _buildTableRow(["", "", "", ""], context: context),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pembayaran : ${isTablet ? "Partisi" : "Partisi"}",
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
                    Text(
                      "Biaya Survey : $uangMuka",
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
                      "Pelunasan : $pelunasan",
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
      children: cells.asMap().entries.map((entry) {
        int index = entry.key;
        String text = entry.value;

        return Container(
          padding: const EdgeInsets.all(8.0),
          alignment: index == 2 ? Alignment.center : Alignment.centerLeft,
          child: Text(
            text,
            style: TextStyle(
              fontSize: getResponsiveFontSize(context, factor: 0.0355),
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: index == 2 ? TextAlign.center : TextAlign.left,
          ),
        );
      }).toList(),
    );
  }
}
