import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ganesha_interior/Invoice/INV_tipe_L.dart';
import 'package:ganesha_interior/keranjang/list_keranjang.dart';
import 'package:ganesha_interior/kitchen_set/tipe_U.dart';
import 'package:ganesha_interior/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Tipe_L extends StatefulWidget {
  const Tipe_L({super.key});

  @override
  State<Tipe_L> createState() => _Tipe_LState();
}

class _Tipe_LState extends State<Tipe_L> {
  TextEditingController hargaAtasController =
      TextEditingController(text: "Rp ");
  TextEditingController hargaBawahController =
      TextEditingController(text: "Rp ");
  TextEditingController hasilJumlahAtasController =
      TextEditingController(text: "Rp ");
  TextEditingController hasilJumlahBawahController =
      TextEditingController(text: "Rp ");
  TextEditingController backsplashController =
      TextEditingController(text: "Rp ");
  TextEditingController aksesorisController =
      TextEditingController(text: "Rp ");
  TextEditingController uangMukaController = TextEditingController(text: "Rp ");
  TextEditingController jumlahAtas1Controller = TextEditingController();
  TextEditingController jumlahAtas2Controller = TextEditingController();
  TextEditingController jumlahBawah1Controller = TextEditingController();
  TextEditingController jumlahBawah2Controller = TextEditingController();
  final TextEditingController _kitchenLetterLAtasController =
      TextEditingController();
  final TextEditingController _kitchenLetterLBawahController =
      TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController alamatController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NumberFormat _formatter = NumberFormat("#,##0", "id_ID");

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

  void listenToKitchenLetterL() {
    _firestore
        .collection("ukuran_kitchen_set")
        .doc("Letter L")
        .snapshots()
        .listen((DocumentSnapshot doc) {
      if (doc.exists && doc.data() != null) {
        double setAtas = (doc["set_atas"] as num).toDouble();
        double setBawah = (doc["set_bawah"] as num).toDouble();

        setState(() {
          _kitchenLetterLAtasController.text = setAtas.toString();
          _kitchenLetterLBawahController.text = setBawah.toString();
        });

        print(
            "🔥 Data dari Firestore: set_atas = $setAtas, set_bawah = $setBawah");
      } else {
        print("⚠️ Data Letter L tidak ditemukan di Firestore!");
      }
    }, onError: (e) {
      print("❌ Error mengambil data Letter L: $e");
    });
  }

  double parseValue(String text) {
    String cleanedText = text.replaceAll(RegExp(r'[^\d,.]'), '');
    cleanedText = cleanedText.replaceAll(',', '.');

    if (cleanedText.split('.').length > 2) {
      int firstDotIndex = cleanedText.indexOf('.');
      cleanedText = cleanedText.replaceFirst('.', '');
    }

    double parsedValue = double.tryParse(cleanedText) ?? 0.0001;

    return parsedValue;
  }

