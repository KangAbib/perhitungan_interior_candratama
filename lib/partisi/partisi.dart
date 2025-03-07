import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ganesha_interior/Invoice/INV_partisi.dart';
import 'package:ganesha_interior/backdrop_tv/backdrop_tv.dart';
import 'package:ganesha_interior/keranjang/list_keranjang.dart';
import 'package:ganesha_interior/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PartisiScreen extends StatefulWidget {
  const PartisiScreen({super.key});

  @override
  State<PartisiScreen> createState() => _PartisiScreenState();
}

class _PartisiScreenState extends State<PartisiScreen> {
  TextEditingController partisiController = TextEditingController(text: "Rp ");
  TextEditingController uangMukaController = TextEditingController(text: "Rp ");
  TextEditingController jumlahController = TextEditingController(text: "Rp ");
  TextEditingController namaController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController ukuranpartisiController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NumberFormat _formatter = NumberFormat("#,###", "id_ID");

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _setupControllerListener(partisiController);
    _setupControllerListener(ukuranpartisiController);
  }

  void _setupControllerListener(TextEditingController controller) {
    controller.addListener(() {
      _hitungPartisi();
    });
  }

  void _hitungPartisi() {
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

    double ukuranPartisi = parseUkuran(ukuranpartisiController.text);
    double hargaPartisi = parseHarga(partisiController.text);

    double totalHarga = ukuranPartisi * hargaPartisi;
    double uangMuka = totalHarga * 0.6;

    print("Ukuran: $ukuranPartisi, Harga: $hargaPartisi, Total: $totalHarga");

    setState(() {
      jumlahController.text = "Rp ${_formatter.format(totalHarga)}";
      uangMukaController.text = "Rp ${_formatter.format(uangMuka)}";
    });
  }

  double hitungSubTotal() {
    double parseValue(String text) {
      return double.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }

    return parseValue(jumlahController.text);
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

      if (existingBarangKey.isNotEmpty) {
        await keranjangRef.update({
          "$existingBarangKey.harga": harga,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Harga $namaInterior berhasil diperbarui "),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        String barangKey = "barang$nomorBarang";

        await keranjangRef.set({
          barangKey: {"nama": namaInterior, "harga": harga}
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$namaInterior ditambahkan ke keranjang"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menambahkan ke keranjang."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void simpanDataKeFirestore() async {
    if (namaController.text.isEmpty ||
        alamatController.text.isEmpty ||
        ukuranpartisiController.text.isEmpty ||
        partisiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap isi semua kolom sebelum menyimpan."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Debugging untuk melihat data sebelum dikirim ke Firestore
    print("Nama: ${namaController.text}");
    print("Alamat: ${alamatController.text}");
    print("Ukuran Partisi: ${ukuranpartisiController.text}");
    print("Harga Partisi: ${partisiController.text}");

    double parseValue(String text) {
      String cleanedText =
          text.replaceAll("Rp ", "").replaceAll(RegExp(r'[^0-9]'), '');
      return double.tryParse(cleanedText) ?? 0.0;
    }

    double subTotal = parseValue(jumlahController.text);
    double uangMuka = parseValue(uangMukaController.text);
    double pelunasan = subTotal - uangMuka;

    Map<String, dynamic> data = {
      "nama": namaController.text,
      "alamat": alamatController.text,
      "ukuranPartisi": ukuranpartisiController.text,
      "hargaPartisi": partisiController.text,
      "jumlahAtas": jumlahController.text,
      "uangMuka": uangMukaController.text,
      "pelunasan": "Rp ${_formatter.format(pelunasan)}",
      "tanggal": Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance.collection("pesanan Partisi").add(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data berhasil disimpan!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const INV_Partisi(),
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
    partisiController.dispose();
    uangMukaController.dispose();
    jumlahController.dispose();
    namaController.dispose();
    alamatController.dispose();
    ukuranpartisiController.dispose();
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
                          "Estimasi Harga",
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
                                height: screenHeight * 0.035,
                                width: screenHeight * 0.035,
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
                                      "Partisi",
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
                                          controller: ukuranpartisiController,
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
                                            _hitungPartisi();
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10),

                                      // Teks "×" di tengah
                                      Text(
                                        "×",
                                        style: GoogleFonts.manrope(
                                          fontSize: screenWidth * 0.075,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      // Tambahkan jarak kecil
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: partisiController,
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

                                              partisiController.value =
                                                  TextEditingValue(
                                                text: "Rp $formattedValue",
                                                selection:
                                                    TextSelection.collapsed(
                                                        offset:
                                                            "Rp $formattedValue"
                                                                .length),
                                              );
                                            } else {
                                              partisiController.text = "Rp ";
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
                                        builder: (context) => BackdropTV()),
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
                  tambahKeKeranjang("Partisi", hitungSubTotal());
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
