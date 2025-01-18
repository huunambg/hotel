import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:slider_button/slider_button.dart';

class CustomSlideButton extends StatefulWidget {
  final Future<bool?> Function() action;
  const CustomSlideButton({super.key, required this.action});

  @override
  State<CustomSlideButton> createState() => _CustomSlideButtonState();
}

class _CustomSlideButtonState extends State<CustomSlideButton> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return SliderButton(
      radius: 15,
      buttonSize: 55,
      alignLabel: const Alignment(0.4, 0),
      backgroundColor: const Color(0xFF3085FE),
      boxShadow: const BoxShadow(
        color: Colors.black26,
        blurRadius: 2,
        offset: Offset(1, 1),
      ),
      width: w * 0.95,
      action: widget.action,
      label: const Text(
        "Trượt để điểm danh !",
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w500, fontSize: 17),
      ),
      icon: const Center(
          child: Icon(
        Ionicons.arrow_forward_outline,
        color: Color.fromARGB(255, 62, 132, 223),
        size: 30.0,
      )),
    );
  }
}
