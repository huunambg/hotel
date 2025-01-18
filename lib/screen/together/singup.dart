import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '/provider/user.dart';
import '/screen/together/login_new.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  FirebaseFirestore userColection = FirebaseFirestore.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final rePasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<dynamic> items = [
   {"faciliti_name":"abc"}
  ];
  String ? selectedValue;
  bool islLoad = true;


void loadData() async {
     await FirebaseFirestore.instance
        .collection("Facility")
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        items.add(doc);
      }
    }).catchError((error) {
    });
    items.removeAt(0);
    setState(() {
      islLoad =false;
    });
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF21899C),
      body: Column(
        children: [
          SizedBox(
            height: size.height * 0.15,
          ),
          SizedBox(
            height: size.height * 0.85,
            child: buildCard(size),
          ),
        ],
      ),
    );
  }

  Widget buildCard(Size size) {
    final personelProvider = Provider.of<UserProvider>(context, listen: false);
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: size.height * 0.01,
                ),
                logo(size.height / 8, size.height / 8),
                SizedBox(
                  height: size.height * 0.03,
                ),
                richText(24),
                SizedBox(
                  height: size.height * 0.02,
                ),
                userNameTextField(size),
                SizedBox(
                  height: size.height * 0.02,
                ),
                emailTextField(size),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Container(
                  height: size.height / 11,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: Color.fromARGB(255, 235, 225, 225)),
                      borderRadius: BorderRadius.circular(15)),
                  child: islLoad ? const Center(child: CircularProgressIndicator(),):DropdownButtonHideUnderline(
                    child: DropdownButton2<dynamic>(
                      isExpanded: true,
                      hint: Text(
                        'Chọn cơ sở',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      items: items
                          .map((dynamic item) => DropdownMenuItem<String>(
                                value: item.id,
                                child: Text(
                                  item['faciliti_name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                          .toList(),
                      value: selectedValue,
                      onChanged: (dynamic value) {
                        setState(() {
                          selectedValue = value;
                        });
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 40,
                        width: 140,
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                passwordTextField(size),
                SizedBox(
                  height: size.height * 0.02,
                ),
                rePasswordTextField(size),
                SizedBox(
                  height: size.height * 0.03,
                ),
                InkWell(
                  child: signInButton(size),
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                     if(selectedValue!=null){
                       userColection.collection("User").add({
                        "email": emailController.text,
                        "password": passwordController.text,
                        "role": "user",
                        "username": usernameController.text,
                        "address": "Chưa đặt",
                        "date_birth": DateTime.now().toString(),
                        "facility_id": selectedValue,
                        "list_room": "Chưa có",
                        "phone_number": "Chưa có",
                        "sex": false,
                        "fcm_token":"null"
                      }).whenComplete(
                        () {
                          setState(() {
                            passwordController.clear();
                            rePasswordController.clear();
                          });
                          CherryToast.success(
                            title: const Text("Tạo tài khoản thành công"),
                          ).show(context);
                        },
                      );
                     }else{
                            CherryToast.warning(
                        title: const Text("Vui lòng chọn cơ sở"),
                      ).show(context);
                     }
                    } else {
                      CherryToast.warning(
                        title: const Text("Bạn cần nhập đầy đủ thông tin"),
                      ).show(context);
                    }
                  },
                ),
                SizedBox(
                  height: size.height * 0.04,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewLogin(),
                      ),
                    );
                  },
                  child: footerText(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget logo(double height_, double width_) {
    return SvgPicture.asset(
      'assets/svg/logo.svg',
      height: height_,
      width: width_,
    );
  }

  Widget richText(double fontSize) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: fontSize,
          color: const Color(0xFF21899C),
          letterSpacing: 2.000000061035156,
        ),
        children: const [
          TextSpan(
            text: 'Đăng',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: ' ký',
            style: TextStyle(
              color: Color(0xFFFE9879),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget emailTextField(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 11,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 1.0,
          color: const Color(0xFFEFEFEF),
        ),
      ),
      child: TextFormField(
        controller: emailController,
        style: GoogleFonts.inter(
          fontSize: 16.0,
          color: const Color(0xFF15224F),
        ),
        maxLines: 1,
        cursorColor: const Color(0xFF15224F),
        decoration: InputDecoration(
          hintText: 'Email',
          hintStyle: GoogleFonts.inter(
            fontSize: 12.0,
            color: const Color(0xFF969AA8),
          ),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập email';
          }
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Vui lòng nhập email hợp lệ';
          }
          return null;
        },
      ),
    );
  }

  Widget userNameTextField(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 11,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 1.0,
          color: const Color(0xFFEFEFEF),
        ),
      ),
      child: TextFormField(
        controller: usernameController,
        style: GoogleFonts.inter(
          fontSize: 16.0,
          color: const Color(0xFF15224F),
        ),
        maxLines: 1,
        cursorColor: const Color(0xFF15224F),
        decoration: InputDecoration(
          hintText: 'Tên người dùng',
          hintStyle: GoogleFonts.inter(
            fontSize: 12.0,
            color: const Color(0xFF969AA8),
          ),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập tên người dùng';
          }

          return null;
        },
      ),
    );


  }

  Widget passwordTextField(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 11,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 1.0,
          color: const Color(0xFFEFEFEF),
        ),
      ),
      child: TextFormField(
        controller: passwordController,
        style: GoogleFonts.inter(
          fontSize: 16.0,
          color: const Color(0xFF15224F),
        ),
        maxLines: 1,
        obscureText: true,
        keyboardType: TextInputType.visiblePassword,
        cursorColor: const Color(0xFF15224F),
        decoration: InputDecoration(
          hintText: 'Mật khẩu',
          hintStyle: GoogleFonts.inter(
            fontSize: 12.0,
            color: const Color(0xFF969AA8),
          ),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập mật khẩu';
          }
          if (value.length < 6) {
            return 'Mật khẩu phải có ít nhất 6 ký tự';
          }
          return null;
        },
      ),
    );
  }

  Widget rePasswordTextField(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 11,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          width: 1.0,
          color: const Color(0xFFEFEFEF),
        ),
      ),
      child: TextFormField(
        controller: rePasswordController,
        style: GoogleFonts.inter(
          fontSize: 16.0,
          color: const Color(0xFF15224F),
        ),
        maxLines: 1,
        obscureText: true,
        keyboardType: TextInputType.visiblePassword,
        cursorColor: const Color(0xFF15224F),
        decoration: InputDecoration(
          hintText: 'Nhập lại mật khẩu',
          hintStyle: GoogleFonts.inter(
            fontSize: 12.0,
            color: const Color(0xFF969AA8),
          ),
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập lại mật khẩu';
          }
          if (value != passwordController.text) {
            return 'Mật khẩu không khớp';
          }
          return null;
        },
      ),
    );
  }

  Widget signInButton(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 11,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        color: const Color(0xFF21899C),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C2E84).withOpacity(0.2),
            offset: const Offset(0, 15.0),
            blurRadius: 60.0,
          ),
        ],
      ),
      child: Text(
        'Đăng ký',
        style: GoogleFonts.inter(
          fontSize: 16.0,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget footerText() {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: 12.0,
          color: const Color(0xFF3B4C68),
        ),
        children: const [
          TextSpan(
            text: 'Bạn đã có tài khoản ?',
          ),
          TextSpan(
            text: ' ',
            style: TextStyle(
              color: Color(0xFFFF5844),
            ),
          ),
          TextSpan(
            text: 'Đăng nhập',
            style: TextStyle(
              color: Color(0xFFFF5844),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
