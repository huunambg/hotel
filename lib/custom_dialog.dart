import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomDialog {
late BuildContext context;
double? h;
CustomDialog(this.context,this.h);

void errorWifiDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: h! * 0.35,
            child: Column(
              children: [
                Lottie.asset("assets/lottie/wifierror.json"),
                const Text("Wifi không hợp lệ!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Thoát'),
            ),
          ],
        );
      },
    );
  }

  void errorWifiDistanceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: h! * 0.4,
            child: Column(
              children: [
                Lottie.asset("assets/lottie/sad.json"),
                const Text("Vị trí và wifi của bạn không hợp lệ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Thoát'),
            ),
          ],
        );
      },
    );
  }

  void errorDistanceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: h! * 0.4,
            child: Column(
              children: [
                Lottie.asset("assets/lottie/sad.json"),
                const Text("Bạn không ở vị trí của công ty",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Thoát'),
            ),
          ],
        );
      },
    );
  }

   void loadingDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            height: 250,
            child: Center(
              child:Lottie.asset("assets/lottie/load.json",height: 150),
            ),
          ),
          
        );
      },
    );
  }

}