  void _updateHasilJumlah({required bool isAtas}) {
    double jumlah1 = parseValue(
        isAtas ? jumlahAtas1Controller.text : jumlahBawah1Controller.text);
    double jumlah2 = parseValue(
        isAtas ? jumlahAtas2Controller.text : jumlahBawah2Controller.text);
    double kitchenSet = parseValue(isAtas
        ? _kitchenLetterLAtasController.text
        : _kitchenLetterLBawahController.text);
    double harga = parseValue(
        isAtas ? hargaAtasController.text : hargaBawahController.text);

    print(
        "🔍 jumlah1: $jumlah1, jumlah2: $jumlah2, kitchenSet: $kitchenSet, harga: $harga");

    double hasil = (jumlah1 + jumlah2 - kitchenSet) * (harga * 1000);
    if (hasil < 0) hasil = 0;
    hasil = double.parse(hasil.toStringAsFixed(2));

    if (hasil < 0.0001) {
      hasil = 0.0001;
    }

    print("✅ Hasil perhitungan: $hasil");

    String hasilFormatted = "Rp ${_formatter.format(hasil)}";

    setState(() {
      if (isAtas) {
        hasilJumlahAtasController.text = hasilFormatted;
      } else {
        hasilJumlahBawahController.text = hasilFormatted;
      }
    });

    updateUangMuka();
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

  void updateUangMuka() {
    double parseValue(String text) {
      return double.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }

    double hasilAtas = parseValue(hasilJumlahAtasController.text);
    double hasilBawah = parseValue(hasilJumlahBawahController.text);
    double backsplash = parseValue(backsplashController.text);
    double aksesoris = parseValue(aksesorisController.text);

    double total = hasilAtas + hasilBawah + backsplash + aksesoris;
    double uangMuka = total * 0.6;

    setState(() {
      uangMukaController.text = "Rp ${_formatter.format(uangMuka)}";
    });
  }

  double hitungSubTotal() {
    double parseValue(String text) {
      return double.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }

    return parseValue(hasilJumlahAtasController.text) +
        parseValue(hasilJumlahBawahController.text) +
        parseValue(backsplashController.text) +
        parseValue(aksesorisController.text);
  }

  void tambahKeKeranjang(String namaInterior, double harga) async {
    try {
      var keranjangRef = FirebaseFirestore.instance
          .collection("keranjang")
          .doc("listKeranjang");

      var docSnapshot = await keranjangRef.get();
      Map<String, dynamic>? data = docSnapshot.data() ?? {};

      int nomorBarang = 1;
      for (var key in data.keys) {
        if (key.startsWith("barang")) {
          int nomor = int.parse(key.replaceAll("barang", ""));
          if (nomor >= nomorBarang) {
            nomorBarang = nomor + 1;
          }
        }
      }

      String existingBarangKey = "";
      for (var key in data.keys) {
        if (data[key]["nama"] == namaInterior) {
          existingBarangKey = key;
          break;
        }
      }

      int timestamp = DateTime.now().millisecondsSinceEpoch;

      if (existingBarangKey.isNotEmpty) {
        await keranjangRef.update({
          "$existingBarangKey.harga": harga,
          "$existingBarangKey.timestamp": timestamp,
        });
        
        _showSnackBar("Harga $namaInterior berhasil diperbarui", Colors.blue);
        
      } else {
        String barangKey = "barang$nomorBarang";

        await keranjangRef.set({
          barangKey: {
            "nama": namaInterior,
            "harga": harga,
            "timestamp": timestamp
          }
        }, SetOptions(merge: true));

         _showSnackBar("$namaInterior ditambahkan ke keranjang", Colors.green);
      }
    } catch (e) {
      print("Error: $e");
      _showSnackBar("Gagal menambahkan ke keranjang.", Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600; // Menentukan apakah perangkat tablet

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: isTablet ? 18.0 : 12.0, // Lebih besar di tablet
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 1)
      ),
    );
  }

