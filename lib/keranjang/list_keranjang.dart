import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganesha_interior/keranjang/daftar_bayar_keranjang.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class KeranjangScreen extends StatefulWidget {
  const KeranjangScreen({super.key});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  final formatCurrency = NumberFormat("#,###", "id_ID");

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
                        height: screenHeight * 0.03,
                        width: screenHeight * 0.03,
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
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: items.length,
                                        itemBuilder: (context, index) {
                                          String namaBarang =
                                              items[index]["nama"];

                                          double screenWidth =
                                              MediaQuery.of(context).size.width;

                                          if (screenWidth < 600) {
                                            // Jika layar kecil (mobile)
                                            namaBarang = namaBarang
                                                .replaceAll(
                                                    RegExp(r'kitchen',
                                                        caseSensitive: false),
                                                    "")
                                                .trim();
                                          }

                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    screenWidth > 600 ? 20 : 8,
                                                vertical:
                                                    5), // ✅ Padding dinamis
                                            child: Card(
                                              color: Color(0xFFD5D5D5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: ListTile(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: screenWidth > 600
                                                      ? 15
                                                      : 5, // ✅ Padding lebih besar di tablet
                                                  vertical: screenWidth > 600
                                                      ? 12
                                                      : 2, // ✅ Tambah tinggi di tablet
                                                ),
                                                leading: Text(
                                                  "${index + 1}.",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: screenWidth > 600
                                                        ? 18
                                                        : 14, // ✅ Ukuran teks lebih besar di tablet
                                                  ),
                                                ),
                                                title: Text(
                                                  namaBarang,
                                                  style: TextStyle(
                                                      fontSize:
                                                          screenWidth > 600
                                                              ? 18
                                                              : 14),
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
                                                        fontSize: screenWidth >
                                                                600
                                                            ? 18
                                                            : 14, // ✅ Ukuran teks harga lebih besar
                                                        color:
                                                            Color(0xFFFF5252),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            12), // ✅ Jarak lebih besar untuk tablet
                                                    GestureDetector(
                                                      onTap: () {
                                                        String itemKey =
                                                            items[index]["key"];
                                                        hapusItemKeranjang(
                                                            itemKey);
                                                      },
                                                      child: Icon(
                                                        Icons.close,
                                                        size: screenWidth > 600
                                                            ? 28
                                                            : 24, // ✅ Icon lebih besar untuk tablet
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
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
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 600
              ? 20
              : 12, // ✅ Padding lebih besar di tablet
          vertical: 16,
        ),
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

            double totalHarga =
                items.fold(0, (sum, item) => sum + item["harga"]);
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
                        fontSize: MediaQuery.of(context).size.width > 600
                            ? 25
                            : 14, // ✅ Ukuran teks lebih besar di tablet
                      ),
                    ),
                    Text(
                      jumlahItem.toString(),
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width > 600 ? 25 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Harga:",
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width > 600 ? 25: 14,
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
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width > 600
                      ? 55
                      : 45, // ✅ Tombol lebih tinggi di tablet
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Daftar_KeranjangScreen(),
                        ),
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
                        fontSize: MediaQuery.of(context).size.width > 600
                            ? 25
                            : 16, // ✅ Teks lebih besar di tablet
                        color: Colors.white,
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
