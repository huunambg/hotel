import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/screen/admin/add_personnel.dart';
import '/screen/admin/update_personnel.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class FacilityDetailPersonnel extends StatefulWidget {
  const FacilityDetailPersonnel({super.key, required this.facilitiName});
  final String facilitiName;

  @override
  State<FacilityDetailPersonnel> createState() =>
      _FacilityDetailPersonnelState();
}

class _FacilityDetailPersonnelState extends State<FacilityDetailPersonnel> {
  FirebaseFirestore personnelColection = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPersonnel(
                        facilityId: widget.facilitiName,
                      ),
                    ));
              },
              icon: const Icon(Icons.add))
        ],
        title: const Text("Danh sách nhân viên"),
      ),
      body: StreamBuilder(
        stream: personnelColection
            .collection("Personnel")
            .where('facility_id', isEqualTo: widget.facilitiName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<dynamic> personnels = snapshot.data!.docs;
            //  print(personnels);
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: personnels.length,
              itemBuilder: (context, index) {
                var personnel = personnels[index];
                return InkWell(
                  onLongPress: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("THông báo"),
                              content:
                                  const Text("Mời bạn chọn chức năng phòng"),
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
                                              .collection("Personnel")
                                              .doc(personnel.id)
                                              .delete();
                                          CherryToast.success(
                                            title: const Text(
                                                "Xóa nhân viên thành công"),
                                            // ignore: use_build_context_synchronously
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
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            const SizedBox(width: 10),
                            const Text("Thông báo",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        content: const Text(
                          "Mời bạn chọn thuê phòng",
                          style: TextStyle(fontSize: 16),
                        ),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => AddBillHour(personnel: personnel),
                              //     ));
                            },
                            child: const Text(
                              "Theo giờ",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => AddBillDay(personnel: personnel),
                              //     ));
                            },
                            child: const Text(
                              "Theo ngày",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Quay lại",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
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
                              height: h * 0.14,
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
                          padding:
                              const EdgeInsets.only(top: 8, left: 8, right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text("Họ tên:  ",
                                      style: TextStyle(fontSize: 12)),
                                  Text(personnel['user_name'],
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
                              )
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
