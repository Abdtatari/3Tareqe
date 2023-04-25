import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tareqe/screens/userProfileInfo.dart';
import 'package:tareqe/models/theme.dart';

import '../models/DAO.dart';
import '../models/student.dart';
class driverListPage extends StatefulWidget {
  const driverListPage({Key? key}) : super(key: key);

  @override
  State<driverListPage> createState() => _driverListPageState();
}

class _driverListPageState extends State<driverListPage> {
  Widget card(Student driver){
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
      return Container(
        width: width ,
        height: height*0.20,
        child: InkWell(
          child: Card(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: width*0.25,
                  margin: EdgeInsets.all(5),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 65,
                    backgroundImage: AssetImage('assets/images/loader.gif'),
                    child: driver.photo!=null && driver.photo!.isNotEmpty?
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.transparent,
                      backgroundImage:NetworkImage(driver.photo!)
                      ,
                    ):
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.transparent,
                      backgroundImage:AssetImage("assets/images/defaultProfile.png")
                      ,
                    ),
                  ),
                ),
                SizedBox(width: width*0.05,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: width*0.6,
                      child: AutoSizeText(
                        driver.name!,
                        style: TextStyle(
                          fontSize: 24,
                          color: appTheme.mainColor,
                        ),
                        maxLines: 1,
                      ),
                    ),

                    Container(
                      width: width*0.6,
                      child:AutoSizeText(
                        driver.email!,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      width: width*0.6,
                      child: AutoSizeText(
                        driver.phoneNumber!,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        maxLines: 1,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => userProfileInfo(driver: true,student: driver,)),
            ).then((value) => refresh());
          },
        ),
      );
  }
  refresh(){
    setState((){
      DataAccessObject db= DataAccessObject();
      driverList =  db.getUserByType(2);
    });
  }
  late Future<List<Student>> driverList;
  @override
  void initState() {
    super.initState();
    DataAccessObject db= DataAccessObject();
    driverList =  db.getUserByType(2);
  }
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async{
          refresh();
        },
        child: FutureBuilder<List<Student>>(
          future: driverList,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  ));
            } else if (snapshot.hasData) {
              List<Student> drivers =
              snapshot.data as List<Student>;
              if (drivers.isEmpty) {
                return Center(
                  child: Text("No Data".tr()),
                );
              }
              return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    return card(drivers[index]);
                  });
            } else if (snapshot.data!.isEmpty) {
              return Center(
                child: Text("No Data".tr()),
              );
            } else {
              return Center(
                child: Text("Error".tr()),
              );
            }
          },
        ));
  }
}
