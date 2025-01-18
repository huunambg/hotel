import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:gap/gap.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:intl/intl.dart';

class AddPersonnel extends StatefulWidget {
  const AddPersonnel({super.key, required this.facilityId});
  final String facilityId;

  @override
  State<AddPersonnel> createState() => _AddPersonnelState();
}

class _AddPersonnelState extends State<AddPersonnel> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phonNumberController = TextEditingController();
  final TextEditingController dateBirthController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  FirebaseFirestore roomColection = FirebaseFirestore.instance;
  bool sex = false;
  DateTime? dateTimeSelect = DateTime.utc(2024,1,1);
  @override
  Widget build(BuildContext context) {
    // double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(centerTitle: true,title: const Text("Thêm nhân viên"),),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextFormField(
              keyboardType: TextInputType.number,
              controller: nameController,
              decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const Gap(20),
            Row(
              children: [
                const Text("Giới tính"),
                const Gap(20),
                FlutterSwitch(
                  inactiveColor: Colors.purple,
                  activeText: "Nam",
                  inactiveText: "Nữ",
                  width: 125.0,
                  height: 55.0,
                  valueFontSize: 20.0,
                  toggleSize: 45.0,
                  value: sex,
                  borderRadius: 30.0,
                  padding: 8.0,
                  showOnOff: true,
                  onToggle: (val) {
                    setState(() {
                      sex = val;
                    });
                  },
                ),
              ],
            ),
            const Gap(20),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: phonNumberController,
              decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const Gap(20),
            TextFormField(
              readOnly: true,
              controller: dateBirthController,
              decoration: InputDecoration(
                  labelText: 'Ngày sinh',
                  suffixIcon: IconButton(
                      onPressed: () {
                        picker.DatePicker.showDatePicker(context,
                            showTitleActions: true,
                            minTime: DateTime.utc(1980, 1, 1),
                            maxTime: DateTime.utc(2010, 12, 31),
                            onChanged: (date) {
                          debugPrint('change $date');
                        }, onConfirm: (date) {
                          setState(() {
                            dateBirthController.text =
                                DateFormat('dd/MM/yyyy').format(date);
                                dateTimeSelect = date;
                          });
                        },
                            currentTime: DateTime.now(),
                            locale: picker.LocaleType.vi);
                      },
                      icon: const Icon(Icons.calendar_month)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            const Gap(20),
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                  labelText: 'Địa chỉ',
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
                await roomColection.collection("Personnel").add({
                  "facility_id": widget.facilityId,
                  "user_name": nameController.text,
                  "phone_number": phonNumberController.text,
                  "date_birth": dateTimeSelect.toString(),
                  "address": addressController.text,
                  "sex": sex,
                  "list_room" : "Không có"
                });
                setState(() {
                  nameController.clear();
                  phonNumberController.clear();
                  dateBirthController.clear();
                  addressController.clear();
                  sex = false;
                });
                CherryToast.success(
                  title: const Text("Thêm nhân viên thành công"),
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
