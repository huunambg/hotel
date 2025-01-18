import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class UpdateFacility extends StatefulWidget {
  const UpdateFacility({super.key, required this.facility});

  final dynamic facility;

  @override
  State<UpdateFacility> createState() => _UpdateFacilityState();
}

class _UpdateFacilityState extends State<UpdateFacility> {
  final TextEditingController numberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FirebaseFirestore roomColection = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    numberController.text = widget.facility['number'].toString();
    nameController.text = widget.facility['faciliti_name'];
    addressController.text = widget.facility['address'];
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập Nhật Cơ Sở'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Gắn form key để quản lý trạng thái
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cập nhật thông tin cơ sở",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const Gap(20),
                textFieldAdd(
                  nameController,
                  "Tên cơ sở",
                  TextInputType.text,
                  (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Vui lòng nhập tên cơ sở";
                    }
                    return null;
                  },
                ),
                const Gap(15),
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
                const Gap(15),
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
                const Gap(30),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Nếu dữ liệu hợp lệ, thực hiện cập nhật
                        await roomColection
                            .collection("Facility")
                            .doc(widget.facility.id)
                            .update({
                          "faciliti_name": nameController.text.trim(),
                          "address": addressController.text.trim(),
                          "number": int.parse(numberController.text.trim()),
                        });
                        setState(() {
                          nameController.clear();
                          addressController.clear();
                          numberController.clear();
                        });
                        CherryToast.success(
                          title: const Text("Cập nhật thành công"),
                        ).show(context);
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
                      "Cập nhật",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget textFieldAdd(
      TextEditingController controller,
      String labelText,
      TextInputType inputType,
      String? Function(String?)? validator) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.teal),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.teal),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      validator: validator, // Thêm logic xác thực
    );
  }
}
