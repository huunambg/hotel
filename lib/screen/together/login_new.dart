import 'package:cherry_toast/cherry_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '/custom_dialog.dart';
import '/provider/user.dart';
import '/screen/admin/navbar.dart';
import '/screen/together/singup.dart';
import '/screen/user/navbar_user.dart';
import 'package:provider/provider.dart';

class NewLogin extends StatefulWidget {
  const NewLogin({super.key});

  @override
  State<NewLogin> createState() => _NewLoginState();
}

class _NewLoginState extends State<NewLogin> {
  FirebaseFirestore userColection = FirebaseFirestore.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool checkLogin = false;
  @override
  void initState() {
    super.initState();
    emailController.text = "nam@gmail.com";
    passwordController.text = "123456";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF21899C),
      body: SingleChildScrollView(
        child: Column(
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
      ),
    );
  }

  Widget buildCard(Size size) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //header text

            Text(
              'Khám phá quản lý khách sạn của bạn ',
              style: GoogleFonts.inter(
                fontSize: 14.0,
                color: const Color(0xFF969AA8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: size.height * 0.04,
            ),

            //logo section
            logo(size.height / 8, size.height / 8),
            SizedBox(
              height: size.height * 0.03,
            ),
            richText(24),
            SizedBox(
              height: size.height * 0.05,
            ),

            //email & password section
            emailTextField(size),
            SizedBox(
              height: size.height * 0.02,
            ),
            passwordTextField(size),
            SizedBox(
              height: size.height * 0.03,
            ),

            //sign in button
            InkWell(
              child: signInButton(size),
              onTap: () async {
                checkLogin = false;
                CustomDialog(context, size.height).loadingDialog();
                await userColection
                    .collection('User')
                    .where('email', isEqualTo: emailController.text)
                    .where('password', isEqualTo: passwordController.text)
                    .get()
                    .then((QuerySnapshot querySnapshot) {
                  if (querySnapshot.docs.isNotEmpty) {
                    var doc = querySnapshot.docs.first;
                    userProvider.setData(doc);
                    Navigator.pop(context);
                    if (doc['role'] == "admin") {
                      checkLogin = true;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NavBarAdmin(),
                          ));
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NavbarUser(),
                          ));
                    }
                  } else {
                    Navigator.pop(context);
                    CherryToast.error(
                      title: Text('Thông báo'),
                      description: Text('Email hoặc mật khẩu không đúng!'),
                    ).show(context);
                  }
                }).catchError((error) {
                  Navigator.pop(context);
                  CherryToast.error(
                    title: Text('Thông báo'),
                    description: Text('Đã xảy ra lỗi! Vui lòng thử lại.'),
                  ).show(context);
                });
              },
            ),
            SizedBox(
              height: size.height * 0.04,
            ),

            //footer section. sign up text here
            InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUp(),
                      ));
                },
                child: footerText()),
          ],
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
            text: ' nhập',
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
      child: TextField(
        controller: emailController,
        style: GoogleFonts.inter(
          fontSize: 16.0,
          color: const Color(0xFF15224F),
        ),
        maxLines: 1,
        cursorColor: const Color(0xFF15224F),
        decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: GoogleFonts.inter(
              fontSize: 12.0,
              color: const Color(0xFF969AA8),
            ),
            border: InputBorder.none),
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
      child: TextField(
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
            labelText: 'Mật khẩu',
            labelStyle: GoogleFonts.inter(
              fontSize: 12.0,
              color: const Color(0xFF969AA8),
            ),
            border: InputBorder.none),
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
        'Đăng nhập',
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
            text: 'Bạn chưa có tài khoản ?',
          ),
          TextSpan(
            text: ' ',
            style: TextStyle(
              color: Color(0xFFFF5844),
            ),
          ),
          TextSpan(
            text: 'Đăng kí',
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
