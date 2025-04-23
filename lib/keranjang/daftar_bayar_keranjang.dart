import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_interior/keranjang/INV_keranjang.dart';
import 'package:ganesha_interior/keranjang/tambah_item_keranjang.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Daftar_KeranjangScreen extends StatefulWidget {
  const Daftar_KeranjangScreen({super.key});

  @override
  State<Daftar_KeranjangScreen> createState() => _Daftar_KeranjangScreenState();
}

class _Daftar_KeranjangScreenState extends State<Daftar_KeranjangScreen> {
  TextEditingController namaController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController uangMukaController = TextEditingController(text: "Rp ");
  TextEditingController diskonController = TextEditingController(text: "Rp ");
  TextEditingController diskonTambahanController =
      TextEditingController(text: "Rp ");
  TextEditingController biayaSurveyController =
      TextEditingController(text: "Rp ");
  double totalHarga = 0;
  double uangMuka = 0;
  double diskon = 0;
  bool isDiskonValid = true;
  bool isDiskonVisible = false;
  final formatCurrency = NumberFormat("#,###", "id_ID");
  final NumberFormat _formatter = NumberFormat("#,###", "id_ID");

  String formatRupiah(String value) {
    value = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.isEmpty) return "Rp ";

    final number = NumberFormat("#,###", "id_ID");
    return "Rp ${number.format(int.parse(value))}";
  }

  void hapusItemKeranjang(String itemKey) async {
    var keranjangRef =
        FirebaseFirestore.instance.collection("keranjang").doc("listKeranjang");

    await keranjangRef.update({
      itemKey: FieldValue.delete(),
    }).then((_) async {
      print("✅ Item $itemKey berhasil dihapus");

      // Cek ulang apakah masih ada item dengan isFromTambah: true
      var docSnapshot = await keranjangRef.get();
      if (docSnapshot.exists) {
        Map<String, dynamic>? data = docSnapshot.data();
        bool masihAdaDiskon = false;

        data?.forEach((key, value) {
          if (value is Map<String, dynamic> && value["isFromTambah"] == true) {
            masihAdaDiskon = true;
          }
        });

        setState(() {
          isDiskonVisible = masihAdaDiskon;
        });

        print("🔄 isDiskonVisible setelah hapus: $isDiskonVisible");
      }
    }).catchError((error) {
      print("❌ Gagal menghapus item: $error");
    });
  }

  void tambahItem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Tambah_ItemScreen(),
      ),
    );

    // Cek apakah ada barang baru dengan isFromTambah: true
    cekDiskonTambahan();
  }

  void cekDiskonTambahan() async {
    var keranjangRef =
        FirebaseFirestore.instance.collection("keranjang").doc("listKeranjang");

    var docSnapshot = await keranjangRef.get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();

      bool adaDiskonTambahan = false;

      data?.forEach((key, value) {
        if (value is Map<String, dynamic> && value["isFromTambah"] == true) {
          adaDiskonTambahan = true;
        }
      });

      // Update state jika ada barang yang berasal dari Tambah_ItemScreen
      if (adaDiskonTambahan) {
        setState(() {
          isDiskonVisible = true;
        });

        print("✅ Form Diskon Tambahan muncul!");
        print("✅ isFromTambah tetap ada di Firestore!");
      }
    }
  }

  void tambahItemKeranjang(String nama, int harga) {
    FirebaseFirestore.instance
        .collection("keranjang")
        .doc("listKeranjang")
        .update({
      "barang_${DateTime.now().millisecondsSinceEpoch}": {
        "nama": nama,
        "harga": harga,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      },
    }).then((_) {
      print("Item berhasil ditambahkan");
    }).catchError((error) {
      print("Gagal menambahkan item: $error");
    });
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
          duration: Duration(seconds: 1)),
    );
  }

  @override
  void initState() {
    super.initState();
    cekDiskonTambahan();

    biayaSurveyController.addListener(() {
  String text = biayaSurveyController.text;

  // Cegah penghapusan awalan "Rp "
  if (!text.startsWith("Rp ")) {
    biayaSurveyController.text = "Rp ";
    biayaSurveyController.selection = TextSelection.collapsed(offset: 3);
    return;
  }

  // Format ulang angka ke format rupiah
  String formattedText = formatRupiah(text);

  if (biayaSurveyController.text != formattedText) {
    biayaSurveyController.text = formattedText;
    biayaSurveyController.selection =
        TextSelection.collapsed(offset: formattedText.length);
  }
});

    diskonController.addListener(() {
      String text = diskonController.text;

      if (!text.startsWith("Rp ")) {
        diskonController.text = "Rp ";
        diskonController.selection = TextSelection.collapsed(offset: 3);
      } else {
        String formattedText = formatRupiah(text);

        if (diskonController.text != formattedText) {
          diskonController.removeListener(() {});
          diskonController.text = formattedText;
          diskonController.selection =
              TextSelection.collapsed(offset: formattedText.length);
          diskonController.addListener(() {});
        }
      }

      double diskonInput =
          double.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      double maxDiskon = totalHarga * 0.01;

      if (isDiskonValid != (diskonInput <= maxDiskon)) {
        setState(() {
          isDiskonValid = diskonInput <= maxDiskon;
        });
      }
    });
    diskonTambahanController.addListener(() {
      String text = diskonTambahanController.text;

      // Pastikan awalan "Rp " tidak hilang
      if (!text.startsWith("Rp ")) {
        diskonTambahanController.text = "Rp ";
        diskonTambahanController.selection = TextSelection.collapsed(offset: 3);
        return; // Hentikan proses jika baru mengembalikan "Rp "
      }

      // Format ulang angka ke format rupiah
      String formattedText = formatRupiah(text);

      if (diskonTambahanController.text != formattedText) {
        diskonTambahanController.text = formattedText;
        diskonTambahanController.selection =
            TextSelection.collapsed(offset: formattedText.length);
      }
    });
  }

  @override
  void dispose() {
    diskonController.dispose();
    diskonTambahanController.dispose();
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
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
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
              ),
            ),
          ),
          Positioned.fill(
            top: screenHeight * 0.097,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("keranjang")
                  .doc("listKeranjang")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: CircularProgressIndicator());
                }

                var data = snapshot.data!.data() as Map<String, dynamic>;
                List<Map<String, dynamic>> items = [];

                data.forEach((key, value) {
                  if (key.startsWith("barang")) {
                    items.add({
                      "key": key,
                      "nama": value["nama"],
                      "harga": value["harga"],
                      "timestamp": value["timestamp"] ?? 0,
                    });
                  }
                });

                items.sort((a, b) => b["timestamp"].compareTo(a["timestamp"]));

                items.sort((a, b) => b["timestamp"].compareTo(a["timestamp"]));
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text(
                                          "List Keranjang",
                                          style: GoogleFonts.manrope(
                                            fontSize: screenWidth * 0.045,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFFFF5252),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.005),
                                        child: Text(
                                          "Nama Klien",
                                          style: GoogleFonts.lato(
                                            fontWeight: FontWeight.normal,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.035,
                                          ),
                                        ),
                                      ),
                                      TextField(
                                        controller: namaController,
                                        style: GoogleFonts.manrope(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  600
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.035,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Masukkan nama",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.005),
                                        child: Text(
                                          "Alamat",
                                          style: GoogleFonts.lato(
                                            fontWeight: FontWeight.normal,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.035,
                                          ),
                                        ),
                                      ),
                                      TextField(
                                        maxLines: 3,
                                        controller: alamatController,
                                        style: GoogleFonts.manrope(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  600
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.035,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Masukkan alamat lengkap",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.005),
                                        child: Text(
                                          "List Interior",
                                          style: GoogleFonts.lato(
                                            fontWeight: FontWeight.normal,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.035,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width >
                                                    600
                                                ? 250
                                                : 180,
                                        child: ListView.builder(
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                          itemCount: items.length,
                                          itemBuilder: (context, index) {
                                            String namaBarang =
                                                items[index]["nama"];
                                            double screenWidth =
                                                MediaQuery.of(context)
                                                    .size
                                                    .width;

                                            if (screenWidth < 600) {
                                              namaBarang = namaBarang
                                                  .replaceAll(
                                                      RegExp(r'kitchen',
                                                          caseSensitive: false),
                                                      "")
                                                  .trim();
                                            }

                                            return Card(
                                              color: Color(0xFFD5D5D5),
                                              margin: EdgeInsets.symmetric(
                                                vertical: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        600
                                                    ? 8
                                                    : 5,
                                                horizontal:
                                                    MediaQuery.of(context)
                                                                .size
                                                                .width >
                                                            600
                                                        ? 16
                                                        : 0,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: ListTile(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  vertical:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width >
                                                              600
                                                          ? 10
                                                          : 2,
                                                  horizontal:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width >
                                                              600
                                                          ? 20
                                                          : 16,
                                                ),
                                                leading: Text(
                                                  "${index + 1}.",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                600
                                                            ? 18
                                                            : 14,
                                                  ),
                                                ),
                                                title: Text(
                                                  namaBarang,
                                                  style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                600
                                                            ? 18
                                                            : 14,
                                                  ),
                                                ),
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "Rp ${formatCurrency.format(items[index]["harga"])}",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width >
                                                                600
                                                            ? 18
                                                            : 14,
                                                        color:
                                                            Color(0xFFFF5252),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    GestureDetector(
                                                      onTap: () {
                                                        String itemKey =
                                                            items[index]["key"];
                                                        hapusItemKeranjang(
                                                            itemKey);
                                                      },
                                                      child: Icon(
                                                        Icons.close,
                                                        color: Colors.red,
                                                        size: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width >
                                                                600
                                                            ? 28
                                                            : 24,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: SizedBox(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    600
                                                ? 55
                                                : 45,
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    600
                                                ? 150
                                                : 100,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                tambahItem(); // ✅ Memanggil fungsi tambahItem()
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xFF4CAF50),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text(
                                                "Tambah",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width >
                                                              600
                                                          ? 18
                                                          : 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      TextField(
                                        controller: diskonController,
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.manrope(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: "Masukkan Diskon",
                                          labelStyle: GoogleFonts.manrope(
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 14,
                                          ),
                                          suffixIcon: Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: Icon(
                                              isDiskonValid
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color: isDiskonValid
                                                  ? Colors.green.shade600
                                                  : Colors.red.shade600,
                                              size: screenWidth * 0.05,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            isDiskonVisible, // ✅ Pastikan form hanya muncul saat isDiskonVisible = true
                                        child: Column(
                                          children: [
                                            SizedBox(height: 20),
                                            TextField(
                                              controller:
                                                  diskonTambahanController,
                                              keyboardType:
                                                  TextInputType.number,
                                              style: GoogleFonts.manrope(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              decoration: InputDecoration(
                                                labelText: "Diskon Tambahan",
                                                labelStyle: GoogleFonts.manrope(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.04,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[700],
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      TextField(
                                        controller: uangMukaController,
                                        readOnly: true,
                                        style: GoogleFonts.manrope(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: "DP (60%)",
                                          labelStyle: GoogleFonts.manrope(
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 14,
                                          ),
                                        ),
                                        keyboardType: TextInputType.none,
                                      ),
                                      SizedBox(height: 10),
                                      TextField(
                                        controller: biayaSurveyController,
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.manrope(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: "Biaya Survei",
                                          labelStyle: GoogleFonts.manrope(
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 14,
                                          ),
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
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding:
            EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 20 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("keranjang")
              .doc("listKeranjang")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return SizedBox.shrink();
            }

            var data = snapshot.data!.data() as Map<String, dynamic>;
            List<Map<String, dynamic>> items = [];

            data.forEach((key, value) {
              if (key.startsWith("barang")) {
                items.add({
                  "nama": value["nama"],
                  "harga": value["harga"],
                });
              }
            });

            totalHarga = items.fold(0, (sum, item) => sum + item["harga"]);
            uangMuka = totalHarga * 0.6;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              uangMukaController.text = "Rp ${formatCurrency.format(uangMuka)}";
            });
            int jumlahItem = items.length;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total List:",
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width > 600 ? 22 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      jumlahItem.toString(),
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width > 600 ? 22 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Harga:",
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width > 600 ? 25 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Rp ${formatCurrency.format(totalHarga)}",
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width > 600 ? 25 : 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5252),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width > 600 ? 55 : 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!isDiskonValid) {
                        _showSnackBar(
                            "Turunkan diskon hingga hijau!", Colors.red);
                        return;
                      }

                      if (namaController.text.isEmpty ||
                          alamatController.text.isEmpty) {
                        _showSnackBar(
                            "Harap isi nama dan alamat sebelum membayar!.",
                            Colors.red);
                        return;
                      }
                      DocumentSnapshot keranjangSnapshot =
                          await FirebaseFirestore.instance
                              .collection("keranjang")
                              .doc("listKeranjang")
                              .get();

                      if (!keranjangSnapshot.exists ||
                          keranjangSnapshot.data() == null) {
                        _showSnackBar("Keranjang masih kosong.", Colors.red);
                        return;
                      }

                      Map<String, dynamic> keranjangData =
                          keranjangSnapshot.data() as Map<String, dynamic>;

                      double totalHargaItem = 0;
                      List<Map<String, dynamic>> daftarBarang = [];

                      keranjangData.forEach((key, value) {
                        if (value is Map<String, dynamic>) {
                          daftarBarang.add(value);
                          totalHargaItem += (value["harga"] ?? 0).toDouble();
                        }
                      });
                      double parseValue(String text) {
                        String cleanedText = text
                            .replaceAll("Rp ", "")
                            .replaceAll(RegExp(r'[^0-9]'), '');
                        return double.tryParse(cleanedText) ?? 0.0;
                      }

                      double uangMukaInput = double.tryParse(uangMukaController
                              .text
                              .replaceAll(RegExp(r'[^0-9]'), '')) ??
                          0;
                      double diskonInput = double.tryParse(diskonController.text
                              .replaceAll(RegExp(r'[^0-9]'), '')) ??
                          0;
                      double diskonTambahan = double.tryParse(
                              diskonTambahanController.text
                                  .replaceAll(RegExp(r'[^0-9]'), '')) ??
                          0;
                      double diskontotal = diskonInput + diskonTambahan;
                      String biayaSurveyText =
                          biayaSurveyController.text.trim();
                      double biayaSurvey = biayaSurveyText.isEmpty
                          ? 0
                          : parseValue(biayaSurveyText);
                      double totalHargaSetelahDiskon =
                          totalHargaItem - diskonInput - diskonTambahan;
                      if (totalHargaSetelahDiskon < 0)
                        totalHargaSetelahDiskon = 0;

                      double sisaPembayaran =
                          totalHargaSetelahDiskon - uangMukaInput - biayaSurvey;
                      if (sisaPembayaran < 0) sisaPembayaran = 0;

                      await FirebaseFirestore.instance
                          .collection("pesanan_keranjang")
                          .add({
                        "nama": namaController.text.trim(),
                        "alamat": alamatController.text.trim(),
                        "items": daftarBarang,
                        "total_harga": totalHargaItem,
                        "diskon": diskonInput,
                        "diskon_tambahan": diskonTambahan,
                        "diskon_total": diskontotal,
                        "total_setelah_diskon": totalHargaSetelahDiskon,
                        "uang_muka": uangMukaInput,
                        "sisa_pembayaran": sisaPembayaran,
                        "biayaSurvey":
                            "Rp ${_formatter.format(biayaSurvey.round())}",
                        "timestamp": FieldValue.serverTimestamp(),
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => INV_Keranjang()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF5252),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Bayar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            MediaQuery.of(context).size.width > 600 ? 25 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
