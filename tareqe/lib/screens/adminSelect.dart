import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tareqe/screens/adminRequestsPage.dart';
import 'package:tareqe/screens/adminUsersList.dart';
import 'package:tareqe/screens/reviews.dart';
import 'package:tareqe/models/theme.dart';
class adminSelectPage extends StatefulWidget {
  const adminSelectPage({Key? key}) : super(key: key);

  @override
  State<adminSelectPage> createState() => _adminSelectPageState();
}

class _adminSelectPageState extends State<adminSelectPage> {
  List<String> categories =[];
  List<IconData> icons=[];
  @override
  void initState() {
    super.initState();
    categories.add("Users".tr());
    icons.add(Icons.supervised_user_circle_sharp);

    categories.add("Requests".tr());
    icons.add(Icons.verified_user);
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Widget gridCard(int index) {
      return InkWell(
        child: Container(
          height: height * 0.25,
          width: width*0.4,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  width: width * 0.25,
                  height: height * 0.05,
                  child: Icon(icons[index],color: appTheme.mainColor,size: 60,)
              ),
              Text(categories[index],
                  style: TextStyle(color: Colors.black))

            ],
          ),
        ),
        onTap: () {
          index==0?
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => adminUsersPage()),
          ):
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => adminRequestsPage()),
          );
        },
      );
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: appTheme.mainColor,
          title: Text("Admin Panel".tr()),
          centerTitle: true,
          actions: [
            Container(
              margin: EdgeInsets.only(left: width*0.05,right: width*0.05),
              child: InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => reviews()),
                  );
                },
                child: Icon(Icons.feedback_sharp,color: Colors.white,),
              )
            )
          ],
        ),
        body:  Container(
          color: Color.fromRGBO(239, 239, 239, 1),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: SizedBox()),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      gridCard(0),
                      gridCard(1),
                  ],),
                ),
                Expanded(child: SizedBox()),
              ]
          ),
        )
    );
  }
}
