import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class AddFacilityScreen extends StatefulWidget {
  const AddFacilityScreen({super.key});

  @override
  State<AddFacilityScreen> createState() => _AddFacilityScreenState();
}

class _AddFacilityScreenState extends State<AddFacilityScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FirebaseFirestore facilityCollection = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Cơ Sở'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Gắn Form key
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                textFieldAdd(
                  nameController,
                  "Tên khách sạn",
                  TextInputType.text,
                  (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Vui lòng nhập tên khách sạn";
                    }
                    return null;
                  },
                ),
                const Gap(10),
                textFieldAdd(
                  addressController,
                  "Địa chỉ",
                  TextInputType.text,
                  (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Vui lòng nhập địa chỉ";
                    }
                    return null;
                  },
                ),
                const Gap(10),
                textFieldAdd(
                  numberController,
                  "Cơ sở số",
                  TextInputType.number,
                  (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Vui lòng nhập số cơ sở";
                    }
                    if (int.tryParse(value) == null) {
                      return "Cơ sở số phải là số hợp lệ";
                    }
                    return null;
                  },
                ),
                const Gap(20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Nếu dữ liệu hợp lệ, hiển thị dialog
                      AwesomeDialog(
                        btnOkText: "Có",
                        btnCancelText: "Quay lại",
                        context: context,
                        dialogType: DialogType.info,
                        animType: AnimType.rightSlide,
                        title: 'Thông báo',
                        desc: 'Bạn có muốn thêm cơ sở?',
                        btnCancelOnPress: () {},
                        btnOkOnPress: () async {
                          await facilityCollection.collection("Facility").add({
                            "facility_name": nameController.text.trim(),
                            "address": addressController.text.trim(),
                            "number": numberController.text.trim(),
                            "user_id":
                                "your_user_id_placeholder", // Thay bằng logic User ID thực tế
                          });
                          setState(() {
                            nameController.clear();
                            addressController.clear();
                            numberController.clear();
                          });
                          CherryToast.success(
                            title: const Text("Thêm cơ sở thành công"),
                          ).show(context);
                        },
                      ).show();
                    } else {
                      // Nếu dữ liệu không hợp lệ
                      CherryToast.error(
                        title: const Text("Vui lòng nhập đầy đủ và đúng thông tin"),
                      ).show(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(w * 0.9, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Thêm cơ sở",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget textFieldAdd(TextEditingController controller, String labelText,
      TextInputType inputType, String? Function(String?)? validator) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      validator: validator,
    );
  }
}
