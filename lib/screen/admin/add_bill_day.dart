import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class AddBillDay extends StatefulWidget {
  const AddBillDay({super.key, required this.room});
  final dynamic room;

  @override
  State<AddBillDay> createState() => _AddBillDayState();
}

class _AddBillDayState extends State<AddBillDay> {
  final cusstomerNameController = TextEditingController();
  bool isPaid = false;
  final phoneNumberController = TextEditingController();
  final startDayController = TextEditingController();
  final endDayController = TextEditingController();
  final numeDayMoneyController = TextEditingController();
  FirebaseFirestore billColection = FirebaseFirestore.instance;
  String endDay = "";
  String startDay = "";
  String totalMoneyTemp = "0";
  var totalMoney = "0";
  String priceDay = "0";
  void load() {
    // priceDayController.text = widget.room['price_on_day'].toString();
    priceDay = widget.room['price_on_day'].toString();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    // double h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Phòng ${widget.room['room_number']}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.text,
              controller: cusstomerNameController,
              decoration: InputDecoration(
                  labelText: 'Tên khách hàng',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const Gap(10),
            TextFormField(
              keyboardType: TextInputType.phone,
              controller: phoneNumberController,
              decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const Gap(10),
            Row(
              children: [
                const Text("Giá phòng theo ngày: "),
                Text(
                  convertMoney(int.parse(priceDay)),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                )
              ],
            ),
            const Gap(10),
            TextFormField(
              onChanged: (value) {
                try {
                  if (numeDayMoneyController.text.isNotEmpty) {
                    setState(() {
                      totalMoney = (int.parse(numeDayMoneyController.text) *
                              widget.room['price_on_day'])
                          .toString();

                      totalMoneyTemp = convertMoney(int.parse(totalMoney));
                    });
                  } else {
                    setState(() {
                      totalMoney = "0";
                      totalMoneyTemp = totalMoney;
                    });
                  }
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
              keyboardType: TextInputType.number,
              controller: numeDayMoneyController,
              decoration: InputDecoration(
                  labelText: 'Số ngày thuê',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const Gap(10),
            TextFormField(
              readOnly: true,
              keyboardType: TextInputType.number,
              controller: startDayController,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                      onPressed: () {
                        if (numeDayMoneyController.text.isNotEmpty) {
                          picker.DatePicker.showDateTimePicker(context,
                              showTitleActions: true,
                              minTime: DateTime.now(),
                              maxTime:
                                  DateTime.now().add(const Duration(days: 61)),
                              onChanged: (date) {
                            debugPrint('change $date');
                            setState(() {
                              startDay = date.toString();
                              startDayController.text =
                                  DateFormat('HH:mm - dd/MM/yyyy').format(date);
                              if (numeDayMoneyController.text != "") {
                                endDay = date
                                    .add(Duration(
                                        hours: int.parse(
                                            numeDayMoneyController.text)))
                                    .toString();
                                endDayController.text =
                                    DateFormat('HH:mm - dd/MM/yyyy').format(
                                        date.add(Duration(
                                            hours: int.parse(
                                                numeDayMoneyController.text))));
                              }
                            });
                          }, onConfirm: (date) {
                            debugPrint('confirm $date');
                          },
                              currentTime: DateTime.now(),
                              locale: picker.LocaleType.vi);
                        } else {
                          CherryToast.warning(
                            title:
                                const Text("Vui lòng nhập số giờ thuê trước"),
                          ).show(context);
                        }
                      },
                      icon: const Icon(Icons.calendar_month)),
                  labelText: 'Ngày bắt đấu',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const Gap(10),
            TextFormField(
              readOnly: true,
              controller: endDayController,
              decoration: InputDecoration(
                  labelText: 'Ngày kết thúc',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const Gap(10),
            Row(children: [
              const Text("Tổng số tiền: "),
              Text(
                convertMoney(
                  int.parse(totalMoney),
                ),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 16),
              ),
              const Spacer(),
              int.parse(totalMoney) > 0
                  ? TextButton(
                      onPressed: () {
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
                                        "https://img.vietqr.io/image/vietinbank-107872416964-print.jpg?amount=$totalMoney&addInfo=Thanh toan tien phong ${widget.room['room_number']}&accountName=Nong Huu Nam"),
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
            ]),
            int.parse(totalMoney) > 0
                ? Row(
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
                  )
                : const SizedBox.shrink(),
            const Gap(10),
            int.parse(totalMoney) > 0 && startDayController.text.isNotEmpty
                ? MaterialButton(
                    height: 45,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Colors.blueAccent,
                    minWidth: w * 0.85,
                    onPressed: () async {
                      Map<String, dynamic> data = {
                        "custommer_name": cusstomerNameController.text,
                        "day_number": int.parse(numeDayMoneyController.text),
                        "hour_number": 0,
                        "end_day": endDay,
                        "price_on_day": widget.room['price_on_day'],
                        "price_on_hour": 0,
                        "is_paid": isPaid,
                        "is_rent_hour": false,
                        "phone_number": phoneNumberController.text,
                        "room_id": widget.room.id,
                        "room_number": widget.room['room_number'],
                        "start_day": startDay,
                        "total_money": int.parse(totalMoney),
                        "facility_id": widget.room['facility_id'],
                        "create_at": DateTime.now()
                      };
                      await billColection.collection("Bill").add(data);
                      setState(() {
                        cusstomerNameController.clear();
                        phoneNumberController.clear();
                        numeDayMoneyController.clear();
                        startDayController.clear();
                        endDayController.clear();
                        endDay = "";
                        startDay = "";
                        totalMoney = "0";
                        totalMoneyTemp = "$totalMoneyđ";
                        isPaid = false;
                      });
                      CherryToast.success(
                        title: const Text("Tạo hóa đơn thành công"),
                        // ignore: use_build_context_synchronously
                      ).show(context);
                    },
                    child: const Text(
                      "Tạo hóa đơn",
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
