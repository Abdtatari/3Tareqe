import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tareqe/models/theme.dart';
import 'package:tareqe/models/userFeedback.dart';

import '../models/DAO.dart';
class reviews extends StatefulWidget {
  const reviews({Key? key}) : super(key: key);

  @override
  State<reviews> createState() => _reviewsState();
}

class _reviewsState extends State<reviews> {
  late Future<List<UserFeedback>> feedbacks;
  @override
  void initState() {
    super.initState();
    DataAccessObject db= DataAccessObject();
    feedbacks =  db.getFeedbacks();
  }

  Widget card(UserFeedback feedback){
    String imgURL="";
    if (feedback.photoPath!=null){
      imgURL=feedback.photoPath!;
    }
    String title=feedback.title!;
    String content=feedback.content!;
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return  Wrap(
      children: <Widget>[
        Card(
          margin: EdgeInsets.all(8),
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Column(
                children: <Widget>[
                  Container(
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 5,right: 5,top: 5),
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  radius: 35,
                                  backgroundImage: AssetImage('assets/images/loader.gif'),
                                  child:imgURL!=null &&imgURL.isNotEmpty? CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: NetworkImage(imgURL),
                                  ): CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: AssetImage("assets/images/defaultProfile.png"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: width*0.6,
                            margin: EdgeInsets.all(10),
                            child:  Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  overflow: null,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: appTheme.mainColor,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Text(
                                  content,
                                  overflow: null,
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                )
                              ],
                            ),
                          )

                        ],
                      )
                  ),
                ],
              )),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reviews".tr()),
        centerTitle: true,
        backgroundColor: appTheme.mainColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            DataAccessObject db= DataAccessObject();
            feedbacks =  db.getFeedbacks();
          });
        },
          child: FutureBuilder<List<UserFeedback>>(
            future: feedbacks,
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
                List<UserFeedback> userFeedback =
                snapshot.data as List<UserFeedback>;
                if (userFeedback.isEmpty) {
                  return Center(
                    child: Text("No Data".tr()),
                  );
                }
                return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: userFeedback.length,
                    itemBuilder: (context, index) {
                      return card(userFeedback[index]);
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
          ))
    );
  }
}
