import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:gap/gap.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class UpdatePersonnel extends StatefulWidget {
  const UpdatePersonnel({super.key, required this.personnel});
  final dynamic personnel;

  @override
  State<UpdatePersonnel> createState() => _UpdatePersonnelState();
}

class _UpdatePersonnelState extends State<UpdatePersonnel> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phonNumberController = TextEditingController();
  final TextEditingController dateBirthController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
    final TextEditingController roomController = TextEditingController();
  FirebaseFirestore roomColection = FirebaseFirestore.instance;
  bool sex = false;
  DateTime? dateTimeSelect = DateTime.utc(2024, 1, 1);
  final List<String> _listRoom = [
    '',
  ];
  final List<String> _listRoomInit = [
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    // double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sửa thông tin nhân viên"),
      ),
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
            TextFormField(
              controller: roomController,
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                      onPressed: () async {
                        await showModalBottomSheet(
                          isScrollControlled:
                              true, // required for min/max child size
                          context: context,
                          builder: (ctx) {
                            return MultiSelectBottomSheet(
                              confirmText: const Text("Lưu"),
                              cancelText:const Text("Quay lại"),
                              title: const Text("Chọn phòng"),
                              items: _listRoom
                                  .map((r) => MultiSelectItem<String>(r, r))
                                  .toList(),
                              initialValue: _listRoomInit,
                              onConfirm: (values) {print("data $values");
                       
                                String temp = "";
                               for(int i=0 ;i <values.length ;i++){
                                  if(i==0){
                                    temp= values[i];
                                  }else{
                                    temp+= ",${values[i]}";
                                  }
                               }
                                setState(() {
                                  roomController.text = temp;
                                });

                              
                              
                              },
                              maxChildSize: 0.8,
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.room_preferences_rounded)),
                  labelText: 'Danh sách phòng ',
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
                await roomColection
                    .collection("User")
                    .doc(widget.personnel.id)
                    .update({
                  "facility_id": widget.personnel['facility_id'],
                  "username": nameController.text,
                  "phone_number": phonNumberController.text,
                  "date_birth": dateTimeSelect.toString(),
                  "address": addressController.text,
                  "sex": sex,
                  "list_room": roomController.text
                });
                setState(() {
                  nameController.clear();
                  phonNumberController.clear();
                  dateBirthController.clear();
                  addressController.clear();
                  sex = false;
                });
                CherryToast.success(
                  title: const Text("Sửa thông tin thành công"),
                  // ignore: use_build_context_synchronously
                ).show(context);
              },
              child: const Text(
                "Sửa thông tin",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> loadData() async {
    nameController.text = widget.personnel['username'];
    phonNumberController.text = widget.personnel['phone_number'];
    dateBirthController.text = DateFormat('dd/MM/yyyy')
        .format(DateTime.parse(widget.personnel['date_birth']));
    addressController.text = widget.personnel['address'];
    roomController.text = widget.personnel['list_room'];
    sex = widget.personnel['sex'];
    dateTimeSelect = DateTime.parse(widget.personnel['date_birth']);

    await FirebaseFirestore.instance
        .collection("Room")
        .where("facility_id", isEqualTo: widget.personnel['facility_id'])
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        _listRoom.add(doc['room_number'].toString());
      }
    }).catchError((error) {
      //    print('Error getting documents: $error');
    });
    _listRoom.removeAt(0);
    setState(() {});
  }
}
