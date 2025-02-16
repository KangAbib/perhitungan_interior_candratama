import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ganesha_interior/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class Tipe_Straight extends StatefulWidget {
  const Tipe_Straight({super.key});

  @override
  State<Tipe_Straight> createState() => _Tipe_StraightState();
}

class _Tipe_StraightState extends State<Tipe_Straight> {
  TextEditingController hargaAtasController = TextEditingController(text: "Rp ");
  TextEditingController hargaBawahController = TextEditingController(text: "Rp ");
  TextEditingController hasilJumlahController =
      TextEditingController(text: "Rp ");
  TextEditingController topTableController = TextEditingController(text: "Rp ");
  TextEditingController backsplashController =
      TextEditingController(text: "Rp ");
  TextEditingController aksesorisController =
      TextEditingController(text: "Rp ");
  TextEditingController uangMukaController = TextEditingController(text: "Rp ");
  double _scale = 1.0;
  double _opacity = 1.0;

  @override
  void dispose() {
    hargaAtasController.dispose();
    hargaBawahController.dispose();
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
  }

  void formatInput(TextEditingController controller, String value) {
    if (!value.startsWith("Rp ")) {
      controller.value = TextEditingValue(
        text: "Rp ${value.replaceAll(RegExp(r'[^0-9]'), '')}",
        selection: TextSelection.collapsed(offset: controller.text.length),
      );
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.9;
      _opacity = 0.7;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
      _opacity = 1.0;
    });
    _navigateBack();
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
      _opacity = 1.0;
    });
  }

  void _navigateBack() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
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
                          onTapDown: _onTapDown,
                          onTapUp: _onTapUp,
                          onTapCancel: _onTapCancel,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            transform: Matrix4.identity()..scale(_scale),
                            child: Opacity(
                              opacity: _opacity,
                              child: Image.asset(
                                "assets/images/back.png",
                                height: screenHeight * 0.03,
                                width: screenHeight * 0.03,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Kitchen Set",
                          style: TextStyle(
                            color: Color(0xFFFF5252),
                            fontSize: MediaQuery.of(context).size.width * 0.04,
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
                                        fontSize: screenWidth * 0.05,
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
                                    style: GoogleFonts.manrope(
                                      fontSize: screenWidth *
                                          0.04, // Sesuaikan ukuran font
                                      fontWeight: FontWeight.w400, // Regular
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
                                    style: GoogleFonts.manrope(
                                      fontSize: screenWidth *
                                          0.04, // Sesuaikan ukuran font
                                      fontWeight: FontWeight.w400, // Regular
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
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 22,
                                                        horizontal: 12),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(height: 40),
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
                                              style: GoogleFonts.manrope(
                                                fontSize: screenWidth *
                                                    0.04, // Sesuaikan ukuran font
                                                fontWeight:
                                                    FontWeight.w400, // Regular
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
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                String angkaOnly =
                                                    value.replaceAll(
                                                        RegExp(r'[^0-9]'), '');
                                                hargaAtasController.value =
                                                    TextEditingValue(
                                                  text: "Rp $angkaOnly",
                                                  selection:
                                                      TextSelection.collapsed(
                                                          offset:
                                                              "Rp $angkaOnly"
                                                                  .length),
                                                );
                                              },
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
                                              controller: hasilJumlahController,
                                              style: GoogleFonts.manrope(
                                                fontSize: screenWidth *
                                                    0.04, // Sesuaikan ukuran font
                                                fontWeight:
                                                    FontWeight.w400, // Regular
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
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) => formatInput(
                                                  hasilJumlahController, value),
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
                                                      0.001),
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
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical: 22,
                                                        horizontal: 12),
                
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(height: 40),
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
                                                    0.033,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            TextField(
                                              controller: hargaBawahController,
                                              style: GoogleFonts.manrope(
                                                fontSize: screenWidth *
                                                    0.04, // Sesuaikan ukuran font
                                                fontWeight:
                                                    FontWeight.w400, // Regular
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
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                if (!value.startsWith("Rp ")) {
                                                  hargaBawahController.value =
                                                      TextEditingValue(
                                                    text:
                                                        "Rp ${value.replaceAll(RegExp(r'[^0-9]'), '')}",
                                                    selection:
                                                        TextSelection.collapsed(
                                                            offset:
                                                                hargaBawahController
                                                                    .text
                                                                    .length),
                                                  );
                                                }
                                              },
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
                                              controller: hasilJumlahController,
                                              style: GoogleFonts.manrope(
                                                fontSize: screenWidth *
                                                    0.04, // Sesuaikan ukuran font
                                                fontWeight:
                                                    FontWeight.w400, // Regular
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
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) => formatInput(
                                                  hasilJumlahController, value),
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
                                      fontSize: screenWidth *
                                          0.04, // Sesuaikan ukuran font
                                      fontWeight: FontWeight.w400, // Regular
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 12), // Tambahkan di sini
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) =>
                                        formatInput(topTableController, value),
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
                                      fontSize: screenWidth *
                                          0.04, // Sesuaikan ukuran font
                                      fontWeight: FontWeight.w400, // Regular
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 12), // Tambahkan di sini
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) => formatInput(
                                        backsplashController, value),
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
                                      fontSize: screenWidth *
                                          0.04, // Sesuaikan ukuran font
                                      fontWeight: FontWeight.w400, // Regular
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 12), // Tambahkan di sini
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) =>
                                        formatInput(aksesorisController, value),
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
                                    style: GoogleFonts.manrope(
                                      fontSize: screenWidth *
                                          0.04, // Sesuaikan ukuran font
                                      fontWeight: FontWeight.w400, // Regular
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 12), // Tambahkan di sini
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) =>
                                        formatInput(uangMukaController, value),
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
          ),
        ],
      ),
    );
  }
}
