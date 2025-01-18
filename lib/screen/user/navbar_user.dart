import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '/screen/admin/room.dart';
import '/screen/together/bill_page.dart';
import '/provider/user.dart';
import '/screen/together/acount_page.dart';
import '/screen/user/home_page_user.dart';
import '/screen/user/rollcall_screen.dart';
import '/widget/notification.dart';
import 'package:provider/provider.dart';

class NavbarUser extends StatefulWidget {
  const NavbarUser({
    super.key,
  });

  @override
  State<NavbarUser> createState() => _NavbarUserState();
}

class _NavbarUserState extends State<NavbarUser> {
  int _bottomNavIndex = 0;

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const NavbarUser(),
          ));
    }
  }

  Future<void> setupInteractedMessage() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    debugPrint(token);
    await FirebaseFirestore.instance
        .collection("User")
        .doc(userProvider.getData().id)
        .update({"fcm_token": token});
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint(
          'Received a foreground message: ${message.notification?.body}');
      NotificationService().showNotification(
          title: message.notification?.title, body: message.notification?.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final tab = [
      const HomePageUser(),
      RoomScreen(facilitiId: userProvider.getData()["facility_id"]),
      BillPage(
        isAdmin: false,
        facilityId: userProvider.getData()["facility_id"],
      ),
      const AccountPage()
    ];
    return Scaffold(
      body: tab[_bottomNavIndex],
      bottomNavigationBar: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: GNav(
          gap: 10,
          rippleColor: Colors.grey[300]!,
          hoverColor: Colors.grey[100]!,
          activeColor: Colors.blueAccent,
          iconSize: 26,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: Colors.white,
          color: Colors.black,
          tabs: const [
            GButton(
              icon: Icons.home_outlined,
              text: 'Trang chủ',
            ),
            GButton(
              icon: Icons.grid_on_outlined,
              text: 'Danh sách phòng',
            ),
            GButton(
              icon: Icons.book,
              text: 'Hóa đơn',
            ),
            GButton(
              icon: Icons.person_outline,
              text: 'Tài khoản',
            ),
          ],
          selectedIndex: _bottomNavIndex,
          onTabChange: (index) {
            setState(() {
              _bottomNavIndex = index;
            });
          },
        ),
      ),
    );
  }
}
