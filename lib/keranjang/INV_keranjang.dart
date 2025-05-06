import 'package:flutter/material.dart';
import 'package:ganesha_interior/keranjang/daftar_bayar_keranjang.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:ui';

class INV_Keranjang extends StatefulWidget {
  const INV_Keranjang({super.key});

  @override
  State<INV_Keranjang> createState() => _INV_Keranjang();
}

class _INV_Keranjang extends State<INV_Keranjang> {
  ScreenshotController screenshotController = ScreenshotController();
  String nama = "Memuat...";
  String alamat = "";
  double subTotal = 0;
  double diskon = 0;
  double uangMuka = 0;
  double pelunasan = 0;
  String biayaSurvey = "";
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
          biayaSurvey = data["biayaSurvey"] ?? "Rp 0";
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

  Future<void> captureAndGeneratePDF() async {
    try {
      final image = await screenshotController.capture(
          delay: Duration(milliseconds: 300));
      if (image == null) return;

      final pdf = pw.Document();
      final imageProvider = pw.MemoryImage(image);

      // Ukuran kertas sedikit lebih tinggi dari A4
      final customPageFormat = PdfPageFormat.a4.copyWith(
        height: PdfPageFormat.a4.height * 1.1,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: customPageFormat,
          margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(child: pw.Image(imageProvider)),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Pembayaran dapat dilakukan melalui rekening:',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
              pw.Text(' BCA       a.n. Candra Puput Hapsari, Rek: 0331797811',style: pw.TextStyle(fontSize: 13)),
              pw.Text(' Mandiri   a.n. Candra Puput Hapsari, Rek: 9000033904781',style: pw.TextStyle(fontSize: 13)),
              pw.Text(' BRI         a.n. Candra Puput Hapsari, Rek: 050801000243567',style: pw.TextStyle(fontSize: 13)),
              ],
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Inv_$nama.pdf',
      );
    } catch (e) {
      print("Error saat membuat PDF: $e");
    }
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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Daftar_KeranjangScreen()),
        );
        return false;
      },
      child: Scaffold(
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
                              fontSize:
                                  getResponsiveFontSize(context, factor: 0.065),
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
                                    fontSize: getResponsiveFontSize(context,
                                        factor: 0.0355),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  nama,
                                  style: TextStyle(
                                    fontSize: getResponsiveFontSize(context,
                                        factor: 0.03),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  alamat,
                                  style: TextStyle(
                                    fontSize: getResponsiveFontSize(context,
                                        factor: 0.03),
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
                                  fontSize: getResponsiveFontSize(context,
                                      factor: 0.0355),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                todayDate,
                                style: TextStyle(
                                  fontSize: getResponsiveFontSize(context,
                                      factor: 0.03),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Table(
                              columnWidths: const {
                                0: FlexColumnWidth(4),
                                1: FlexColumnWidth(2),
                              },
                              border: TableBorder.all(color: Colors.black),
                              children: [
                                _buildTableRow(["Kategori", "Harga"],
                                    isHeader: true, context: context),
                                ...List<TableRow>.from(
                                  (listKeranjang
                                          .where((item) =>
                                              item["timestamp"] != null)
                                          .toList()
                                        ..sort((a, b) => b["timestamp"]
                                            .compareTo(a["timestamp"])))
                                      .map((item) => _buildTableRow([
                                            item["nama"]?.toString() ?? "-",
                                            formatRupiah((item["harga"] ?? 0)
                                                .toDouble()),
                                          ], context: context)),
                                ),
                              ],
                            ),
                            const SizedBox(
                                height:
                                    16), // Spasi antara tabel dan pembayaran
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Pembayaran : ",
                                  style: TextStyle(
                                    fontSize: getResponsiveFontSize(context,
                                        factor: 0.0355),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Text(
                                    "Sub Total : ${formatRupiah(subTotal)}",
                                    style: TextStyle(
                                      fontSize: getResponsiveFontSize(context,
                                          factor: 0.03),
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
                                      fontSize: getResponsiveFontSize(context,
                                          factor: 0.03),
                                    ),
                                  ),
                                  Text(
                                    "Uang Muka : ${formatRupiah(uangMuka)}",
                                    style: TextStyle(
                                      fontSize: getResponsiveFontSize(context,
                                          factor: 0.03),
                                    ),
                                  ),
                                  Text(
                                    "Biaya Survei : $biayaSurvey",
                                    style: TextStyle(
                                      fontSize: getResponsiveFontSize(context,
                                          factor: 0.03),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          thickness: 2,
                                          color: Colors.black,
                                          indent: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          endIndent: 5,
                                        ),
                                      ),
                                      Text(
                                        "-",
                                        style: TextStyle(
                                          fontSize: getResponsiveFontSize(
                                              context,
                                              factor: 0.04),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "Pelunasan : ${formatRupiah(pelunasan)}",
                                    style: TextStyle(
                                      fontSize: getResponsiveFontSize(context,
                                          factor: 0.03),
                                    ),
                                  ),
                                ],
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
