import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '/screen/user/notification.dart';
import '/custom_dialog.dart';
import '/provider/user.dart';
import '/widget/custom_item_recent_activity.dart';
import '/widget/custom_slide_button.dart';
import '/widget/custom_sound.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:provider/provider.dart';

class HomePageUser extends StatefulWidget {
  const HomePageUser({super.key});

  @override
  State<HomePageUser> createState() => _HomePageUserState();
}

class _HomePageUserState extends State<HomePageUser> {
  DateTime today = DateTime.now();
  late double h;
  late double w;
  final EasyInfiniteDateTimelineController _controller =
      EasyInfiniteDateTimelineController();
  DateTime? _focusDate = DateTime.now();

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
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        _listDataRollcall.add(doc);
      }
    }).catchError((error) {
      print('Error getting documents: $error');
    });
  }

  bool rollcall(DateTime date) {
    for (var item in _listDataRollcall) {
      if (item['day'] == date.day &&
          item['month'] == date.month &&
          item['year'] == date.year) {
        return false;
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    loadData().whenComplete(
      () {
        isRollcall = rollcall(today);
        setState(() {
          isLoad = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    h = MediaQuery.of(context).size.height;
    w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F2F3),
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
            const Text("Nhân viên chính thức của Hotel",
                style: TextStyle(fontSize: 13))
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                )),
            child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 214, 212, 212)),
                    borderRadius: BorderRadius.circular(50)),
                child: const Icon(Icons.notifications_none_outlined)),
          ),
          const Gap(5)
        ],
      ),
      body: isLoad
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(5),
                  EasyInfiniteDateTimeLine(
                    dayProps: EasyDayProps(
                        height: 90,
                        inactiveDayStyle: DayStyle(
                            decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ))),
                    showTimelineHeader: false,
                    locale: "vi_VN",
                    controller: _controller,
                    firstDate: DateTime(today.year, today.month, 1),
                    focusDate: _focusDate,
                    lastDate: DateTime(today.year, today.month, 1)
                        .add(const Duration(days: 30)),
                    onDateChange: (selectedDate) {
                      setState(() {
                        _focusDate = selectedDate;
                        isRollcall = rollcall(selectedDate);
                      });
                    },
                  ),
                  Gap(h * 0.02),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Điểm danh hôm nay",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const Gap(10),
                        Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: h * 0.2,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 2,
                                  offset: Offset(1, 1),
                                ),
                              ]),
                          child: isRollcall == false
                              ? const Text(
                                  "Đã điểm danh",
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 20),
                                )
                              : const Text(
                                  "Chưa điểm danh",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                ),
                        ),
                        Gap(h * 0.02),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Hoạt động gần đây",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Xem tất cả",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.blue),
                            ),
                          ],
                        ),
                        const Gap(10),
                        const ItemRecentActivity(),
                        const Gap(10),
                        const ItemRecentActivity(),
                        const Gap(16),
                        CustomSlideButton(
                          action: () async {
                            DateTime dateTime = DateTime.now();
                            CustomDialog(context, h).loadingDialog();
                            if (rollcall(dateTime)) {
                              FirebaseFirestore.instance
                                  .collection("Rollcall")
                                  .add({
                                "user_id": userProvider.getData().id,
                                "day": dateTime.day,
                                "month": dateTime.month,
                                "year": dateTime.year
                              }).whenComplete(() {
                                Navigator.pop(context);
                                CustomSound().playBeepSucces();
                                CherryToast.success(
                                  title: const Text("Điểm danh thành công"),
                                ).show(context);
                                _listDataRollcall.add({
                                  "user_id": userProvider.getData().id,
                                  "day": dateTime.day,
                                  "month": dateTime.month,
                                  "year": dateTime.year
                                });
                                setState(() {
                                  isRollcall = rollcall(dateTime);
                                });
                              });
                            } else {
                              Navigator.pop(context);
                              CustomSound().playBeepWarning();
                              CherryToast.warning(
                                title: Text("Bạn đã điểm danh ngày hôm nay"),
                              ).show(context);
                            }

                            return false;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
