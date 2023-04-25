import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tareqe/screens/requestDetails.dart';
import 'package:tareqe/models/theme.dart';

import '../models/DAO.dart';
import '../models/student.dart';
class adminRequestsPage extends StatefulWidget {
  const adminRequestsPage({Key? key}) : super(key: key);

  @override
  State<adminRequestsPage> createState() => _adminRequestsPageState();
}

class _adminRequestsPageState extends State<adminRequestsPage> {
  late Future<List<Student>> requests;


  @override
  void initState() {
    super.initState();
    DataAccessObject db= DataAccessObject();
    requests =  db.getDriversRequest();
  }

  refresh(){
    setState(() {
      DataAccessObject db= DataAccessObject();
      requests =  db.getDriversRequest();
    });
  }

  Widget card(Student request){
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      width: width ,
      height: height*0.20,
      child: InkWell(
        child: Card(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: width*0.5,
                    child: Text(
                      request.name!,
                      style: TextStyle(
                        fontSize: 20,
                        color: appTheme.mainColor,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),

                  Container(
                    width: width*0.5,
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.phone,color: appTheme.mainColor,),
                        Text(
                          request.phoneNumber!,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ) ,
                  ),
                 Row(
                   children: [
                     Icon(Icons.newspaper,color: appTheme.mainColor,),
                     Text(
                       request.licence!,
                       style: TextStyle(fontSize: 14, color: Colors.grey),
                     ),
                   ],
                 )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Icon(Icons.check_circle_outline,color: Colors.green,size: 40,),
                SizedBox(width: width*0.05,),
                Icon(Icons.cancel_outlined,color: Colors.red,size: 40,),
                ],
              )
            ],
          ),
        ),
        onTap: () async {
           await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => requestDetails(request:request)),
          ).then((value) => refresh());
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Requests".tr()),
        centerTitle: true,
        backgroundColor: appTheme.mainColor,
      ),
      body:  RefreshIndicator(
        onRefresh: ()async{
        refresh();
        },
        child: FutureBuilder<List<Student>>(
          future: requests,
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
              List<Student> requests =
              snapshot.data as List<Student>;
              if (requests.isEmpty) {
                return Center(
                  child: Text("No Data".tr()),
                );
              }
              return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    return card(requests[index]);
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
      ),
    );
  }
}
