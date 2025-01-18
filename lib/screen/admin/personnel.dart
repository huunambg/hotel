import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/screen/admin/rollcall_personnel_screen.dart';
import '/screen/admin/update_personnel.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class PersonnelScreen extends StatefulWidget {
  const PersonnelScreen({super.key});
  @override
  State<PersonnelScreen> createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> {
  FirebaseFirestore personnelColection = FirebaseFirestore.instance;
  FirebaseFirestore facilityColection = FirebaseFirestore.instance;
  final seachController = TextEditingController();
  List<dynamic> listFacility = [];
  bool iSearch = false;
  late Stream stream;

  Future<void> loadData() async {
    await facilityColection
        .collection("Facility")
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        listFacility.add(doc);
      }
    }).catchError((error) {
      print('Error getting documents: $error');
    });
    setState(() {});
  }

  String getNumber(String id) {
    for (var item in listFacility) {
      if (item.id == id) {
        return item['number'];
      }
    }
    return "Không có";
  }

  @override
  void initState() {
    super.initState();
    loadData();
    stream = personnelColection
        .collection("User")
        .where('role', isEqualTo: "user")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Danh sách nhân viên"),
        actions: [
          IconButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Tìm kiếm"),
                      content: TextField(
                        controller: seachController, // Sử dụng seachController
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Quay lại")),
                        TextButton(
                            onPressed: () {
                              iSearch = true;
                              Navigator.pop(context);
                            },
                            child: const Text("Tìm kiếm"))
                      ],
                    );
                  },
                );

                if (iSearch) {
                  if (seachController.text.isEmpty) {
                    setState(() {
                      stream = personnelColection
                          .collection("User")
                          .where('role', isEqualTo: "user")
                          .snapshots();
                      iSearch = false; // Đặt lại iSearch về false
                    });
                  } else {
                    setState(() {
                      stream = personnelColection
                          .collection("User")
                          .where('role', isEqualTo: "user")
                          .where('username', isEqualTo: seachController.text)
                          .snapshots();
                      iSearch = false; // Đặt lại iSearch về false
                    });
                  }
                  seachController.clear(); // Xóa nội dung của seachController
                }
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<dynamic> personnels = snapshot.data!.docs;
            personnels = personnels.reversed.toList();
            if (personnels.length > 0) {
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: personnels.length,
                itemBuilder: (context, index) {
                  var personnel = personnels[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RollcallPersonnelScreen(personnel: personnel),
                          ));
                    },
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text("THông báo"),
                                content: const Text("Mời bạn chọn chức năng"),
                                actions: <Widget>[
                                  TextButton(
                                      child: const Text("Xóa"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        AwesomeDialog(
                                          btnOkText: "Có",
                                          btnCancelText: "Quay lại",
                                          context: context,
                                          dialogType: DialogType.info,
                                          animType: AnimType.rightSlide,
                                          title: 'Thông báo',
                                          desc: 'Bạn có muốn xóa nhân viên ',
                                          btnCancelOnPress: () {},
                                          btnOkOnPress: () async {
                                            await personnelColection
                                                .collection("User")
                                                .doc(personnel.id)
                                                .delete();
                                            CherryToast.success(
                                              title: const Text(
                                                  "Xóa nhân viên thành công"),
                                            ).show(context);
                                          },
                                        ).show();
                                      }),
                                  TextButton(
                                      child: const Text("Sửa"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdatePersonnel(
                                                        personnel: personnel)));
                                      }),
                                  TextButton(
                                      child: const Text("Quay lại"),
                                      onPressed: () => Navigator.pop(context)),
                                ],
                              ));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: h * 0.18,
                                width: w * 0.2,
                                decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10))),
                                child: Text(
                                  (index + 1).toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8, left: 8, right: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("Họ tên:  ",
                                        style: TextStyle(fontSize: 12)),
                                    Text(personnel['username'],
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Số điện thoại:  ",
                                        style: TextStyle(fontSize: 12)),
                                    Text((personnel['phone_number']),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Ngày sinh:  ",
                                        style: TextStyle(fontSize: 12)),
                                    Text(
                                        DateFormat('dd/MM/yyyy').format(
                                            DateTime.parse(
                                                personnel['date_birth'])),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Giới tính:  ",
                                        style: TextStyle(fontSize: 12)),
                                    personnel['sex']
                                        ? const Center(
                                            child: Text(
                                            "Nam",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold),
                                          ))
                                        : const Center(
                                            child: Text(
                                            "Nữ",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold),
                                          )),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Cơ sở:  ",
                                        style: TextStyle(fontSize: 12)),
                                    Text(getNumber(personnel['facility_id']),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Quản lý phòng:  ",
                                        style: TextStyle(fontSize: 12)),
                                    Text(personnel['list_room'],
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: (const Text("Không có nhân viên trên")),
              );
            }
          } else {
            return Center(
                child: Lottie.asset("assets/lottie/loading.json",
                    width: 120, height: 120));
          }
        },
      ),
    );
  }

  String convertMoney(int money) {
    return "${NumberFormat.decimalPattern('vi').format(money)}đ";
  }

  Widget textFieldBill(
      TextEditingController controller, String label, TextInputType type) {
    return TextField(
      keyboardType: type,
      controller: controller,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          labelText: label),
    );
  }
}
