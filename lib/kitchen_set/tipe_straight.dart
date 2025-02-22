import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ganesha_interior/Invoice/INV_tipe_straight.dart';
import 'package:ganesha_interior/kitchen_set/tipe_L.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Tipe_Straight extends StatefulWidget {
  const Tipe_Straight({super.key});

  @override
  State<Tipe_Straight> createState() => _Tipe_StraightState();
}

class _Tipe_StraightState extends State<Tipe_Straight> {
  TextEditingController hargaAtasController =
      TextEditingController(text: "Rp ");
  TextEditingController hargaBawahController =
      TextEditingController(text: "Rp ");
  TextEditingController hasilJumlahAtasController =
      TextEditingController(text: "Rp ");
  TextEditingController hasilJumlahBawahController =
      TextEditingController(text: "Rp ");
  TextEditingController topTableController = TextEditingController(text: "Rp ");
  TextEditingController backsplashController =
      TextEditingController(text: "Rp ");
  TextEditingController aksesorisController =
      TextEditingController(text: "Rp ");
  TextEditingController uangMukaController = TextEditingController(text: "Rp ");
  TextEditingController jumlahController = TextEditingController();
  TextEditingController jumlahBawahController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController alamatController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NumberFormat _formatter = NumberFormat("#,###", "id_ID");

  StreamSubscription? _hargaKitchenSetAtasSubscription;
  StreamSubscription? _hargaKitchenSetBawahSubscription;

  void _setupControllerListener(TextEditingController controller) {
    controller.addListener(() {
      String text = controller.text.replaceAll(RegExp(r'[^0-9]'), '');

      if (text.isNotEmpty) {
        int parsedValue = int.tryParse(text) ?? 0;
        String formattedText = "Rp ${_formatter.format(parsedValue)}";

        if (controller.text != formattedText) {
          controller.value = TextEditingValue(
            text: formattedText,
            selection: TextSelection.collapsed(offset: formattedText.length),
          );
        }
      }
    });
  }

