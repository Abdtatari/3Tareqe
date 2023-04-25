import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tareqe/screens/driversListPage.dart';
import 'package:tareqe/screens/passengersListPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:tareqe/models/theme.dart';

class adminUsersPage extends StatefulWidget {
  const adminUsersPage({Key? key}) : super(key: key);

  @override
  State<adminUsersPage> createState() => _adminUsersPageState();
}

class _adminUsersPageState extends State<adminUsersPage> {
  List<Widget> screens = [];
  int screenIndex = 0;

  @override
  void initState() {
    super.initState();
    screens.add(passengersListPage());
    screens.add(driverListPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users".tr()),
        backgroundColor: appTheme.mainColor,
        centerTitle: true,
      ),
      resizeToAvoidBottomInset : false,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: screenIndex,
        onTap: (int i) {
          setState(() {
            screenIndex = i;
          });
        },
        items: [
          BottomNavigationBarItem(
            activeIcon: Icon(
              Icons.person,
              color: Colors.green,
              size: 36,
            ),
            icon: Icon(
              Icons.person,
              color: appTheme.mainColor,
              size: 30,
            ),
            label: "Passengers".tr(),),
          BottomNavigationBarItem(
            activeIcon:  Icon(
              CupertinoIcons.car_detailed,
              color: Colors.green,
              size: 36,
            ),
            icon: Icon(
              CupertinoIcons.car_detailed,
              color: appTheme.mainColor,
              size: 30,
            ),
            label: "Drivers".tr(),),
        ],
      ),
      body: IndexedStack(
        children: screens,
        index: screenIndex,
      ),);
  }
}
