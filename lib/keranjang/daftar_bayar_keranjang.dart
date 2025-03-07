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

  double totalHarga = 0;
  double uangMuka = 0;
  double diskon = 0;
  bool isDiskonValid = true;
  final formatCurrency = NumberFormat("#,###", "id_ID");

  String formatRupiah(String value) {
    value = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.isEmpty) return "Rp ";

    final number = NumberFormat("#,###", "id_ID");
    return "Rp ${number.format(int.parse(value))}";
  }

  void hapusItemKeranjang(String itemKey) {
    FirebaseFirestore.instance
        .collection("keranjang")
        .doc("listKeranjang")
        .update({
      itemKey: FieldValue.delete(),
    }).then((_) {
      print("Item $itemKey berhasil dihapus");
    }).catchError((error) {
      print("Gagal menghapus item: $error");
    });
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

  @override
  void initState() {
    super.initState();

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
  }

  @override
  void dispose() {
    diskonController.dispose();
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
                                            fontSize: screenWidth * 0.05,
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
                                        height: 180,
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
                                                  vertical: 5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: ListTile(
                                                leading: Text(
                                                  "${index + 1}.",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                title: Text(
                                                  namaBarang,
                                                  style:
                                                      TextStyle(fontSize: 14),
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
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFFFF5252),
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
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
                                            height: 45,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Tambah_ItemScreen(),
                                                  ),
                                                );
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
                                                  fontSize: 16,
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
                                          border: OutlineInputBorder(),
                                          suffixIcon: Icon(
                                            isDiskonValid
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: isDiskonValid
                                                ? Colors.green
                                                : Colors.red,
                                          ),
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
                                          labelText: "Uang Muka",
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
        padding: EdgeInsets.all(12),
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
            Future.delayed(Duration.zero, () {
              uangMukaController.text = "Rp ${formatCurrency.format(uangMuka)}";
            });
            int jumlahItem = items.length;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total List:", style: TextStyle(fontSize: 14)),
                    Text(
                      jumlahItem.toString(),
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Harga:", style: TextStyle(fontSize: 14)),
                    Text(
                      "Rp ${formatCurrency.format(totalHarga)}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5252),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
  width: double.infinity,
  height: 45,
  child: ElevatedButton(
    onPressed: () async {
      // Validasi jika nama dan alamat kosong
      if (namaController.text.isEmpty || alamatController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Harap isi nama dan alamat sebelum membayar!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Ambil daftar item dari koleksi 'keranjang'
      DocumentSnapshot keranjangSnapshot = await FirebaseFirestore.instance
          .collection("keranjang")
          .doc("listKeranjang")
          .get();

      if (!keranjangSnapshot.exists || keranjangSnapshot.data() == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Keranjang masih kosong!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Map<String, dynamic> keranjangData =
          keranjangSnapshot.data() as Map<String, dynamic>;

      // Hitung total harga item dalam keranjang
      double totalHargaItem = 0;
      List<Map<String, dynamic>> daftarBarang = [];

      keranjangData.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          daftarBarang.add(value);
          totalHargaItem += (value["harga"] ?? 0).toDouble();
        }
      });

      // Ambil nilai uang muka & diskon dari inputan
      double uangMukaInput = double.tryParse(
              uangMukaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;
      double diskonInput = double.tryParse(
              diskonController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;

      // Hitung total harga setelah diskon
      double totalHargaSetelahDiskon = totalHargaItem - diskonInput;
      if (totalHargaSetelahDiskon < 0) totalHargaSetelahDiskon = 0;

      // Hitung sisa pembayaran setelah dikurangi uang muka
      double sisaPembayaran = totalHargaSetelahDiskon - uangMukaInput;
      if (sisaPembayaran < 0) sisaPembayaran = 0;

      // Simpan pesanan ke koleksi 'pesanan_keranjang'
      await FirebaseFirestore.instance.collection("pesanan_keranjang").add({
        "nama": namaController.text.trim(),
        "alamat": alamatController.text.trim(),
        "items": daftarBarang,
        "total_harga": totalHargaItem,
        "diskon": diskonInput,
        "total_setelah_diskon": totalHargaSetelahDiskon,
        "uang_muka": uangMukaInput,
        "sisa_pembayaran": sisaPembayaran,
        "timestamp": FieldValue.serverTimestamp(),
      });

      // Hapus isi keranjang setelah pembayaran sukses
      await FirebaseFirestore.instance.collection("keranjang").doc("listKeranjang").set({});

      // Navigasi ke halaman INV_Keranjang
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => INV_Keranjang()),
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
        fontSize: 16,
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
