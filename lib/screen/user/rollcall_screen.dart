import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '/provider/user.dart';
import 'package:provider/provider.dart';

class RollcallScreen extends StatefulWidget {
  const RollcallScreen({super.key});

  @override
  State<RollcallScreen> createState() => _RollcallScreenState();
}

class _RollcallScreenState extends State<RollcallScreen> {
  DateTime today = DateTime.now();

  List<dynamic> _listDataRollcall = [];
  bool isLoad = true;
  bool isRollcall = false;
  Future loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await FirebaseFirestore.instance
        .collection("Rollcall")
        .where("user_id", isEqualTo: userProvider.getUserId())
        .where("month", isEqualTo: today.month)
        .where("year", isEqualTo: today.year)
        .orderBy("day", descending: false) // Sắp xếp theo ngày tăng dần
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        _listDataRollcall.add(doc);
      }
    }).catchError((error) {
      print('Error getting documents: $error');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData().whenComplete(
      () {
        setState(() {
          isLoad = false;
        });
      },
    );
  }

  String formatDay(int day) {
    if (day < 10) {
      return "0$day";
    } else {
      return "$day";
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F2F3),
        leading: const Padding(
          padding: EdgeInsets.all(5.0),
          child: CircleAvatar(
            backgroundImage: AssetImage("assets/images/boy.png"),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userProvider.getData()["username"]),
            Text("Nhân viên chính thức của Hotel",
                style: TextStyle(fontSize: 13))
          ],
        ),
        actions: [
          Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 214, 212, 212)),
                  borderRadius: BorderRadius.circular(50)),
              child: const Icon(Icons.notifications_none_outlined)),
          const Gap(5)
        ],
      ),
      body: isLoad
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _listDataRollcall.length,
              itemBuilder: (context, index) {
                final item = _listDataRollcall[index];
                return Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: w,
                  height: h * 0.1,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Container(
                          alignment: Alignment.center,
                          width: w * 0.16,
                          height: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10))),
                          child: Text(
                            formatDay(item['day']),
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )),
                      Expanded(
                          child: Container(
                        alignment: Alignment.center,
                        child: Text("Đã điểm danh",
                            style: TextStyle(
                                color: Colors.blueAccent, fontSize: 20)),
                      ))
                    ],
                  ),
                );
              },
            ),
    );
  }
}
