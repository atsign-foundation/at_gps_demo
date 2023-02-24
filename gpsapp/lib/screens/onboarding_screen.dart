import 'package:flutter/material.dart';


import 'package:gpsapp/widgets/onboarding_dialog.dart';

class OnboardingScreen extends StatelessWidget {
  static const String id = '/onboarding';
  const OnboardingScreen({Key? key}) : super(key: key);

  
  @override
  Widget build(BuildContext context) {
        double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
        int gridRows = 1;
    if (width > height) {
      gridRows = 2;
    } else {
      gridRows = 1;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
    decoration: BoxDecoration(
          color: Colors.white70,
          gradient: gridRows > 1
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 78, 173, 80),
                    Color.fromARGB(255, 171, 200, 224)
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 78, 173, 80),
                    Color.fromARGB(255, 171, 200, 224)
                  ],
                ),
        ),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Text(
              "atGPS",
              style: TextStyle(
                  fontSize: 38,
                  letterSpacing: 5,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            OnboardingDialog()
          ],
        )),
      ),
    );
  }
}
