import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hotel/screen/admin/add_facility.dart';
import '/provider/user.dart';
import '/screen/admin/room.dart';
import '/screen/admin/update_facility.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({super.key});

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  FirebaseFirestore facilityCollection = FirebaseFirestore.instance;
  final addressController = TextEditingController();
  final nameController = TextEditingController();
  final numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final personnelProvider = Provider.of<UserProvider>(context, listen: false);
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: h * 0.07,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Khách sạn",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // showModalBottomSheet(
              //   shape: const RoundedRectangleBorder(
              //     borderRadius: BorderRadius.only(
              //       topLeft: Radius.circular(20),
              //       topRight: Radius.circular(20),
              //     ),
              //   ),
              //   context: context,
              //   builder: (context) => SingleChildScrollView(
              //     child: Padding(
              //       padding: const EdgeInsets.all(16.0),
              //       child: Column(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           Align(
              //             alignment: Alignment.centerRight,
              //             child: IconButton(
              //               onPressed: () {
              //                 Navigator.pop(context);
              //               },
              //               icon: const Icon(Icons.close),
              //             ),
              //           ),
              //           textFieldAdd(nameController, "Tên khách sạn",
              //               TextInputType.text),
              //           const Gap(10),
              //           textFieldAdd(
              //               addressController, "Địa chỉ", TextInputType.text),
              //           const Gap(10),
              //           textFieldAdd(
              //               numberController, "Cơ sở số", TextInputType.number),
              //           const Gap(20),
              //           ElevatedButton(
              //             onPressed: () {
              //               AwesomeDialog(
              //                 btnOkText: "Có",
              //                 btnCancelText: "Quay lại",
              //                 context: context,
              //                 dialogType: DialogType.info,
              //                 animType: AnimType.rightSlide,
              //                 title: 'Thông báo',
              //                 desc: 'Bạn có muốn thêm cơ sở',
              //                 btnCancelOnPress: () {},
              //                 btnOkOnPress: () async {
              //                   await facilityCollection
              //                       .collection("Facility")
              //                       .add({
              //                     "faciliti_name": nameController.text,
              //                     "address": addressController.text,
              //                     "number": numberController.text,
              //                     "user_id": personnelProvider.getUserId()
              //                   });
              //                   setState(() {
              //                     nameController.clear();
              //                     addressController.clear();
              //                     numberController.clear();
              //                   });
              //                   CherryToast.success(
              //                     title: const Text("Thêm cơ sở thành công"),
              //                   ).show(context);
              //                 },
              //               ).show();
              //             },
              //             style: ElevatedButton.styleFrom(
              //               minimumSize: Size(w * 0.9, 50),
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(15),
              //               ),
              //             ),
              //             child: const Text(
              //               "Thêm cơ sở",
              //               style: TextStyle(
              //                   fontSize: 16, fontWeight: FontWeight.bold),
              //             ),
              //           )
              //         ],
              //       ),
              //     ),
              //   ),
              // );
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddFacilityScreen(),
                  ));
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: StreamBuilder(
        stream: facilityCollection
            .collection("Facility")
            .orderBy("number", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var facilities = snapshot.data!.docs;
            if (facilities.isNotEmpty) {
              return ListView.builder(
                itemCount: facilities.length,
                padding: const EdgeInsets.all(8.0),
                itemBuilder: (context, index) {
                  var facility = facilities[index];
                  return GestureDetector(
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text("Thông báo"),
                                content: const Text("Mời bạn chọn chức năng"),
                                actions: <Widget>[
                                  TextButton(
                                      child: const Text("Quay lại"),
                                      onPressed: () => Navigator.pop(context)),
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
                                          desc: 'Bạn có muốn xóa cơ sở ',
                                          btnCancelOnPress: () {},
                                          btnOkOnPress: () async {
                                            await facilityCollection
                                                .collection("Facility")
                                                .doc(facility.id)
                                                .delete();
                                            CherryToast.success(
                                              title: const Text(
                                                  "Xóa cơ sở thành công"),
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
                                                  UpdateFacility(
                                                      facility: facility),
                                            ));
                                      }),
                                ],
                              ));
                    },
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoomScreen(
                              facilitiId: facility.id,
                            ),
                          ));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: Image.asset(
                              "assets/images/hotel_${(index % 5) + 1}.png",
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  facility['faciliti_name'],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  facility['address'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text("Cơ sở số: "),
                                    Text(
                                      facility['number'].toString(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
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
              return const Center(
                child: Text(
                  "Chưa có cơ sở nào",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              );
            }
          } else {
            return Center(
              child: Lottie.asset(
                "assets/lottie/loading.json",
                width: 120,
                height: 120,
              ),
            );
          }
        },
      ),
    );
  }

  Widget textFieldAdd(
      TextEditingController controller, String label, TextInputType type) {
    return TextField(
      keyboardType: type,
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}
