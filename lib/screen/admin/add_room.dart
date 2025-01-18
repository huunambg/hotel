import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:gap/gap.dart';

class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({super.key, required this.facilityId});
  final String facilityId;

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final TextEditingController numberController = TextEditingController();
  final TextEditingController priceDayController = TextEditingController();
  final TextEditingController piceHourController = TextEditingController();
  FirebaseFirestore roomColection = FirebaseFirestore.instance;
  bool isVip = false;
  @override
  Widget build(BuildContext context) {
   // double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.number,
              controller: numberController,
              decoration: InputDecoration(
                  labelText: 'Số phòng',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const Gap(20),
            Row(
              children: [
                const Text("Phòng vip"),
                const Gap(20),
                FlutterSwitch(
                  activeText: "Có",
                  inactiveText: "Không",
                  width: 125.0,
                  height: 55.0,
                  valueFontSize: 20.0,
                  toggleSize: 45.0,
                  value: isVip,
                  borderRadius: 30.0,
                  padding: 8.0,
                  showOnOff: true,
                  onToggle: (val) {
                    setState(() {
                      isVip = val;
                    });
                  },
                ),
              ],
            ),
            const Gap(20),
            TextFormField(
               keyboardType: TextInputType.number,
              controller: priceDayController,
              decoration: InputDecoration(
                  labelText: 'Giá phòng 1 ngày',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const Gap(20),
            TextFormField(
               keyboardType: TextInputType.number,
              controller: piceHourController,
              decoration: InputDecoration(
                  labelText: 'Giá theo giờ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const Gap(20),
            MaterialButton(
              height: 40,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.blueAccent,
              minWidth: w * 0.8,
              onPressed: () async {
                await roomColection.collection("Room").add({
                  "room_number": int.parse(numberController.text),
                  "facility_id": widget.facilityId,
                  "is_vip": isVip,
                  "price_on_day": int.parse(priceDayController.text),
                  "price_on_hour": int.parse(piceHourController.text)
                });
                setState(() {
                  numberController.clear();
                  priceDayController.clear();
                  piceHourController.clear();
                  isVip = false;
                });
                CherryToast.success(
                  title: const Text("Thêm phòng thành công"),
                // ignore: use_build_context_synchronously
                ).show(context);
              },
              child: const Text(
                "Thêm",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
