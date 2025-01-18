import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class UpdateBillScreen extends StatefulWidget {
  const UpdateBillScreen({super.key, required this.bill});
  final dynamic bill;
  @override
  State<UpdateBillScreen> createState() => _UpdateBillScreenState();
}

class _UpdateBillScreenState extends State<UpdateBillScreen> {
  FirebaseFirestore billColection = FirebaseFirestore.instance;
  bool isPaid = false;
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Hóa đơn"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tên khách hàng: "),
                Text(widget.bill['custommer_name'],
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold))
              ],
            ),
            const SizedBox(
              height: 24.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Thuê theo: "),
                widget.bill['is_rent_hour']
                    ? const Text("Giờ",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold))
                    : const Text("Ngày",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold))
              ],
            ),
            SizedBox(
              height: 24.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Bắt đầu: "),
                Text(
                    DateFormat('HH:mm - dd/MM/yyyy')
                        .format(DateTime.parse(widget.bill['start_day'])),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold))
              ],
            ),
            SizedBox(
              height: 24.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Kết thúc: "),
                Text(
                    DateFormat('HH:mm - dd/MM/yyyy')
                        .format(DateTime.parse(widget.bill['end_day'])),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold))
              ],
            ),
            SizedBox(
              height: 24.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.bill['is_rent_hour']
                    ? Row(
                        children: [
                          const Text("Giá theo giờ: "),
                          Text(convertMoney(widget.bill['price_on_hour']),
                              // ignore: prefer_const_constructors
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : Row(
                        children: [
                          const Text("Giá theo ngày: "),
                          Text(convertMoney(widget.bill['price_on_day']),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      )
              ],
            ),
            SizedBox(
              height: 24.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.bill['is_rent_hour']
                    ? Row(
                        children: [
                          const Text("Tổng số giờ: "),
                          Text(widget.bill['hour_number'].toString(),
                              // ignore: prefer_const_constructors
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : Row(
                        children: [
                          const Text("Tổng số ngày: "),
                          Text(widget.bill['day_number'].toString(),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      )
              ],
            ),
            SizedBox(
              height: 24.0,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tổng tiền phải chả: "),
                Text(convertMoney(widget.bill['total_money']),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                widget.bill['is_paid'] == false
                    ? GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: AspectRatio(
                                aspectRatio: 600 / 776,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                          "https://img.vietqr.io/image/vietinbank-107872416964-print.jpg?amount=${widget.bill['total_money']}&addInfo=${widget.bill['custommer_name']} thanh toan tien phong ${widget.bill['room_number']}&accountName=Nong Huu Nam"),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            icon: const Icon(Icons.close)),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "QR thanh toán",
                          style: TextStyle(color: Colors.blue),
                        ))
                    : const SizedBox.shrink()
              ],
            ),
            const SizedBox(
              height: 24.0,
            ),
            widget.bill['is_paid']
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Thanh toán: "),
                    Text("Đã thanh toán",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green))
                  ])
                : Row(
                    children: [
                      const Text("Đã thanh toán"),
                      const Gap(20),
                      FlutterSwitch(
                        activeText: "Ok",
                        inactiveText: "Chưa",
                        width: 125.0,
                        height: 55.0,
                        valueFontSize: 20.0,
                        toggleSize: 45.0,
                        value: isPaid,
                        borderRadius: 30.0,
                        padding: 8.0,
                        showOnOff: true,
                        onToggle: (val) {
                          setState(() {
                            isPaid = val;
                          });
                        },
                      ),
                    ],
                  ),
            const Gap(10),
            widget.bill['is_paid'] == false
                ? MaterialButton(
                    height: 45,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Colors.blueAccent,
                    minWidth: w * 0.85,
                    onPressed: () async {
                      await billColection
                          .collection("Bill")
                          .doc(widget.bill.id)
                          .update({
                        "is_paid": isPaid,
                      });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cập nhật hóa đơn",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  String convertMoney(int money) {
    return "${NumberFormat.decimalPattern('vi').format(money)}đ";
  }
}
