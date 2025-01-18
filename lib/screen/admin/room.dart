import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hotel/screen/admin/update_room.dart';
import '/screen/admin/add_bill_day.dart';
import '/screen/admin/add_bill_hour.dart';
import '/screen/admin/add_personnel.dart';
import '/screen/admin/add_room.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, required this.facilitiId});
  final String facilitiId;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  FirebaseFirestore roomColection = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
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
                        facilityId: widget.facilitiId,
                      ),
                    ));
              },
              icon: const Icon(Icons.person_2_outlined)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddRoomScreen(
                        facilityId: widget.facilitiId,
                      ),
                    ));
              },
              icon: const Icon(Icons.holiday_village))
        ],
        title: const Text("Danh sách phòng"),
      ),
      body: StreamBuilder(
        stream: roomColection
            .collection("Room")
            .where('facility_id', isEqualTo: widget.facilitiId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<dynamic> rooms = snapshot.data!.docs;
            if (rooms.isEmpty) {
              return const Center(
                child: Text(
                  "Hiện chưa có phòng nào trong cơ sở này",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }
            rooms = rooms.reversed.toList();
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: rooms.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12),
              itemBuilder: (context, index) {
                var room = rooms[index];
                return InkWell(
                    onLongPress: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateRoom(room: room),
                          ));
                    },
                    onTap: () => _showBookingOptions(context, room),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border:
                            Border.all(color: Colors.blueAccent, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: room['is_vip']
                                      ? Colors.orangeAccent
                                      : Colors.blue,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                ),
                                child: Text(
                                  room['room_number'].toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UpdateRoom(room: room),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      _showConfirmDelete(context, room);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(Icons.edit,
                                            color: Colors.blue),
                                        title: Text('Sửa phòng'),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(Icons.delete,
                                            color: Colors.red),
                                        title: Text('Xóa phòng'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("Theo giờ: ",
                                        style: TextStyle(fontSize: 14)),
                                    Text(convertMoney(room['price_on_hour']),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const Gap(5),
                                Row(
                                  children: [
                                    const Text("Theo ngày: ",
                                        style: TextStyle(fontSize: 14)),
                                    Text(convertMoney(room['price_on_day']),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const Gap(8),
                                if (room['is_vip'])
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        "VIP",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ));
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

  void _showRoomOptions(BuildContext context, dynamic room) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Bo tròn góc
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Đảm bảo dialog có kích thước gọn
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "Thông báo",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Mời bạn chọn thuê phòng",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Dàn đều các nút
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddBillHour(room: room),
                          ));
                    },
                    child: const Text("Theo giờ"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddBillDay(room: room),
                          ));
                    },
                    child: const Text("Theo ngày"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Quay lại"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingOptions(BuildContext context, dynamic room) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Bo tròn các góc của dialog
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Đảm bảo dialog không chiếm toàn màn hình
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    "Thông báo",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Mời bạn chọn thuê phòng",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10.0, // Khoảng cách ngang giữa các nút
                runSpacing: 8.0, // Khoảng cách dọc nếu xuống dòng
                alignment: WrapAlignment.center, // Căn giữa các nút
                children: [
                  buildDialogButton(
                    context: context,
                    label: "Theo giờ",
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBillHour(room: room),
                        ),
                      );
                    },
                  ),
                  buildDialogButton(
                    context: context,
                    label: "Theo ngày",
                    color: Colors.green,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBillDay(room: room),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDialogButton({
    required BuildContext context,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Bo tròn nút
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }

  void _showConfirmDelete(BuildContext context, dynamic room) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text("Xóa phòng"),
          content: const Text("Bạn có chắc muốn xóa phòng này không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                await roomColection
                    .collection("Room")
                    .doc(room.id) // Xóa phòng theo ID
                    .delete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Phòng đã được xóa thành công")),
                );
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  String convertMoney(int money) {
    return "${NumberFormat.decimalPattern('vi').format(money)}đ";
  }
}
