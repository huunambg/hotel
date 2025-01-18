import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hotel/screen/admin/statistic_page.dart';
import '/provider/user.dart';
import '/screen/together/login_new.dart';
import '/widget/itemaccount.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ionicons/ionicons.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: ListView(
        padding:
            const EdgeInsets.only(top: 35, bottom: 10, left: 10, right: 10),
        children: [
          Column(
            children: [
              InkWell(
                onTap: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(500),
                  child: SizedBox(
                    height: h * 0.2,
                    width: h * 0.2,
                    child: Image.asset("assets/images/boy.png"),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                userProvider.getData()["username"],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              userProvider.getData()["role"] == "admin"
                  ? const Text("Quản lý khách sạn")
                  : const Text("Nhân viên khách sạn"),
            ],
          ),
          const SizedBox(height: 20),
          userProvider.getData()["role"] == "admin"
              ? ItemAccount(
                  icon: Icons.stacked_bar_chart_outlined,
                  onpressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatisticPage(),
                        ));
                  },
                  titile: "Thống kê")
              : ItemAccount(
                  icon: Icons.person_outline_outlined,
                  onpressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatisticPage(),
                        ));
                  },
                  titile: "Sửa thông tin"),
          ItemAccount(
              icon: Ionicons.help, onpressed: () async {}, titile: "Phản hồi"),
          ItemAccount(
              icon: Ionicons.settings_outline,
              onpressed: () async {},
              titile: "Cài đặt"),
          ItemAccount(
              icon: Ionicons.arrow_back_circle_outline,
              onpressed: () async {
                bool check = false;
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Thông báo'),
                    content: const Text('Bạn có chắc muốn đăng xuất không?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () async {
                          check = true;
                          Navigator.of(context).pop();

                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool("isLogin", false);
                        },
                        child: const Text('Có'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Không'),
                      ),
                    ],
                  ),
                );
                if (check) {
                  if (mounted) {
                    FirebaseFirestore.instance
                        .collection("User")
                        .doc(userProvider.getUserId())
                        .update({"fcm_token": ""}).whenComplete(
                      () {
                        Navigator.pushReplacement(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NewLogin(),
                            ));
                      },
                    );
                  }
                }
              },
              titile: "Đăng xuất"),
        ],
      ),
    );
  }

  // Future<void> logout(BuildContext context) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool("is_logout", true);
  //   prefs.remove('token');
  //   prefs.remove('username');
  //   prefs.remove('personnel_id');
  //   Navigator.pop(context);
  //   Navigator.pushReplacement(
  //       context, MaterialPageRoute(builder: (context) => Login()));
  // }
}
