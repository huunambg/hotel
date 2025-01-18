import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '/provider/user.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  DateTime today = DateTime.now();

  List<dynamic> _listDataNotification = [];
  bool isLoad = true;
  bool isRollcall = false;
  Future loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print(today);
    await FirebaseFirestore.instance
        .collection("Notifications")
        // .orderBy("time", descending: false) // Sắp xếp theo ngày tăng dần
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        _listDataNotification.add(doc);
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
        centerTitle: true,
        title: const Text("Thông báo"),
      ),
      body: isLoad
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _listDataNotification.length,
              itemBuilder: (context, index) {
                final item = _listDataNotification[index];
                return Container(
                  padding: EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 8),
                  width: w,
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
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(100)),
                          child: Text(
                            (_listDataNotification.length - index).toString(),
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )),
                      Gap(5),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Thông báo: ${item['title']}",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16)),
                          Text("Nội dung: ${item['content']}",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14)),
                          Text(
                              "Thời gian: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(item['time']))}")
                        ],
                      ))
                    ],
                  ),
                );
              },
            ),
    );
  }
}
