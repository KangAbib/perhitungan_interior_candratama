import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ganesha_interior/Invoice/INV_minibar.dart';
import 'package:ganesha_interior/keranjang/list_keranjang.dart';
import 'package:ganesha_interior/kitchen_set/meja_island.dart';
import 'package:ganesha_interior/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Minibar extends StatefulWidget {
  const Minibar({super.key});

  @override
  State<Minibar> createState() => _MinibarState();
}

class _MinibarState extends State<Minibar> {
  TextEditingController minibarController = TextEditingController(text: "Rp ");
  TextEditingController uangMukaController = TextEditingController(text: "Rp ");
  TextEditingController jumlahController = TextEditingController(text: "Rp ");
  TextEditingController namaController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController ukuranminibarController = TextEditingController();
  TextEditingController biayaSurveyController = TextEditingController(text :"Rp ");
  List<TextEditingController> namaItemControllers = [];
  List<TextEditingController> hargaItemControllers = [
    TextEditingController(text: "Rp ")
  ];
  bool showItemForm = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NumberFormat _formatter = NumberFormat("#,###", "id_ID");

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _setupControllerListener(minibarController);
    _setupControllerListener(ukuranminibarController);
    for (var controller in hargaItemControllers) {
      controller.addListener(() {
        _hitungMinibar();
      });
    }
  }

  void tambahItemField() {
    final namaController = TextEditingController();
    final hargaController = TextEditingController(text: "Rp ");

    // Tambahkan listener langsung di sini
    hargaController.addListener(() {
      _hitungMinibar();
    });

    setState(() {
      namaItemControllers.add(namaController);
      hargaItemControllers.add(hargaController);
      showItemForm = true;
    });

    _hitungMinibar(); // hitung ulang setelah penambahan
  }

  void _hapusItem(int index) {
    setState(() {
      namaItemControllers[index].dispose();
      hargaItemControllers[index].dispose();
      namaItemControllers.removeAt(index);
      hargaItemControllers.removeAt(index);
      // Panggil _hitungPartisi setelah menghapus item
      _hitungMinibar();
    });
  }


  void _setupControllerListener(TextEditingController controller) {
    controller.addListener(() {
      _hitungMinibar();
    });
  }

  void _hitungMinibar() {
    double parseUkuran(String text) {
      String cleanedText =
          text.replaceAll(RegExp(r'[^0-9,.]'), '').replaceAll(',', '.');

      return double.tryParse(cleanedText) ?? 0.0;
    }

    double parseHarga(String text) {
      String cleanedText =
          text.replaceAll("Rp ", "").replaceAll(RegExp(r'[^0-9]'), '');

      return double.tryParse(cleanedText) ?? 0.0;
    }

    double ukuranMinibar = parseUkuran(ukuranminibarController.text);
    double hargaMinibar = parseHarga(minibarController.text);
    double totalHargaItem = 0;
    for (var controller in hargaItemControllers) {
      totalHargaItem += parseHarga(controller.text);
    }

    double totalHarga = ukuranMinibar * hargaMinibar;
    double total = totalHarga + totalHargaItem;
    double uangMuka = total * 0.6;

    print("Ukuran: $ukuranMinibar, Harga: $hargaMinibar, Total: $totalHarga");

    setState(() {
      jumlahController.text = "Rp ${_formatter.format(totalHarga)}";
      uangMukaController.text = "Rp ${_formatter.format(uangMuka)}";
    });
  }

  double hitungSubTotal() {
    double parseUkuran(String text) {
      String cleanedText = text.replaceAll(RegExp(r'[^0-9,.]'), '').replaceAll(',', '.');
      return double.tryParse(cleanedText) ?? 0.0;
    }

    double parseHarga(String text) {
      String cleanedText = text.replaceAll("Rp ", "").replaceAll(RegExp(r'[^0-9]'), '');
      return double.tryParse(cleanedText) ?? 0.0;
    }

    double ukuranMinibar = parseUkuran(ukuranminibarController.text);
    double hargaMinibar = parseHarga(minibarController.text);

    double totalHargaItem = 0;
    for (var controller in hargaItemControllers) {
      totalHargaItem += parseHarga(controller.text);
    }

    // Menggunakan variabel ukuranMejaRias dan hargaMejaRias yang sudah didefinisikan
    return (ukuranMinibar * hargaMinibar) + totalHargaItem;
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
          barangKey: {"nama": namaInterior, "harga": harga, "timestamp": timestamp,}
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

  void simpanDataKeFirestore() async {
    if (namaController.text.isEmpty ||
        alamatController.text.isEmpty ||
        ukuranminibarController.text.isEmpty ||
        minibarController.text.isEmpty) {
       _showSnackBar("Harap isi semua kolom sebelum menyimpan.", Colors.red);
      return;
    }

    // Debugging untuk melihat data sebelum dikirim ke Firestore
    print("Nama: ${namaController.text}");
    print("Alamat: ${alamatController.text}");
    print("Ukuran Minibar: ${ukuranminibarController.text}");
    print("Harga Minibar: ${minibarController.text}");

    double parseValue(String text) {
      String cleanedText =
          text.replaceAll("Rp ", "").replaceAll(RegExp(r'[^0-9]'), '');
      return double.tryParse(cleanedText) ?? 0.0;
    }

    double subTotal = parseValue(jumlahController.text);
    double uangMuka = parseValue(uangMukaController.text);
    double ukuranMinibar = parseValue(ukuranminibarController.text);
    double hargaMinibar = parseValue(minibarController.text);
     String biayaSurveyText = biayaSurveyController.text.trim();
      double biayaSurvey = biayaSurveyText.isEmpty
    ? 0
    : parseValue(biayaSurveyText);
    double totalHargaItem = 0;
    for (var controller in hargaItemControllers) {
      totalHargaItem += parseValue(controller.text);
    }
    double totalHarga = ukuranMinibar * hargaMinibar;
    double total = totalHarga + totalHargaItem;
    double pelunasan = total - uangMuka - biayaSurvey;

    List<Map<String, dynamic>> detailItems = [];

    for (int i = 0; i < namaItemControllers.length; i++) {
      String nama = namaItemControllers[i].text.trim();
      String hargaText = hargaItemControllers[i].text.trim();
      double harga = double.tryParse(hargaText
              .replaceAll("Rp ", "")
              .replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;

      if (nama.isNotEmpty && harga > 0) {
        detailItems.add({
          "namaItem": nama,
          "hargaItem": harga,
        });
      }
    }

    Map<String, dynamic> data = {
      "nama": namaController.text,
      "alamat": alamatController.text,
      "ukuranMinibar": ukuranminibarController.text,
      "hargaMinibar": minibarController.text,
      "jumlah": jumlahController.text,
      "uangMuka": uangMukaController.text,
       "biayaSurvey": "Rp ${_formatter.format(biayaSurvey.round())}",
      "pelunasan": "Rp ${_formatter.format(pelunasan)}",
      "Total": "Rp ${_formatter.format(total)}",
      "detailItems": detailItems,
      "tanggal": Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance
      .collection("pesanan minibar")
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
      builder: (context) => const INV_Minibar(),
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
    minibarController.dispose();
    uangMukaController.dispose();
    jumlahController.dispose();
    namaController.dispose();
    alamatController.dispose();
    ukuranminibarController.dispose();
    biayaSurveyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
                                      "Minibar",
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
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: Text(
                                            "Ukuran",
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.normal,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.035,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 20),
                                          child: Text(
                                            "Harga",
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.normal,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.035,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: ukuranminibarController,
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
                                            hintText: "Masukkan ukuran",
                                          ),
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          textAlign: TextAlign.center,
                                          onChanged: (value) {
                                            _hitungMinibar();
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10),

                                      // Teks "×" di tengah
                                      Text(
                                        "×",
                                        style: GoogleFonts.manrope(
                                          fontSize: screenWidth * 0.07,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      // Tambahkan jarak kecil
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: minibarController,
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
                                            hintText: "Masukkan harga",
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            String cleanedText =
                                                value.replaceAll(
                                                    RegExp(r'[^0-9]'), '');

                                            if (cleanedText.isNotEmpty) {
                                              double parsedValue =
                                                  double.tryParse(
                                                          cleanedText) ??
                                                      0;
                                              String formattedValue = _formatter
                                                  .format(parsedValue);

                                              minibarController.value =
                                                  TextEditingValue(
                                                text: "Rp $formattedValue",
                                                selection:
                                                    TextSelection.collapsed(
                                                        offset:
                                                            "Rp $formattedValue"
                                                                .length),
                                              );
                                            } else {
                                              minibarController.text = "Rp ";
                                            }
                                          },
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
                                      "Hasil Jumlah",
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
                                    controller: jumlahController,
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
                                  SizedBox(height: 10),
                                  Stack(
                                    children: [
                                      SizedBox(height: 5),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              tambahItemField();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(7),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.blue,
                                              ),
                                              child: Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible: showItemForm,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: List.generate(
                                          namaItemControllers.length, (index) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Label Nama Item
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.005,
                                              ),
                                              child: Text(
                                                "Nama Item ${index + 1}",
                                                style: GoogleFonts.lato(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.035,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            // TextField Nama Item
                                            TextField(
                                              controller:
                                                  namaItemControllers[index],
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
                                                  horizontal: 12,
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: Icon(Icons.close,
                                                      color: Colors.red),
                                                  onPressed: () =>
                                                      _hapusItem(index),
                                                ),
                                              ),
                                              keyboardType: TextInputType.text,
                                            ),
                                            SizedBox(height: 10),

                                            // Label Harga Item
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.005,
                                              ),
                                              child: Text(
                                                "Harga Item ${index + 1}",
                                                style: GoogleFonts.lato(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.035,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),

                                            // TextField Harga Item
                                            TextField(
                                              controller:
                                                  hargaItemControllers[index],
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
                                                  horizontal: 12,
                                                ),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                String cleanedText =
                                                    value.replaceAll(
                                                        RegExp(r'[^0-9]'), '');
                                                if (cleanedText.isNotEmpty) {
                                                  double parsedValue =
                                                      double.tryParse(
                                                              cleanedText) ??
                                                          0;
                                                  String formattedValue =
                                                      _formatter
                                                          .format(parsedValue);
                                                  hargaItemControllers[index]
                                                      .value = TextEditingValue(
                                                    text: "Rp $formattedValue",
                                                    selection:
                                                        TextSelection.collapsed(
                                                      offset:
                                                          "Rp $formattedValue"
                                                              .length,
                                                    ),
                                                  );
                                                } else {
                                                  hargaItemControllers[index]
                                                      .text = "Rp ";
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.005),
                                    child: Text(
                                      "DP (60%)",
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
                                   SizedBox(height: 10),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.005),
                                    child: Text(
                                      "Biaya Survei",
                                      style: GoogleFonts.lato(
                                        fontWeight: FontWeight.normal,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.035,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  
                                      Expanded(
                                        flex : 2,
                                        child: TextField(
                                          controller: biayaSurveyController,
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
                                           
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            String cleanedText =
                                                value.replaceAll(
                                                    RegExp(r'[^0-9]'), '');

                                            if (cleanedText.isNotEmpty) {
                                              double parsedValue =
                                                  double.tryParse(
                                                          cleanedText) ??
                                                      0;
                                              String formattedValue = _formatter
                                                  .format(parsedValue);

                                              biayaSurveyController.value =
                                                  TextEditingValue(
                                                text: "Rp $formattedValue",
                                                selection:
                                                    TextSelection.collapsed(
                                                        offset:
                                                            "Rp $formattedValue"
                                                                .length),
                                              );
                                            } else {
                                              biayaSurveyController.text = "Rp ";
                                            }
                                          },
                                        ),
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
                                        builder: (context) => MejaIsland()),
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
                onPressed: () {tambahKeKeranjang("Minibar", hitungSubTotal());
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
                  simpanDataKeFirestore();
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
