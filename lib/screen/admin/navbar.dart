import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hotel/screen/admin/bill_page_admin.dart';
import '/screen/together/bill_page.dart';
import '/provider/user.dart';
import '/screen/admin/home_page_admin.dart';
import '/screen/admin/personnel.dart';
import '/screen/together/acount_page.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
class NavBarAdmin extends StatefulWidget {
  const NavBarAdmin({super.key});

  @override
  State<NavBarAdmin> createState() => _NavBarAdminState();
}

class _NavBarAdminState extends State<NavBarAdmin> {
  final iconList = <IconData>[
    Icons.home_outlined,
    Icons.people_outline,
    Icons.book,
    Icons.person_outline,
  ];

  int _bottomNavIndex = 0;

  final tab = [
    const HomePageAdmin(),
    const PersonnelScreen(),
    const BillPageAdmin(isAdmin: true,),
    const AccountPage(),
  ];
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  FirebaseFirestore notificationColection = FirebaseFirestore.instance;

  List<String> _listFcmToken = [];

  @override
  Widget build(BuildContext context) {
   // final personelProvider = Provider.of<UserProvider>(context, listen: false);
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: tab[_bottomNavIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () {
          FirebaseFirestore.instance
              .collection("User")
              .where("role", isEqualTo: "user")
              .get()
              .then((QuerySnapshot querySnapshot) {
            for (var doc in querySnapshot.docs) {
             if(doc['fcm_token']!=""){
               _listFcmToken.add(doc['fcm_token'].toString());
             }
            }

            if (_listFcmToken.isEmpty) {
              print("No FCM tokens found.");
              // Xử lý khi không có token nào
            } else {
              // Tiếp tục xử lý khi có token
            }
          }).catchError((error) {
            print('Error getting documents: $error');
          });

          showModalBottomSheet(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            context: context,
            builder: (context) => SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(8),
                height: h * 0.6,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          onPressed: () {
                            titleController.clear();
                            contentController.clear();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close)),
                    ),
                    textFieldAdd(
                        titleController, "Tên thông báo", TextInputType.text),
                    const Gap(10),
                    textFieldAdd(contentController, "Nội dung thông báo",
                        TextInputType.number),
                    const Gap(20),
                    MaterialButton(
                      onPressed: () {
                        AwesomeDialog(
                          btnOkText: "Có",
                          btnCancelText: "Quay lại",
                          context: context,
                          dialogType: DialogType.info,
                          animType: AnimType.rightSlide,
                          title: 'Thông báo',
                          desc:
                              'Bạn có muốn gửi thông báo đến toàn bộ nhân viên',
                          btnCancelOnPress: () {},
                          btnOkOnPress: () async {
                            if (_listFcmToken.isNotEmpty) {
                              var url = Uri.parse(
                                  'http://192.168.100.10:3000/public/api/send-notification');
                              var response = await http.post(
                                url,
                                body: {
                                  "title": titleController.text,
                                  "content": contentController.text,
                                  "fcm_tokens": _listFcmToken.toString()
                                },
                              );
                              print('Response status: ${response.statusCode}');
                              print('Response body: ${response.body}');
                              await notificationColection
                                  .collection("Notifications")
                                  .add({
                                "title": titleController.text,
                                "content": contentController.text,
                                "time": DateTime.now().toString()
                              });
                              setState(() {
                                titleController.clear();
                                contentController.clear();
                              });
                              CherryToast.success(
                                title: const Text("Tạo thông báo thành công"),
                                // ignore: use_build_context_synchronously
                              ).show(context);
                            } else {
                              CherryToast.error(
                                title: const Text(
                                    "Chưa có nhân viên nào dể nhận thông báo"),
                                // ignore: use_build_context_synchronously
                              ).show(context);
                            }
                          },
                        ).show();
                      },
                      minWidth: w * 0.9,
                      height: 50,
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: const Text(
                        "Gửi thông báo",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
        child: const Icon(
          Icons.notification_add,
          size: 26,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: (index) => setState(() => _bottomNavIndex = index),
      ),
    );
  }

  Widget textFieldAdd(
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