  void simpanDataKeFirestore(BuildContext context) async {
    if ([
      namaController.text,
      alamatController.text,
      hargaAtasController.text,
      hargaBawahController.text,
      jumlahAtas1Controller.text,
      jumlahAtas2Controller.text,
      jumlahBawah1Controller.text,
      jumlahBawah2Controller.text,
      hasilJumlahAtasController.text,
      hasilJumlahBawahController.text,
      backsplashController.text,
      aksesorisController.text,
      uangMukaController.text
    ].any((element) => element.isEmpty)) {
      _showSnackBar("Harap isi semua kolom sebelum menyimpan.", Colors.red);
      return;
    }

    try {
      double jumlahAtas = (parseValue(jumlahAtas1Controller.text) +
              parseValue(jumlahAtas2Controller.text) -
              parseValue(_kitchenLetterLAtasController.text))
          .abs();

      double jumlahBawah = (parseValue(jumlahBawah1Controller.text) +
              parseValue(jumlahBawah2Controller.text) -
              parseValue(_kitchenLetterLBawahController.text))
          .abs();

      double subTotal = (parseValue(hasilJumlahAtasController.text) +
              parseValue(hasilJumlahBawahController.text) +
              parseValue(backsplashController.text) +
              parseValue(aksesorisController.text)) *
          1000;

      double uangMuka = parseValue(uangMukaController.text) * 1000;
      double pelunasan = subTotal - uangMuka;

      Map<String, dynamic> data = {
        "nama": namaController.text,
        "alamat": alamatController.text,
        "hargaAtas": hargaAtasController.text,
        "hargaBawah": hargaBawahController.text,
        "jumlahAtas": jumlahAtas.toStringAsFixed(2),
        "jumlahBawah": jumlahBawah.toStringAsFixed(2),
        "hasilJumlahAtas": hasilJumlahAtasController.text,
        "hasilJumlahBawah": hasilJumlahBawahController.text,
        "backsplash": backsplashController.text,
        "aksesoris": aksesorisController.text,
        "uangMuka": "Rp ${_formatter.format(uangMuka.round())}",
        "subTotal": "Rp ${_formatter.format(subTotal.round())}",
        "pelunasan": "Rp ${_formatter.format(pelunasan.round())}",
        "tanggal": Timestamp.now(),
      };

      await FirebaseFirestore.instance
      .collection("pesanan kitchen L")
      .add(data);

  double screenWidth = MediaQuery.of(context).size.width;

      ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth > 600 ? 50 : 20,
        vertical: 20,
      ),
      content: SizedBox(
        height: screenWidth > 600 ? 50 : 30,
        child: Center(
          child: Text(
            "Data berhasil disimpan!",
            style: TextStyle(
              fontSize: screenWidth > 600 ? 20 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 1),
    ),
  );

      Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const INV_Tipe_L(),
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
    backsplashController.removeListener(updateUangMuka);
    aksesorisController.removeListener(updateUangMuka);

    hargaAtasController.dispose();
    hargaBawahController.dispose();
    hasilJumlahAtasController.dispose();
    hasilJumlahBawahController.dispose();
    backsplashController.dispose();
    aksesorisController.dispose();
    uangMukaController.dispose();

    jumlahBawah1Controller.dispose();
    jumlahBawah2Controller.dispose();
    _kitchenLetterLBawahController.dispose();

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
    _setupControllerListener(backsplashController);
    _setupControllerListener(aksesorisController);
    _setupControllerListener(uangMukaController);

    listenToHargaKitchenSet("Kitchen Set Atas", hargaAtasController);
    listenToHargaKitchenSet("Kitchen Set Bawah", hargaBawahController);
    listenToKitchenLetterL();
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()),
                            );
                          },
                          child: Image.asset(
                            "assets/images/back.png",
                            height: screenHeight * 0.035,
                            width: screenHeight * 0.035,
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
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("keranjang")
                          .doc("listKeranjang")
                          .snapshots(),
                      builder: (context, snapshot) {
                        int jumlahItem = 0;

                        if (snapshot.hasData && snapshot.data!.exists) {
                          var data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          jumlahItem = data.keys
                              .where((key) => key.startsWith("barang"))
                              .length;
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const KeranjangScreen()),
                            );
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Ikon Keranjang
                              Image.asset(
                                "assets/images/keranjang_merah.png",
                                height: MediaQuery.of(context).size.width > 600
                                    ? screenHeight * 0.045
                                    : screenHeight * 0.035,
                                width: MediaQuery.of(context).size.width > 600
                                    ? screenHeight * 0.045
                                    : screenHeight * 0.035,
                                fit: BoxFit.contain,
                              ),
                              // Badge Jumlah Item (Ditampilkan jika jumlahItem > 0)
                              if (jumlahItem > 0)
                                Positioned(
                                  top: -6, // Ubah agar lebih rapi
                                  right: -6,
                                  child: Container(
                                    width: screenHeight *
                                        0.024, // Ukuran lebih proporsional
                                    height: screenHeight * 0.024,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF5252),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 1),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      jumlahItem.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenHeight * 0.015,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
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
                                      "Tipe Letter L",
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
                                        fontWeight: FontWeight.normal,
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
                                        fontWeight: FontWeight.normal,
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      600
                                                  ? "Kitchen Set Atas"
                                                  : "Atas",
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.normal,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.032,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Harga",
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.normal,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.032,
                                            ),
                                          ),
                                          Spacer(),
                                        ],
                                      ),
                                      SizedBox(height: 7),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: TextField(
                                              controller: jumlahAtas1Controller,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        600
                                                    ? 25
                                                    : 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              onChanged: (value) =>
                                                  _updateHasilJumlah(
                                                      isAtas: true),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "+",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.06,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                            flex: 1,
                                            child: TextField(
                                              controller: jumlahAtas2Controller,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        600
                                                    ? 25
                                                    : 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              onChanged: (value) =>
                                                  _updateHasilJumlah(
                                                      isAtas: true),
                                            ),
                                          ),
                                          SizedBox(width: 7),
                                          Text(
                                            "-",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.06,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                            flex: 1,
                                            child: TextField(
                                              controller:
                                                  _kitchenLetterLAtasController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        600
                                                    ? 30
                                                    : 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              readOnly: true,
                                              onChanged: (value) =>
                                                  _updateHasilJumlah(
                                                      isAtas: true),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "X",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                            flex: 2,
                                            child: TextField(
                                              controller: hargaAtasController,
                                              readOnly: true,
                                              style: GoogleFonts.manrope(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04,
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
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Hasil Jumlah",
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.normal,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.032,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      TextField(
                                        controller: hasilJumlahAtasController,
                                        readOnly: true,
                                        style: GoogleFonts.manrope(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                  SizedBox(height: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      600
                                                  ? "Kitchen Set Bawah"
                                                  : "Bawah",
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.normal,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.032,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Harga",
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.normal,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.032,
                                            ),
                                          ),
                                          Spacer(),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: TextField(
                                              controller:
                                                  jumlahBawah1Controller,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        600
                                                    ? 25
                                                    : 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              onChanged: (value) =>
                                                  _updateHasilJumlah(
                                                      isAtas: false),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "+",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.06,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                            flex: 1,
                                            child: TextField(
                                              controller:
                                                  jumlahBawah2Controller,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        600
                                                    ? 25
                                                    : 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              onChanged: (value) =>
                                                  _updateHasilJumlah(
                                                      isAtas: false),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "-",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.06,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                            flex: 1,
                                            child: TextField(
                                              controller:
                                                  _kitchenLetterLBawahController,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        600
                                                    ? 30
                                                    : 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              readOnly: true,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "X",
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                            flex: 2,
                                            child: TextField(
                                              controller: hargaBawahController,
                                              readOnly: true,
                                              style: GoogleFonts.manrope(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04,
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
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Hasil Jumlah",
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.normal,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.032,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      TextField(
                                        controller: hasilJumlahBawahController,
                                        readOnly: true,
                                        style: GoogleFonts.manrope(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.005),
                                    child: Text(
                                      "Backsplash",
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.normal,
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
                                        fontWeight: FontWeight.normal,
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
                                        fontWeight: FontWeight.normal,
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
                              top: screenHeight * 0.025,
                              right: screenHeight * 0.025,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Tipe_U()),
                                  );
                                },
                                child: Image.asset(
                                  "assets/images/back_rotasi.png",
                                  height: screenHeight * 0.035,
                                  width: screenHeight * 0.035,
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
          onPressed: () {
            tambahKeKeranjang("Kitchen Tipe Letter L", hitungSubTotal());
          },
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
              if (MediaQuery.of(context).size.width > 600) // Jika tablet
                Text(
                  "Keranjang",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                  ),
                )
              else // Jika mobile, pakai gambar
                Image.asset(
                            "assets/images/keranjang_putih.png",
                            height: MediaQuery.of(context).size.height <= 700
                                ? MediaQuery.of(context).size.height * 0.035
                                : MediaQuery.of(context).size.height * 0.03,
                            width: MediaQuery.of(context).size.height <= 700
                                ? MediaQuery.of(context).size.height * 0.035
                                : MediaQuery.of(context).size.height * 0.03,
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
            simpanDataKeFirestore(context);
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
