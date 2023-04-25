import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tareqe/models/DAO.dart';
import 'package:tareqe/models/student.dart';
import 'package:tareqe/screens/userProfileInfo.dart';
import 'package:tareqe/models/theme.dart';
class passengersListPage extends StatefulWidget {
  const passengersListPage({Key? key}) : super(key: key);

  @override
  State<passengersListPage> createState() => _passengersListPageState();
}

class _passengersListPageState extends State<passengersListPage> {
  Widget card(Student passenger){
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
                  child: passenger.photo!=null && passenger.photo!.isNotEmpty?
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.transparent,
                    backgroundImage:NetworkImage(passenger.photo!)
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
                    width: width*0.5,
                    child: AutoSizeText(
                      maxLines: 1,
                      passenger.name!,
                      style: TextStyle(
                        fontSize: 24,
                        color: appTheme.mainColor,
                      ),
                    ),
                  ),

                  Container(
                    width: width*0.6,
                    child:AutoSizeText(
                      passenger.email!,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      maxLines: 1,
                    ),
                  ),
                  Container(

                    width: width*0.6,
                    child: AutoSizeText(
                      passenger.phoneNumber!,
                      maxLines: 1,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
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
            MaterialPageRoute(builder: (context) => userProfileInfo(driver: false,student:passenger)),
          ).then((value) => refresh());
        },
      ),
    );
  }
  late Future<List<Student>> passengerList;
  @override
  void initState() {
    super.initState();
    DataAccessObject db= DataAccessObject();
    passengerList =  db.getUserByType(1);
  }
  void refresh(){
    setState((){
      DataAccessObject db= DataAccessObject();
      passengerList =  db.getUserByType(1);
    });
  }
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async{
          refresh();
        },
            child: FutureBuilder<List<Student>>(
              future: passengerList,
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
                  List<Student> passengers =
                  snapshot.data as List<Student>;
                  if (passengers.isEmpty) {
                    return Center(
                      child: Text("No Data".tr()),
                    );
                  }
                  return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: passengers.length,
                      itemBuilder: (context, index) {
                        return card(passengers[index]);
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
            )
    );
  }
}
