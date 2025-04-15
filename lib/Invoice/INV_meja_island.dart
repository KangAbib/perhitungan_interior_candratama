import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:ui';

class INV_MejaIsland extends StatefulWidget {
  const INV_MejaIsland({super.key});

  @override
  State<INV_MejaIsland> createState() => _INV_MejaIsland();
}

class _INV_MejaIsland extends State<INV_MejaIsland> {
  ScreenshotController screenshotController = ScreenshotController();
  String nama = "Memuat...";
  String alamat = "";
  String hargaMejaIsland = "";
  String jumlahAtas = "";
  String ukuranMejaIsland = "";
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
          .collection("pesanan meja island")
          .orderBy("tanggal", descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var data = snapshot.docs.first.data();

        double jumlahAtasValue = parseCurrency(data["jumlahAtas"] ?? "Rp 0");

        setState(() {
          nama = data["nama"] ?? "Nama tidak ditemukan";
          alamat = data["alamat"] ?? "Alamat tidak ditemukan";
          hargaMejaIsland = data["hargaMejaisland"] ?? "Rp 0";
          jumlahAtas = data["jumlahAtas"] ?? "Rp 0";
          ukuranMejaIsland = data["ukuranMejaisland"] ?? "0";
          biayaSurvey = data["biayaSurvey"] ?? "0";
          uangMuka = data["uangMuka"] ?? "Rp 0";
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
          hargaMejaIsland = "Rp 0";
          jumlahAtas = "Rp 0";
          ukuranMejaIsland = "0";
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
        hargaMejaIsland = "Rp 0";
        jumlahAtas = "Rp 0";
        ukuranMejaIsland = "0";
        uangMuka = "Rp 0";
        subTotal = "Rp 0";
        pelunasan = "Rp 0";
        biayaSurvey = "Rp 0";
      });
    }
  }
  Future<void> captureAndGeneratePDF() async {
  try {
    final image = await screenshotController.capture(delay: Duration(milliseconds: 300));
    if (image == null) return;

    final pdf = pw.Document();
    final imageProvider = pw.MemoryImage(image);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Image(imageProvider)),
              pw.SizedBox(height: 20),
              pw.Text(
                'Pembayaran dapat dilakukan melalui rekening:',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              pw.Text(' BCA        a.n. Candra Puput Hapsari, Rek: 0331797811'),
              pw.Text(' Mandiri   a.n. Candra Puput Hapsari, Rek: 9000033904781'),
              pw.Text(' BRI         a.n. Candra Puput Hapsari, Rek: 050801000243567'),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'invoice_meja island.pdf',
    );
  } catch (e) {
    print("Error saat membuat PDF: $e");
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
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              print("Tombol PDF ditekan");

              await Future.delayed(
                  Duration(milliseconds: 500)); // Tambahan delay
              captureAndGeneratePDF();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            // tanpa RepaintBoundary
            child: Padding(
              padding: const EdgeInsets.all(16.0),
               child: SingleChildScrollView(
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
                      "Meja Island",
                      hargaMejaIsland,
                      ukuranMejaIsland,
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
                    "Pembayaran : ${isTablet ? "Meja Island" : "Meja Island"}",
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
                      "Biaya Survey : $biayaSurvey",
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
