import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tareqe/screens/driverMapPage.dart';
import 'package:tareqe/screens/driversListPage.dart';

import '../models/DAO.dart';
import '../models/sessionInfo.dart';
import '../screens/adminSelect.dart';
import '../screens/becomeDriverRequest.dart';
import '../screens/login.dart';
import '../screens/profile.dart';
import '../screens/writeReview.dart';
import 'message.dart';
import 'package:tareqe/models/theme.dart';

class appDrawer extends StatefulWidget {
  const appDrawer({Key? key}) : super(key: key);

  @override
  State<appDrawer> createState() => _appDrawerState();
}

class _appDrawerState extends State<appDrawer> {
  bool activeDriver=SessionInfo.currentStudent.isDriving!;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Widget card(String title, Icon icon, tap()) {
      return Column(
        children: [
          InkWell(
            onTap: tap,
            child: Container(
              padding: EdgeInsets.only(left: 20),
              height: height * 0.1,
              width: width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      icon,
                      SizedBox(width: 10,),
                      Text(
                        title,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        ],
      );
    }
    String type="Passenger".tr();
    if (SessionInfo.currentStudent.type==2){
      type="Driver";
    }
    else if (SessionInfo.currentStudent.type==0){
      type="Admin";
    }
    else {
      type="Passenger";
    }
    return Container(
      width: 0.8 * width,
      height: height,
      color: Colors.white,
      child: Column(
        children: [
          Container(
              width: width*0.8,
              height:height*0.26,
              color: appTheme.mainColor,
              padding: EdgeInsets.only(left: 10,right: 10),
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsets.only(top: height * 0.05),
                      width: 100,
                      height: height*0.12,
                      child:
                      SessionInfo.currentStudent.photo!=null
                          && SessionInfo.currentStudent.photo!.isNotEmpty?
                      CircleAvatar(
                          backgroundImage:
                          NetworkImage(SessionInfo.currentStudent.photo!)
                      ):
                      CircleAvatar(
                          backgroundImage:
                          AssetImage("assets/images/defaultProfile.png")
                      )
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(SessionInfo.currentStudent.name!),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(CupertinoIcons.car_detailed,color: Colors.white,),
                      SizedBox(width: 10,),
                      Text(type.tr()),
                      Expanded(child: SizedBox()),
                      SessionInfo.currentStudent.type==2?
                      activeDriver?
                      Text("Active".tr()):
                      Text("Offline".tr()):SizedBox(),
                      SessionInfo.currentStudent.type==2?
                      Container(
                        margin: EdgeInsets.only(left: 5,right: 5),
                        decoration: BoxDecoration(
                            color:activeDriver? Colors.green:Colors.red,
                            borderRadius: BorderRadius.circular(50)
                        ),
                        width: 20,
                        height: 20,
                      ):SizedBox()
                    ],
                  )
                ],
              )
          ),

          Flexible(
              child: ListView(
                children: [
                  card(
                      "Profile".tr(),
                      Icon(
                        CupertinoIcons.profile_circled,
                        color: appTheme.mainColor,
                      ), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => profile()),
                    ).then((value) => setState((){}));
                  }),
                  card(
                      "Change Language".tr(),
                      Icon(
                        Icons.language,
                        color: appTheme.mainColor,
                      ), () {
                    setState(() {
                      context.locale = context.locale == Locale("en") ? Locale("ar") : Locale("en");
                    });
                  }),
                  SessionInfo.currentStudent.type==1 && !SessionInfo.currentStudent.approvedToBeDriver! ?
                  card("Become Driver".tr(),
                      Icon(CupertinoIcons.car_detailed, color: appTheme.mainColor),
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => becomeDriver( )),
                        );
                      }):SizedBox(),
                  //SessionInfo.currentStudent.type==2&&SessionInfo.currentStudent.approvedToBeDriver! ?
                  SessionInfo.currentStudent.type==0?
                  card(
                      "Admin Panel".tr(),
                      Icon(
                        Icons.admin_panel_settings,
                        color: appTheme.mainColor,
                      ), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => adminSelectPage()),
                    );
                  }):SizedBox(),
                  SessionInfo.currentStudent.type==2 && SessionInfo.currentStudent.approvedToBeDriver! ?
                  Column(
                    children: [
                      InkWell(
                        onTap: (){},
                        child: Container(
                          padding: EdgeInsets.only(left: 20),
                          height: height * 0.1,
                          width: width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.handshake,
                                        color: appTheme.mainColor,
                                      ),
                                      SizedBox(width: 10,),
                                      Text("Activity".tr()),
                                    ],
                                  ),
                                  Switch(
                                    activeColor: Colors.green,
                                    value: activeDriver,
                                    onChanged: (bool value) async {
                                      if(mounted){
                                        setState(() {
                                          activeDriver = value;
                                        });
                                      }
                                      if (mounted) {
                                          if (SessionInfo.currentStudent.type ==
                                              2
                                              && SessionInfo.currentStudent
                                                  .approvedToBeDriver!
                                              && SessionInfo.currentStudent
                                                  .isActive!
                                          ) {
                                            Position currentLocation = await Geolocator
                                                .getCurrentPosition();
                                            SessionInfo.currentStudent
                                                .isDriving = value;
                                            SessionInfo.currentStudent
                                                .latitude =
                                                currentLocation.latitude;
                                            SessionInfo.currentStudent
                                                .longitude =
                                                currentLocation.longitude;
                                            DataAccessObject db = DataAccessObject();
                                            await db.becomeActive_notActive(
                                                SessionInfo.currentStudent)
                                                .then((value) =>
                                                activeNotactiveFeedback(value));
                                          }
                                          else {
                                              activeDriver = !value;
                                            Message.showErrorToastMessage(
                                                "you are not allowed to be active"
                                                    .tr());
                                          }
                                      }
                                      if(mounted){
                                        setState(() {

                                        });
                                      }
                                      },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ],
                  ):SizedBox(),
                  card(
                      "Tell us anything".tr(),
                      Icon(
                        Icons.reviews,
                        color: appTheme.mainColor,
                      ), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => writeReview()),
                    );
                  }),
                ],
              )),
          InkWell(
              onTap: ()  {
                try {
                  DataAccessObject db = DataAccessObject();
                  db.logout().then((value) => SignoutFeedback(value));
                } catch (e) {
                  print(e.toString());
                }
              },
              child: Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.red,
                  width: width,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      Text(
                        "Logout".tr(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ))),
        ],
      ),
    );
  }
  SignoutFeedback(value){
    SessionInfo.clear();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => sessionHandler()),
            (route) => false);
  }
  activeNotactiveFeedback(value){
    if (!value){
      Message.showErrorToastMessage("Something wrong Happened");
      setState((){
        activeDriver=!activeDriver;
      });
    }
    else{
      if(activeDriver){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => driverMapPage()),
        );
      }
    }
  }
}
