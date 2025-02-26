import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  }

  void _setupControllerListener(TextEditingController controller) {
  controller.addListener(() {
    String text = controller.text.replaceAll(RegExp(r'[^0-9.,]'), '');
    if (text.isNotEmpty) {
      
      double parsedValue = double.tryParse(text.replaceAll(",", ".")) ?? 0;
      String formattedText = controller == minibarController
          ? "Rp ${_formatter.format(parsedValue)}"
          : text; 
      if (controller.text != formattedText) {
        controller.value = TextEditingValue(
          text: formattedText,
          selection: TextSelection.collapsed(offset: formattedText.length),
        );
      }
    } else {
      controller.text = controller == minibarController ? "Rp " : "";
    }
    _hitungMinibar();
  });
}

  void _hitungMinibar() {
  double parseValue(String text) {
  String cleanedText = text.replaceAll(RegExp(r'[^0-9,]'), ''); 
  cleanedText = cleanedText.replaceAll(RegExp(r',+'), ','); 
  if (cleanedText.contains(',')) {
    
    cleanedText = cleanedText.replaceAll('.', '');
  } else {
    
    cleanedText = cleanedText.replaceAll(',', '');
  }
  return double.tryParse(cleanedText.replaceAll(',', '.')) ?? 0;
}

  double ukuranMinibar = parseValue(ukuranminibarController.text);
  double hargaMinibar = parseValue(minibarController.text);

  double totalHarga = ukuranMinibar * hargaMinibar;
  double uangMuka = totalHarga * 0.6;

  print("ukuran: $ukuranMinibar, harga: $hargaMinibar, total: $totalHarga");

  setState(() {
    jumlahController.text = "Rp ${_formatter.format(totalHarga)}";
    uangMukaController.text = "Rp ${_formatter.format(uangMuka)}";
  });
}


  void simpanDataKeFirestore() async {
    if (namaController.text.isEmpty ||
        alamatController.text.isEmpty ||
        ukuranminibarController.text.isEmpty ||
        minibarController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap isi semua kolom sebelum menyimpan."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, dynamic> data = {
      "nama": namaController.text,
      "alamat": alamatController.text,
      "ukuranMinibar": ukuranminibarController.text,
      "hargaMinibar": minibarController.text,
      "jumlahAtas": jumlahController.text,
      "uangMuka": uangMukaController.text,
      "tanggal": Timestamp.now(),
    };

    try {
      await _firestore.collection("pesanan minibar").add(data);
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
    minibarController.dispose();
    uangMukaController.dispose();
    jumlahController.dispose();
    namaController.dispose();
    alamatController.dispose();
    ukuranminibarController.dispose();
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
                        const Text(
                          "Kitchen Set",
                          style: TextStyle(
                            color: Color(0xFFFF5252),
                            fontSize: 18,
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
                                        flex: 2,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: Text(
                                            "Ukuran",
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.w900,
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
                                              fontWeight: FontWeight.w900,
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
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
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
                                          ),
                                          keyboardType: TextInputType.number,
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
                                        fontWeight: FontWeight.w900,
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
                                        builder: (context) => Minibar()),
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
