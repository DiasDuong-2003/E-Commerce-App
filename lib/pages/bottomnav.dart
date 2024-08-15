import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/pages/Order.dart';
import 'package:shopping_app/pages/home.dart';
import 'package:shopping_app/pages/home_slideshow.dart';
import 'package:shopping_app/pages/login.dart';
import 'package:shopping_app/pages/profile.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late List<Widget> pages;

  late Home1 homePage;
  late Order order;
  late Profile profile;
  int currentTabIndex = 0;

  @override
  void initState() {
    homePage = Home1();
    order = Order();
    profile = Profile();
    pages = [homePage, order, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 50,
        backgroundColor: Colors.white,
        color: Colors.black,
        animationDuration: Duration(milliseconds: 500),
        onTap: (int index) async {
          // if (index == 2) {
          //   // Navigate to Login screen and await for result
          //   final result = await Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => Profile()),
          //   );
          //   // Check the result and update the currentTabIndex if needed
          //   if (result != null && result is int) {
          //     setState(() {
          //       currentTabIndex = result;
          //     });
          //   }
          // } else {
          //   setState(() {
          //     currentTabIndex = index;
          //   });
          // }
          setState(() {
              currentTabIndex = index;
            });
        },
        items: [
          Icon(
            Icons.home_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.shopping_bag_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.person_outline,
            color: Colors.white,
          ),
        ],
      ),
      body: pages[currentTabIndex],
    );
  }
}