  void listenToHargaKitchenSet(String docId, TextEditingController controller) {
    StreamSubscription? subscription = _firestore
        .collection("harga_kitchen_set")
        .doc(docId)
        .snapshots()
        .listen((DocumentSnapshot doc) {
      if (doc.exists && doc.data() != null) {
        var hargaRaw = doc["harga"].toString();
        print("🔥 Harga dari Firestore ($docId): $hargaRaw");

        int harga =
            int.tryParse(hargaRaw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        print("✅ Harga setelah parsing ($docId): $harga");

        String hargaFormatted = "Rp ${_formatter.format(harga)}";

        if (controller.text != hargaFormatted) {
          controller.value = TextEditingValue(
            text: hargaFormatted,
            selection: TextSelection.collapsed(offset: hargaFormatted.length),
          );
        }
        print("📌 Controller $docId terupdate: ${controller.text}");
      } else {
        controller.value = const TextEditingValue(text: "Data Tidak Ada");
      }
    }, onError: (e) {
      controller.value = TextEditingValue(text: "Error: $e");
    });

    if (docId == "Kitchen Set Atas") {
      _hargaKitchenSetAtasSubscription = subscription;
    } else if (docId == "Kitchen Set Bawah") {
      _hargaKitchenSetBawahSubscription = subscription;
    }
  }

  void _updateHasilJumlah({required bool isAtas}) {
    String jumlahText =
        (isAtas ? jumlahController : jumlahBawahController).text;
    String hargaText =
        (isAtas ? hargaAtasController : hargaBawahController).text;

    jumlahText = jumlahText.replaceAll(',', '.');

    jumlahText = jumlahText.replaceAll(RegExp(r'[^0-9.]'), '');
    hargaText = hargaText.replaceAll(RegExp(r'[^0-9]'), '');

    double jumlah = double.tryParse(jumlahText) ?? 0;
    int harga = int.tryParse(hargaText) ?? 0;
    double hasil = jumlah * harga;

    String hasilFormatted =
        "Rp ${NumberFormat("#,###.##", "id_ID").format(hasil)}";

    setState(() {
      if (isAtas) {
        hasilJumlahAtasController.text = hasilFormatted;
      } else {
        hasilJumlahBawahController.text = hasilFormatted;
      }
    });

    updateUangMuka();
  }

  void updateUangMuka() {
    double parseValue(String text) {
      return double.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }

    double hasilAtas = parseValue(hasilJumlahAtasController.text);
    double hasilBawah = parseValue(hasilJumlahBawahController.text);
    double topTable = parseValue(topTableController.text);
    double backsplash = parseValue(backsplashController.text);
    double aksesoris = parseValue(aksesorisController.text);

    double total = hasilAtas + hasilBawah + topTable + backsplash + aksesoris;
    double uangMuka = total * 0.6;

    setState(() {
      uangMukaController.text = "Rp ${_formatter.format(uangMuka)}";
    });
  }

  void simpanDataKeFirestore() async {
  if (namaController.text.isEmpty ||
      alamatController.text.isEmpty ||
      hargaAtasController.text.isEmpty ||
      hargaBawahController.text.isEmpty ||
      jumlahController.text.isEmpty ||  
      jumlahBawahController.text.isEmpty || 
      hasilJumlahAtasController.text.isEmpty ||
      hasilJumlahBawahController.text.isEmpty ||
      topTableController.text.isEmpty ||
      backsplashController.text.isEmpty ||
      aksesorisController.text.isEmpty ||
      uangMukaController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Harap isi semua kolom sebelum menyimpan."),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Fungsi untuk parsing nilai angka dari teks dengan format "Rp 10.000.000"
  double parseValue(String text) {
    return double.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  // Hitung Sub Total
  double subTotal = parseValue(hasilJumlahAtasController.text) +
                    parseValue(hasilJumlahBawahController.text) +
                    parseValue(topTableController.text) +
                    parseValue(backsplashController.text) +
                    parseValue(aksesorisController.text);

  Map<String, dynamic> data = {
    "nama": namaController.text,
    "alamat": alamatController.text,
    "jumlahAtas": jumlahController.text, 
    "jumlahBawah": jumlahBawahController.text, 
    "hasilJumlahAtas": hasilJumlahAtasController.text,
    "hasilJumlahBawah": hasilJumlahBawahController.text,
    "topTable": topTableController.text,
    "backsplash": backsplashController.text,
    "aksesoris": aksesorisController.text,
    "uangMuka": uangMukaController.text,
    "subTotal": "Rp ${_formatter.format(subTotal)}", // Simpan subTotal
    "tanggal": Timestamp.now(),
  };

  try {
    await FirebaseFirestore.instance.collection("pesanan").add(data);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Data berhasil disimpan!"),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Gagal menyimpan data: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  void dispose() {
    _hargaKitchenSetAtasSubscription?.cancel();
    _hargaKitchenSetBawahSubscription?.cancel();
    hasilJumlahAtasController.removeListener(updateUangMuka);
    hasilJumlahBawahController.removeListener(updateUangMuka);
    topTableController.removeListener(updateUangMuka);
    backsplashController.removeListener(updateUangMuka);
    aksesorisController.removeListener(updateUangMuka);

    hargaAtasController.dispose();
    hargaBawahController.dispose();
    hasilJumlahAtasController.dispose();
    hasilJumlahBawahController.dispose();
    topTableController.dispose();
    backsplashController.dispose();
    aksesorisController.dispose();
    uangMukaController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _setupControllerListener(hargaAtasController);
    _setupControllerListener(hargaBawahController);
    _setupControllerListener(topTableController);
    _setupControllerListener(backsplashController);
    _setupControllerListener(aksesorisController);
    _setupControllerListener(uangMukaController);

    listenToHargaKitchenSet("Kitchen Set Atas", hargaAtasController);
    listenToHargaKitchenSet("Kitchen Set Bawah", hargaBawahController);
  }

  void formatInput(TextEditingController controller, String value) {
    if (!value.startsWith("Rp ")) {
      controller.value = TextEditingValue(
        text: "Rp ${value.replaceAll(RegExp(r'[^0-9]'), '')}",
        selection: TextSelection.collapsed(offset: controller.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            color: const Color(0xFFD9D9D9),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.07,
              width: screenWidth,
              color: const Color(0xFFFF5252),
            ),
          ),
          Positioned(
            top: screenHeight * 0.034,
            left: screenWidth * 0.01,
            right: screenWidth * 0.01,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                height: screenHeight * 0.055,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Image.asset(
                            "assets/images/back.png",
                            height: screenHeight * 0.03,
                            width: screenHeight * 0.03,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Kitchen Set",
                          style: TextStyle(
                            color: Color(0xFFFF5252),
                            fontSize: MediaQuery.of(context).size.width < 600
                                ? MediaQuery.of(context).size.width * 0.045
                                : MediaQuery.of(context).size.width * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Image.asset(
                      "assets/images/keranjang_merah.png",
                      height: screenHeight * 0.035,
                      width: screenHeight * 0.035,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: screenHeight * 0.097,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - screenHeight * 0.097,
                  ),
                  child: IntrinsicHeight(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                "assets/images/Background.jpg",
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      "Tipe Straight",
                                      style: GoogleFonts.manrope(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    600
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.045,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFFF5252),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.005),
                                    child: Text(
                                      "Nama Klien",
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w900,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.035,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  TextField(
                                    controller: namaController,
                                    style: GoogleFonts.manrope(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              600
                                          ? MediaQuery.of(context).size.width *
                                              0.04
                                          : MediaQuery.of(context).size.width *
                                              0.035,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Masukkan nama",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.005),
                                    child: Text(
                                      "Alamat",
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w900,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.035,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  TextField(
                                    maxLines: 3,
                                    controller: alamatController,
                                    style: GoogleFonts.manrope(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              600
                                          ? MediaQuery.of(context).size.width *
                                              0.04
                                          : MediaQuery.of(context).size.width *
                                              0.035,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Masukkan alamat lengkap",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex:
                                            MediaQuery.of(context).size.width >
                                                    600
                                                ? 2
                                                : 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.005),
                                              child: Text(
                                                MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        600
                                                    ? "Kitchen Set Atas"
                                                    : "Atas",
                                                style: GoogleFonts.lato(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.032,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            TextField(
                                              controller: jumlahController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width >
                                                                600
                                                            ? 22
                                                            : 12,
                                                        horizontal: 12),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              onChanged: (value) {
                                                _updateHasilJumlah(
                                                    isAtas: true);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      600
                                                  ? 40
                                                  : 20),
                                          Text("X",
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.04,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Harga",
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.w900,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.032,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            TextField(
                                              controller: hargaAtasController,
                                              readOnly: true,
                                              style: GoogleFonts.manrope(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 12),
                                                filled: true,
                                                fillColor: Colors.grey[200],
                                              ),
                                              keyboardType: TextInputType.none,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Hasil Jumlah",
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.w900,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.032,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            TextField(
                                              controller:
                                                  hasilJumlahAtasController,
                                              readOnly: true,
                                              style: GoogleFonts.manrope(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 12),
                                                filled: true,
                                                fillColor: Colors.grey[200],
                                              ),
                                              keyboardType: TextInputType.none,
                                              onChanged: (value) =>
                                                  updateUangMuka(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex:
                                            MediaQuery.of(context).size.width >
                                                    600
                                                ? 2
                                                : 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.005),
                                              child: Text(
                                                MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        600
                                                    ? "Kitchen Set Bawah"
                                                    : "Bawah",
                                                style: GoogleFonts.lato(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.032,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            TextField(
                                              controller: jumlahBawahController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width >
                                                                600
                                                            ? 22
                                                            : 12,
                                                        horizontal: 12),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              onChanged: (value) {
                                                _updateHasilJumlah(
                                                    isAtas: false);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      600
                                                  ? 40
                                                  : 20),
                                          Text("X",
                                              style: TextStyle(
                                                  fontSize: screenWidth * 0.04,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Harga",
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.w900,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.032,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            TextField(
                                              controller: hargaBawahController,
                                              readOnly: true,
                                              style: GoogleFonts.manrope(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 12),
                                                filled: true,
                                                fillColor: Colors.grey[200],
                                              ),
                                              keyboardType: TextInputType.none,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Hasil Jumlah",
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.w900,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.032,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            TextField(
                                              controller:
                                                  hasilJumlahBawahController,
                                              readOnly: true,
                                              style: GoogleFonts.manrope(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 12),
                                                filled: true,
                                                fillColor: Colors.grey[200],
                                              ),
                                              keyboardType: TextInputType.none,
                                              onChanged: (value) =>
                                                  updateUangMuka(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.005),
                                    child: Text(
                                      "Top Table",
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w900,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.035,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  TextField(
                                    controller: topTableController,
                                    style: GoogleFonts.manrope(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 12),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      formatInput(topTableController, value);
                                      updateUangMuka();
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.005),
                                    child: Text(
                                      "Backsplash",
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w900,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.035,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  TextField(
                                    controller: backsplashController,
                                    style: GoogleFonts.manrope(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 12),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      formatInput(backsplashController, value);
                                      updateUangMuka();
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.005),
                                    child: Text(
                                      "Aksesoris",
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w900,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.035,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  TextField(
                                    controller: aksesorisController,
                                    style: GoogleFonts.manrope(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 12),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      formatInput(aksesorisController, value);
                                      updateUangMuka();
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.005),
                                    child: Text(
                                      "Uang Muka",
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w900,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.035,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  TextField(
                                    controller: uangMukaController,
                                    readOnly: true,
                                    style: GoogleFonts.manrope(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 12),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                    ),
                                    keyboardType: TextInputType.none,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Tipe_L()),
                                  );
                                },
                                child: Image.asset(
                                  "assets/images/back_rotasi.png",
                                  width: 30,
                                  height: 30,
                                ),
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
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/keranjang_putih.png",
                      height: MediaQuery.of(context).size.height *
                          (MediaQuery.of(context).size.width > 600
                              ? 0.04
                              : 0.03),
                      width: MediaQuery.of(context).size.height * 0.035,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 1),
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {
                  simpanDataKeFirestore();

                  if (namaController.text.isNotEmpty &&
                      alamatController.text.isNotEmpty &&
                      hargaAtasController.text.isNotEmpty &&
                      hargaBawahController.text.isNotEmpty &&
                      hasilJumlahAtasController.text.isNotEmpty &&
                      hasilJumlahBawahController.text.isNotEmpty &&
                      topTableController.text.isNotEmpty &&
                      backsplashController.text.isNotEmpty &&
                      aksesorisController.text.isNotEmpty &&
                      uangMukaController.text.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const INV_TipeStraight(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text(
                  'Hitung',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  dynamic get bottomNavigationBar => bottomNavigationBar;
}
