import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ganesha_interior/screens/home_screen.dart';

class Backdrop extends StatefulWidget {
  const Backdrop({super.key});

  @override
  State<Backdrop> createState() => _BackdropState();
}

class _BackdropState extends State<Backdrop> {
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
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                        );
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
                      "Backdrop",
                      style: TextStyle(
                        color: Color(0xFFFF5252),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
  }
}
