import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Giá trị được chọn trong Dropdown
  String? selectedMonth;
  String? selectedYear;

  Map<String, dynamic> dailyStatistics = {}; // Lưu thống kê theo ngày
  int totalBills = 0; // Tổng số hóa đơn
  int totalRevenue = 0; // Tổng doanh thu

  // Lấy dữ liệu thống kê từ Firestore
  Future<void> loadStatistics() async {
    QuerySnapshot snapshot = await firestore.collection("Bill").get();

    Map<String, dynamic> statistics = {};
    int revenue = 0;
    int bills = 0;
    for (var doc in snapshot.docs) {
      String startDay = doc['start_day'];

      // Đảm bảo parse đúng ngày
      DateTime parsedDate = DateTime.parse(startDay);

      if ((selectedMonth == null ||
              parsedDate.month == int.parse(selectedMonth!)) &&
          (selectedYear == null ||
              parsedDate.year == int.parse(selectedYear!))) {
        String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);

        if (!statistics.containsKey(formattedDate)) {
          statistics[formattedDate] = {
            "totalBills": 0,
            "totalRevenue": 0,
          };
        }

        statistics[formattedDate]["totalBills"] += 1;
        statistics[formattedDate]["totalRevenue"] += doc['total_money'] as int;

        revenue += doc['total_money'] as int;
        bills += 1;
      }
    }

    setState(() {
      dailyStatistics = statistics;
      totalRevenue = revenue;
      totalBills = bills;
    });
  }

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thống kê hóa đơn"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown lọc tháng và năm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dropdown chọn tháng
                Expanded(
                  child: DropdownButton<String?>(
                    value: selectedMonth,
                    onChanged: (String? newMonth) {
                      setState(() {
                        selectedMonth = newMonth;
                      });
                      loadStatistics();
                    },
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: const Text("Tất cả tháng"),
                      ),
                      ...List.generate(12, (index) {
                        String month = (index + 1).toString().padLeft(2, '0');
                        return DropdownMenuItem<String?>(
                          value: month,
                          child: Text("Tháng $month"),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Dropdown chọn năm
                Expanded(
                  child: DropdownButton<String?>(
                    value: selectedYear,
                    onChanged: (String? newYear) {
                      setState(() {
                        selectedYear = newYear;
                      });
                      loadStatistics();
                    },
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: const Text("Tất cả năm"),
                      ),
                      ...List.generate(5, (index) {
                        String year =
                            (DateTime.now().year - 1 + index).toString();
                        return DropdownMenuItem<String?>(
                          value: year,
                          child: Text("Năm $year"),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Thống kê tổng quan
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bar_chart, color: Colors.blue, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          "Thống kê tổng quan",
                          style:
                              TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStatisticRow(
                      "Tổng hóa đơn:",
                      totalBills.toString(),
                      isHighlighted: true,
                    ),
                    const SizedBox(height: 8),
                    _buildStatisticRow(
                      "Tổng doanh thu:",
                      "${NumberFormat.decimalPattern('vi').format(totalRevenue)}đ",
                      isHighlighted: true,
                    ),
                  ],
                ),
              ),
            ),

            // Chi tiết thống kê theo ngày
            Expanded(
              child: dailyStatistics.isEmpty
                  ? const Center(
                      child: Text(
                        "Không có dữ liệu thống kê!",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: dailyStatistics.keys.length,
                      itemBuilder: (context, index) {
                        String date = dailyStatistics.keys.elementAt(index);
                        int totalBills = dailyStatistics[date]["totalBills"];
                        int totalRevenue =
                            dailyStatistics[date]["totalRevenue"];

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: Colors.green, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Ngày: $date",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildStatisticRow(
                                  "Tổng hóa đơn:",
                                  totalBills.toString(),
                                  isHighlighted: true,
                                ),
                                _buildStatisticRow(
                                  "Tổng doanh thu:",
                                  "${NumberFormat.decimalPattern('vi').format(totalRevenue)}đ",
                                  isHighlighted: true,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticRow(String label, String value,
      {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 16 : 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
