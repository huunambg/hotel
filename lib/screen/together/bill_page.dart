import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hotel/screen/admin/update_bill.dart';
import 'package:intl/intl.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key, required this.isAdmin, this.facilityId});
  final bool isAdmin;
  final String? facilityId;

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  FirebaseFirestore billCollection = FirebaseFirestore.instance;
  late SwipeActionController controller;

  @override
  void initState() {
    super.initState();
    controller = SwipeActionController(selectedIndexPathsChangeCallback:
        (changedIndexPaths, selected, currentCount) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Hóa đơn",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
        stream: widget.isAdmin
            ? billCollection.collection("Bill").snapshots()
            : billCollection
                .collection("Bill")
                .where('facility_id', isEqualTo: widget.facilityId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List<dynamic> bills = snapshot.data!.docs;
            bills = bills.reversed.toList();
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemCount: bills.length,
              separatorBuilder: (context, index) => Gap(12),
              itemBuilder: (context, index) {
                var bill = bills[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateBillScreen(bill: bill),
                      ),
                    );
                  },
                  child: _item(context, index, bill),
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                "Không có hóa đơn nào!",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {bool isHighlight = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            "$label ",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w400,
              color: isHighlight ? highlightColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String convertMoney(int money) {
    return "${NumberFormat.decimalPattern('vi').format(money)}đ";
  }

  Widget _item(BuildContext ctx, int index, var bill) {
    double h = MediaQuery.of(context).size.height;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: SwipeActionCell(
          controller: controller,
          index: index,
          // Required!
          key: ValueKey(bill),
          selectedForegroundColor: Colors.black.withAlpha(30),
          trailingActions: [
            // SwipeAction(
            //     backgroundRadius: 8.0,
            //     title: "Xóa",
            //     closeOnTap: true,
            //     onTap: (handler) async {
            //       PanaraConfirmDialog.show(
            //         context,
            //         title: "Xóa thực phẩm",
            //         message: "Bạn có xóa sản phẩm khỏi danh sách",
            //         confirmButtonText: "Xóa",
            //         cancelButtonText: "Quay lại",
            //         onTapCancel: () {
            //           //Get.back();
            //         },
            //         onTapConfirm: () {
            //           // menuCtl.deleteMenu(menuCtl.listMenu[index].menuId!);
            //           // Get.back();
            //         },
            //         panaraDialogType: PanaraDialogType.warning,
            //         barrierDismissible: false,
            //       );
            //     }),
            SwipeAction(
                backgroundRadius: 8.0,
                title: "Cập nhật",
                color: Colors.lightGreen,
                onTap: (handler) {
                  if (bill['is_paid'] == false) {
                    PanaraConfirmDialog.show(
                      context,
                      title: "Cập nhật trạng thái",
                      message: "Bạn có muốn cập nhật trạng thái của hóa đơn",
                      confirmButtonText: "Cập nhật",
                      cancelButtonText: "Quay lại",
                      onTapCancel: () {
                        //Get.back();
                        Navigator.pop(context);
                      },
                      onTapConfirm: () {
                        controller.closeAllOpenCell();
                        Navigator.pop(context);
                        billCollection
                            .collection("Bill")
                            .doc(bill.id)
                            .update({'is_paid': true});
                        CherryToast.success(
                          title: Text("Cập nhật thành công"),
                        ).show(context);
                      },
                      panaraDialogType: PanaraDialogType.warning,
                      barrierDismissible: false,
                    );
                  } else {
                    controller.closeAllOpenCell();
                    CherryToast.warning(
                      title: Text("Hóa đơn đã cập nhật"),
                    ).show(context);
                  }
                }),
          ],
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: h * 0.22,
                  width: h * 0.12,
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    bill['room_number'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow(
                          "Thuê theo:",
                          bill['is_rent_hour'] ? "Giờ" : "Ngày",
                        ),
                        _buildRow(
                          "Bắt đầu:",
                          DateFormat('HH:mm - dd/MM/yyyy').format(
                            DateTime.parse(bill['start_day']),
                          ),
                        ),
                        _buildRow(
                          "Kết thúc:",
                          DateFormat('HH:mm - dd/MM/yyyy').format(
                            DateTime.parse(bill['end_day']),
                          ),
                        ),
                        _buildRow(
                          bill['is_rent_hour']
                              ? "Giá theo giờ:"
                              : "Giá theo ngày:",
                          convertMoney(bill['is_rent_hour']
                              ? bill['price_on_hour']
                              : bill['price_on_day']),
                        ),
                        _buildRow(
                          "Tổng tiền:",
                          convertMoney(bill['total_money']),
                        ),
                        _buildRow(
                          "Thanh toán:",
                          bill['is_paid'] ? "Đã thanh toán" : "Chưa thanh toán",
                          isHighlight: true,
                          highlightColor:
                              bill['is_paid'] ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
