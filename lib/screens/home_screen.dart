import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ganesha_interior/backdrop/backdrop.dart';
import 'package:ganesha_interior/backdrop_tv/backdrop_tv.dart';
import 'package:ganesha_interior/kitchen_set/meja_island.dart';
import 'package:ganesha_interior/kitchen_set/minibar.dart';
import 'package:ganesha_interior/kitchen_set/tipe_L.dart';
import 'package:ganesha_interior/kitchen_set/tipe_U.dart';
import 'package:ganesha_interior/kitchen_set/tipe_straight.dart';
import 'package:ganesha_interior/lemari/lemari.dart';
import 'package:ganesha_interior/partisi/partisi.dart';
import 'package:ganesha_interior/setting/setting_screen.dart';
import 'package:ganesha_interior/table/meja_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
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
                    Text(
                      "Selamat Datang",
                      style: TextStyle(
                        color: Color(0xFFFF5252),
                        fontSize: MediaQuery.of(context).size.width < 600
                            ? MediaQuery.of(context).size.width * 0.045 // HP
                            : MediaQuery.of(context).size.width *
                                0.04, // Tablet // Responsive font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset(
                          "assets/images/keranjang_merah.png",
                          height: screenHeight * 0.035,
                          width: screenHeight * 0.035,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: screenHeight * 0.022,
                            height: screenHeight * 0.022,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5252),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
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
          Positioned(
            top: screenHeight * 0.098,
            left: screenWidth * 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Tipe_Straight()),
                );
              },
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: (screenWidth / 2) - 4,
                  height: screenHeight * 0.205,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Image.asset(
                          "assets/images/kitchen.jpg",
                          width: double.infinity,
                          height: screenHeight * 0.150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child:Padding(
                        padding: EdgeInsets.only(
                              left: (MediaQuery.of(context).size.width / 2) *
                                  0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Kitchen Set",
                              textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                            ),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.only(left: screenWidth * 0.1),
                              onSelected: (value) {
                                if (value == "Straight") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Tipe_Straight()),
                                  );
                                } else if (value == "Letter L") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Tipe_L()),
                                  );
                                } else if (value == "Letter U") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Tipe_U()),
                                  );
                                } else if (value == "Minibar") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Minibar()),
                                  );
                                } else if (value == "Meja Island") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const MejaIsland()),
                                  );
                                }
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: Colors.white,
                              elevation: 6,
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                  value: "Straight",
                                  child: Text(
                                    "Straight",
                                    style:
                                        TextStyle(fontSize: screenWidth * 0.03),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: "Letter L",
                                  child: Text(
                                    "Letter L",
                                    style:
                                        TextStyle(fontSize: screenWidth * 0.03),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: "Letter U",
                                  child: Text(
                                    "Letter U",
                                    style:
                                        TextStyle(fontSize: screenWidth * 0.03),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: "Minibar",
                                  child: Text(
                                    "Minibar",
                                    style:
                                        TextStyle(fontSize: screenWidth * 0.03),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: "Meja Island",
                                  child: Text(
                                    "Meja Island",
                                    style:
                                        TextStyle(fontSize: screenWidth * 0.03),
                                  ),
                                ),
                              ],
                              child: Image.asset(
                                "assets/images/more.png",
                                width: screenWidth * 0.06,
                                height: screenWidth * 0.06,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ),),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.098,
            left: (MediaQuery.of(context).size.width / 2) + 1,
            right: screenWidth * 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PartisiScreen()),
                );
              },
              child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    width: (MediaQuery.of(context).size.width / 2) - 4,
                    height: screenHeight * 0.205,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          child: Image.asset(
                            "assets/images/partisi.jpg",
                            width: double.infinity,
                            height: screenHeight * 0.150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: (MediaQuery.of(context).size.width / 2) *
                                  0.1),
                          child: Text(
                            "Partisi",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                      ],
                    ),
                  )),
            ),
          ),
          Positioned(
            top: screenHeight * 0.311,
            left: screenWidth * 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BackdropTV()),
                );
              },
              child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    width: (MediaQuery.of(context).size.width / 2) - 4,
                    height: screenHeight * 0.22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          child: Image.asset(
                            "assets/images/backdrop_tv.jpg",
                            width: double.infinity,
                            height: screenHeight * 0.169,
                            fit: BoxFit.cover,
                          ),
                        ),
                       Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: (MediaQuery.of(context).size.width / 2) *
                                  0.1),
                          child: Text(
                            "Backdrop TV",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                      ],
                    ),
                  )),
            ),
          ),
          Positioned(
            top: screenHeight * 0.311,
            right: screenWidth * 0,
            left: (MediaQuery.of(context).size.width / 2) + 1,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LemariScreen()),
                );
              },
              child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    width: (MediaQuery.of(context).size.width / 2) - 4,
                    height: screenHeight * 0.22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          child: Image.asset(
                            "assets/images/lemari.png",
                            width: double.infinity,
                            height: screenHeight * 0.169,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: (MediaQuery.of(context).size.width / 2) *
                                  0.1),
                          child: Text(
                            "Lemari",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                      ],
                    ),
                  )),
            ),
          ),
          Positioned(
            top: screenHeight * 0.538,
            left: screenWidth * 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Backdrop()),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: (MediaQuery.of(context).size.width / 2) - 4,
                  height: screenHeight * 0.22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Image.asset(
                          "assets/images/backdrop2.jpg",
                          width: double.infinity,
                          height: screenHeight * 0.169,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: (MediaQuery.of(context).size.width / 2) *
                                  0.1),
                          child: Text(
                            "Backdrop",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.538,
            right: screenWidth * 0,
            left: (MediaQuery.of(context).size.width / 2) + 1,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MejaScreen()),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                    width: (MediaQuery.of(context).size.width / 2) - 4,
                    height: screenHeight * 0.22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          child: Image.asset(
                            "assets/images/meja1.jpg",
                            width: double.infinity,
                            height: screenHeight * 0.169,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: (MediaQuery.of(context).size.width / 2) *
                                  0.1),
                          child: Text(
                            "Meja Rias",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                      ],
                    )),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.764,
            left: screenWidth * 0,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: (MediaQuery.of(context).size.width / 2) - 4,
                height: screenHeight * 0.223,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/images/custom.webp",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: (MediaQuery.of(context).size.width / 2) *
                                  0.1),
                          child: Text(
                            "Custom",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.764,
            left: (MediaQuery.of(context).size.width / 2) + 4,
            right: screenWidth * 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingScreen()),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: (MediaQuery.of(context).size.width / 2) - 4,
                  height: screenHeight * 0.223,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            "assets/images/setting.jpg",
                            width: double.infinity,
                            height: screenHeight * 0.169,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: (MediaQuery.of(context).size.width / 2) *
                                    0.1),
                            child: Text(
                              "Setting",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.035,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
