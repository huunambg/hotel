import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ItemRecentActivity extends StatefulWidget {
  const ItemRecentActivity({super.key});

  @override
  State<ItemRecentActivity> createState() => _ItemRecentActivityState();
}

class _ItemRecentActivityState extends State<ItemRecentActivity> {
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      height: h * 0.07,
      width: double.infinity,
      decoration: BoxDecoration(boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 2,
          offset: Offset(1, 1), // Điều chỉnh hướng của bóng đổ
        ),
      ], color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 223, 222, 220),
                  borderRadius: BorderRadius.circular(5),
                ),
                height: 30,
                width: 30,
                child: const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: Colors.blue,
                ),
              ),
              const Gap(10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Check In",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("18/8/2024",
                      style: TextStyle(
                        color: Color.fromARGB(255, 85, 85, 84),
                      ))
                ],
              ),
            ],
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "08 : 20 : 30",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Giờ vào",
                  style: TextStyle(
                    color: Color.fromARGB(255, 85, 85, 84),
                  ))
            ],
          )
        ],
      ),
    );
  }
}
