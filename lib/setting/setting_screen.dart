import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _kitchenSetAtasController =
      TextEditingController();
  final TextEditingController _kitchenSetBawahController =
      TextEditingController();
  final TextEditingController _kitchenSetLController = TextEditingController();
  final TextEditingController _kitchenSetUController = TextEditingController();
  final TextEditingController _kitchenSetULController = TextEditingController();
  final TextEditingController _kitchenSetUUController = TextEditingController();
  final TextEditingController _kitchenSetAtasOutputController =
      TextEditingController();
  final TextEditingController _kitchenSetBawahOutputController =
      TextEditingController();
  final TextEditingController _kitchenLetterLAtasController =
      TextEditingController();
  final TextEditingController _kitchenLetterLBawahController =
      TextEditingController();
  final TextEditingController _kitchenLetterUAtasController =
      TextEditingController();
  final TextEditingController _kitchenLetterUBawahController =
      TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NumberFormat _formatter = NumberFormat("#,###", "id_ID");
  final ScrollController _scrollController = ScrollController();

  StreamSubscription? _hargaKitchenSetSubscription;
  StreamSubscription? _hargaKitchenSetAtasSubscription;
  StreamSubscription? _hargaKitchenSetBawahSubscription;
  StreamSubscription? _ukuranKitchenSetLSubscription;
  StreamSubscription? _ukuranKitchenSetUSubscription;

  void _setupControllerListener(TextEditingController controller) {
    controller.addListener(() {
      final text = controller.text.replaceAll('.', '');
      if (text.isNotEmpty) {
        final formattedText = _formatter.format(int.parse(text));
        controller.value = TextEditingValue(
          text: formattedText,
          selection: TextSelection.collapsed(offset: formattedText.length),
        );
      }
    });
  }

  Future<void> _saveData(String jenis, String harga) async {
    if (harga.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi harga sebelum menyimpan")),
      );
      return;
    }

    String rawValue = harga.replaceAll('.', '');

    try {
      await _firestore.collection("harga_kitchen_set").doc(jenis).set({
        "jenis": jenis,
        "harga": rawValue,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "$jenis berhasil disimpan",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 600
                  ? 14
                  : 20, // Perbesar teks jika di tablet
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      _kitchenSetAtasController.clear();
      _kitchenSetBawahController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Gagal menyimpan: $e",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width < 600
                  ? 14
                  : 20, // Perbesar teks jika di tablet
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 600
                ? 14
                : 18, // Ukuran teks sesuai layar
            fontWeight: FontWeight.bold,
          ),
        ),
        behavior: SnackBarBehavior.floating, // Membuat SnackBar lebih menonjol
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
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

        int harga = int.tryParse(hargaRaw.replaceAll(',', '')) ?? 0;
        print("✅ Harga setelah parsing ($docId): $harga");

        String hargaFormatted = _formatter.format(harga);

        controller.value = TextEditingValue(
          text: hargaFormatted,
          selection: TextSelection.collapsed(offset: hargaFormatted.length),
        );
        print("📌 Controller $docId terupdate: ${controller.text}");
      } else {
        controller.value = TextEditingValue(text: "Data Tidak Ada");
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

  void _saveUkuranKitchenSet(String jenis, String atas, String bawah) async {
    if (atas.isEmpty || bawah.isEmpty) {
      _showSnackBar("Harap isi ukuran sebelum menyimpan");
      return;
    }

    String atasFormatted = atas.replaceAll(',', '.');
    String bawahFormatted = bawah.replaceAll(',', '.');

    double rawAtas = double.tryParse(atasFormatted) ?? 0.0;
    double rawBawah = double.tryParse(bawahFormatted) ?? 0.0;

    try {
      await FirebaseFirestore.instance
          .collection("ukuran_kitchen_set")
          .doc(jenis)
          .set({
        "jenis": jenis,
        "set_atas": rawAtas,
        "set_bawah": rawBawah,
      });

      _showSnackBar("$jenis berhasil disimpan");

      _kitchenSetLController.clear();
      _kitchenSetUController.clear();
      _kitchenSetULController.clear();
      _kitchenSetUUController.clear();
    } catch (e) {
      _showSnackBar("Gagal menyimpan: $e");
    }
  }

  void listenToUkuranKitchenSet(
      String docId,
      TextEditingController atasController,
      TextEditingController bawahController) {
    StreamSubscription? subscription = _firestore
        .collection("ukuran_kitchen_set")
        .doc(docId)
        .snapshots()
        .listen((DocumentSnapshot doc) {
      if (doc.exists && doc.data() != null) {
        var setAtasRaw = doc["set_atas"].toString();
        var setBawahRaw = doc["set_bawah"].toString();
        print(
            "🔥 Data dari Firestore ($docId): Atas: $setAtasRaw, Bawah: $setBawahRaw");

        double setAtas = double.tryParse(setAtasRaw) ?? 0.0;
        double setBawah = double.tryParse(setBawahRaw) ?? 0.0;
        print(
            "✅ Data setelah parsing ($docId): Atas: $setAtas, Bawah: $setBawah");

        atasController.text = setAtas.toString();
        bawahController.text = setBawah.toString();

        print(
            "📌 Controller $docId terupdate: Atas: ${atasController.text}, Bawah: ${bawahController.text}");
      } else {
        atasController.text = "Data Tidak Ada";
        bawahController.text = "Data Tidak Ada";
      }
    }, onError: (e) {
      atasController.text = "Error: $e";
      bawahController.text = "Error: $e";
    });

    if (docId == "Letter L") {
      _ukuranKitchenSetLSubscription = subscription;
    } else if (docId == "Letter U") {
      _ukuranKitchenSetUSubscription = subscription;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setupControllerListener(_kitchenSetAtasController);
    _setupControllerListener(_kitchenSetBawahController);
    listenToHargaKitchenSet(
        "Kitchen Set Atas", _kitchenSetAtasOutputController);
    listenToHargaKitchenSet(
        "Kitchen Set Bawah", _kitchenSetBawahOutputController);
    listenToUkuranKitchenSet("Letter L", _kitchenLetterLAtasController,
        _kitchenLetterLBawahController);

    listenToUkuranKitchenSet("Letter U", _kitchenLetterUAtasController,
        _kitchenLetterUBawahController);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            color: const Color(0xFFD9D9D9),
          ),
          Container(
            height: screenHeight * 0.07,
            width: screenWidth,
            color: const Color(0xFFFF5252),
          ),
          Positioned(
            top: screenHeight * 0.035,
            left: screenWidth * 0.02,
            right: screenWidth * 0.03,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                height: screenHeight * 0.05,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
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
                      "Setting",
                      style: TextStyle(
                        color: Color(0xFFFF5252),
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.10,
            left: screenWidth * 0.02,
            right: screenWidth * 0.03,
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Daftar Harga",
                            style: GoogleFonts.manrope(
                              color: Color(0xFFFF5252),
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Kitchen set atas",
                          style: GoogleFonts.manrope(
                            fontSize: MediaQuery.of(context).size.width < 600
                                ? MediaQuery.of(context).size.width * 0.04
                                : MediaQuery.of(context).size.width * 0.03,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _kitchenSetAtasController,
                                style: GoogleFonts.manrope(
                                  fontSize: MediaQuery.of(context).size.width <
                                          600
                                      ? MediaQuery.of(context).size.width * 0.04
                                      : MediaQuery.of(context).size.width *
                                          0.035,
                                  fontWeight: FontWeight.w400,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF6666),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                _saveData("Kitchen Set Atas",
                                    _kitchenSetAtasController.text);
                                _kitchenSetAtasController.clear();
                              },
                              child: Text(
                                "Simpan",
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 600
                                          ? MediaQuery.of(context).size.width *
                                              0.045
                                          : MediaQuery.of(context).size.width *
                                              0.03,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Kitchen set bawah",
                          style: GoogleFonts.manrope(
                            fontSize: MediaQuery.of(context).size.width < 600
                                ? MediaQuery.of(context).size.width * 0.04
                                : MediaQuery.of(context).size.width * 0.03,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _kitchenSetBawahController,
                                style: GoogleFonts.manrope(
                                  fontSize: MediaQuery.of(context).size.width <
                                          600
                                      ? MediaQuery.of(context).size.width * 0.04
                                      : MediaQuery.of(context).size.width *
                                          0.035,
                                  fontWeight: FontWeight.w400,
                                ),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF6666),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                _saveData("Kitchen Set Bawah",
                                    _kitchenSetBawahController.text);
                              },
                              child: Text(
                                "Simpan",
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 600
                                          ? MediaQuery.of(context).size.width *
                                              0.045
                                          : MediaQuery.of(context).size.width *
                                              0.03,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.02,
                      vertical: 8.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Daftar Ukuran Kitchen",
                              style: GoogleFonts.manrope(
                                color: Color(0xFFFF5252),
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Letter L",
                            style: GoogleFonts.manrope(
                              fontSize: MediaQuery.of(context).size.width < 600
                                  ? MediaQuery.of(context).size.width * 0.04
                                  : MediaQuery.of(context).size.width * 0.03,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                flex: MediaQuery.of(context).size.width < 600
                                    ? 1
                                    : 2,
                                child: TextFormField(
                                  controller: _kitchenSetLController,
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
                                    labelText: "Set Atas",
                                    labelStyle: GoogleFonts.manrope(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              600
                                          ? 14
                                          : 20, // Label lebih besar di tablet
                                      fontWeight: FontWeight
                                          .bold, // Tambahkan bold agar lebih jelas
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+([.,]\d*)?$')),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: MediaQuery.of(context).size.width < 600
                                    ? 1
                                    : 2,
                                child: TextFormField(
                                  controller: _kitchenSetUController,
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
                                    labelText: "Set Bawah",
                                    labelStyle: GoogleFonts.manrope(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              600
                                          ? 14
                                          : 20, // Label lebih besar di tablet
                                      fontWeight: FontWeight
                                          .bold, // Tambahkan bold agar lebih jelas
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+([.,]\d*)?$')),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6666),
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width < 600
                                            ? 16
                                            : 24,
                                    vertical:
                                        MediaQuery.of(context).size.width < 600
                                            ? 14
                                            : 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  _saveUkuranKitchenSet(
                                    "Letter L",
                                    _kitchenSetLController.text
                                        .replaceAll(',', '.'),
                                    _kitchenSetUController.text
                                        .replaceAll(',', '.'),
                                  );
                                },
                                child: Text(
                                  "Simpan",
                                  style: GoogleFonts.manrope(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context)
                                                .size
                                                .width <
                                            600
                                        ? MediaQuery.of(context).size.width *
                                            0.045
                                        : MediaQuery.of(context).size.width *
                                            0.03,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Letter U",
                            style: GoogleFonts.manrope(
                              fontSize: MediaQuery.of(context).size.width < 600
                                  ? MediaQuery.of(context).size.width * 0.04
                                  : MediaQuery.of(context).size.width * 0.03,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _kitchenSetULController,
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
                                    labelText: "Set Atas",
                                    labelStyle: GoogleFonts.manrope(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              600
                                          ? 14
                                          : 20, // Label lebih besar di tablet
                                      fontWeight: FontWeight
                                          .bold, // Tambahkan bold agar lebih jelas
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+([.,]\d*)?$')),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _kitchenSetUUController,
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
                                    labelText: "Set Bawah",
                                    labelStyle: GoogleFonts.manrope(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              600
                                          ? 14
                                          : 20, // Label lebih besar di tablet
                                      fontWeight: FontWeight
                                          .bold, // Tambahkan bold agar lebih jelas
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+([.,]\d*)?$')),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6666),
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width < 600
                                            ? 16
                                            : 24,
                                    vertical:
                                        MediaQuery.of(context).size.width < 600
                                            ? 14
                                            : 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  _saveUkuranKitchenSet(
                                    "Letter U",
                                    _kitchenSetULController.text,
                                    _kitchenSetUUController.text,
                                  );
                                },
                                child: Text(
                                  "Simpan",
                                  style: GoogleFonts.manrope(
                                    color: Colors.white,
                                    fontSize: MediaQuery.of(context)
                                                .size
                                                .width <
                                            600
                                        ? MediaQuery.of(context).size.width *
                                            0.045
                                        : MediaQuery.of(context).size.width *
                                            0.03,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.3, // 🔥 Pastikan tidak full height
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min, // 🔥 Card menyesuaikan kontennya
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "List Data",
                              style: GoogleFonts.manrope(
                                color: Color(0xFFFF5252),
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            // 🔥 Agar ListView bisa scroll tanpa mempengaruhi ukuran Card
                            child: Scrollbar(
                              controller: _scrollController,
                              child: ListView(
                                controller: _scrollController,
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "1. Kitchen Set Atas",
                                          style: GoogleFonts.manrope(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    600
                                                ? 14
                                                : 25,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  600
                                              ? 40
                                              : 55,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF6666),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ValueListenableBuilder<
                                              TextEditingValue>(
                                            valueListenable:
                                                _kitchenSetAtasOutputController,
                                            builder: (context, value, child) {
                                              String formattedText =
                                                  "Memuat...";

                                              if (value.text.isNotEmpty) {
                                                int? parsedValue = int.tryParse(
                                                  value.text
                                                      .replaceAll('.', '')
                                                      .replaceAll(',', ''),
                                                );

                                                if (parsedValue != null) {
                                                  formattedText = NumberFormat
                                                          .decimalPattern('id')
                                                      .format(parsedValue);
                                                }
                                              }

                                              return Center(
                                                child: Text(
                                                  formattedText,
                                                  style: GoogleFonts.manrope(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                600
                                                            ? 14
                                                            : 24,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "2. Kitchen Set Bawah",
                                          style: GoogleFonts.manrope(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    600
                                                ? 14
                                                : 25,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  600
                                              ? 40
                                              : 55,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF6666),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ValueListenableBuilder<
                                              TextEditingValue>(
                                            valueListenable:
                                                _kitchenSetBawahOutputController,
                                            builder: (context, value, child) {
                                              String formattedText =
                                                  "Memuat...";

                                              if (value.text.isNotEmpty &&
                                                  value.text != "Memuat...") {
                                                int? parsedValue = int.tryParse(
                                                  value.text
                                                      .replaceAll('.', '')
                                                      .replaceAll(',', ''),
                                                );

                                                if (parsedValue != null) {
                                                  formattedText = NumberFormat
                                                          .decimalPattern('id')
                                                      .format(parsedValue);
                                                } else {
                                                  formattedText = value.text;
                                                }
                                              }

                                              return Center(
                                                child: Text(
                                                  formattedText,
                                                  style: GoogleFonts.manrope(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                600
                                                            ? 14
                                                            : 24,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex:
                                            2, // Memberikan ruang untuk teks agar proporsional
                                        child: Text(
                                          "3. Kitchen Letter L",
                                          style: GoogleFonts.manrope(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    600
                                                ? 14
                                                : 25,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          width:
                                              10), // Memberikan sedikit jarak agar rapi
                                      Expanded(
                                        flex:
                                            1, // Proporsi tetap di semua layar
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  600
                                              ? 50
                                              : 55,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF6666),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: TextField(
                                              controller:
                                                  _kitchenLetterLAtasController,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.manrope(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        600
                                                    ? 12
                                                    : 22, // Perbesar font di tablet
                                                fontWeight: FontWeight
                                                    .bold, // Tambahkan bold agar lebih jelas
                                                color: Colors.white,
                                              ),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              readOnly: true,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  600
                                              ? 50
                                              : 55,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF6666),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: TextField(
                                              controller:
                                                  _kitchenLetterLBawahController,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.manrope(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        600
                                                    ? 12
                                                    : 22, // Sama seperti atas
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              readOnly: true,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "4. Kitchen Letter U",
                                          style: GoogleFonts.manrope(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    600
                                                ? 14
                                                : 25,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  600
                                              ? 50
                                              : 55,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF6666),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: TextField(
                                              controller:
                                                  _kitchenLetterUAtasController,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.manrope(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        600
                                                    ? 12
                                                    : 22, // Font lebih besar untuk tablet
                                                fontWeight: FontWeight
                                                    .bold, // Tambahkan bold untuk kejelasan
                                                color: Colors.white,
                                              ),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              readOnly: true,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  600
                                              ? 50
                                              : 55,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF6666),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: TextField(
                                              controller:
                                                  _kitchenLetterUBawahController,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.manrope(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        600
                                                    ? 12
                                                    : 22, // Ukuran font lebih besar di tablet
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              readOnly: true,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
