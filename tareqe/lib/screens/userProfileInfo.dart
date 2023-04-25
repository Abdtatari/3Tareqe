import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tareqe/custom_widget/message.dart';
import 'package:tareqe/models/DAO.dart';
import 'package:tareqe/models/student.dart';
import 'package:tareqe/models/theme.dart';
import '../custom_widget/DisplayImage.dart';
class userProfileInfo extends StatefulWidget {
  final bool driver;
  final Student student;
  const userProfileInfo({Key? key,required this.driver,required this.student}) : super(key: key);

  @override
  State<userProfileInfo> createState() => _userProfileInfoState();
}

class _userProfileInfoState extends State<userProfileInfo> {
  DeleteFeedback(){
    setState(() {
      isSyncing=false;
    });
    Navigator.pop(context);
    Message.showShortToastMessage("Deleted".tr());

  }

  bool isSyncing = false;
  String type ="Passenger";
  String approvedStatus ="Pending";
  Widget buildUserInfoDisplay(String getValue, String title) =>
      Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              SizedBox(
                height: 1,
              ),
              Container(
                  width: 350,
                  height: 40,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ))),
                  child: Row(children: [
                    Expanded(
                            child: Text(
                              getValue,
                              style: TextStyle(fontSize: 16, height: 1.4, color: appTheme.mainColor,),
                            )),
                  ]))
            ],
          ));
  @override
  Widget build(BuildContext context) {
    if (widget.student.approvedToBeDriver!){
      approvedStatus="Approved";
    }
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("User Information".tr()),
        centerTitle: true,
        backgroundColor: appTheme.mainColor,
      ),
      body:ModalProgressHUD(

        inAsyncCall: isSyncing,
        child: SingleChildScrollView(child: Column(
          children: [
            Row(
              mainAxisAlignment:  context.locale == Locale("en")?MainAxisAlignment.end:MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(right: width*0.05,left: width*0.05,top: width*0.05),
                  child:  InkWell(
                    child: Icon(CupertinoIcons.delete,
                        color: Colors.red, size: 35),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                                "Delete warning".tr()),
                            content: Text(
                                "Are you sure you want to delete this account?"
                                    .tr()),
                            actions: [
                              TextButton(
                                child: Text(
                                  "Delete".tr(),
                                  style: TextStyle(
                                      color: Colors.red),
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  setState(() {
                                    isSyncing=true;
                                  });
                                  DataAccessObject db= DataAccessObject();
                                  await db.deleteAccount(widget.student.email).then((value) =>DeleteFeedback());
                                },
                              ),
                              TextButton(
                                child:
                                Text("Cancel".tr()),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
            SizedBox(height: 30,),
            DisplayImage(
              imagePath: widget.student.photo!=null && widget.student.photo!.isNotEmpty?widget.student.photo!:"assets/images/defaultProfile.png",
              showEditIcons: false,
              onPressed: () {
              },
            ),
            SizedBox(height: 20,),
            buildUserInfoDisplay(widget.student.name!, 'Name'.tr()),
            buildUserInfoDisplay(widget.student.phoneNumber!, 'Phone'.tr(),),
            buildUserInfoDisplay(widget.student.email!, 'Email'.tr(),),
            buildUserInfoDisplay(widget.student.gender!.tr(), 'Gender'.tr(),),
            buildUserInfoDisplay(type.tr(), 'Account Type'.tr(),),
            widget.driver?
            Visibility(
                visible: widget.driver,
                child: Column(
                  children: [
                    buildUserInfoDisplay(widget.student.car!.carType!,"Car Brand".tr()),
                    Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Color".tr(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          height: 1,
                        ),
                        Container(
                            width: 350,
                            height: 40,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey,
                                      width: 1,
                                    ))),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                     Icon(size:40,CupertinoIcons.car_detailed,color: Color((int.parse(widget.student.car!.carColor!,))),),
                            ]))
                      ],
                    )),
                     buildUserInfoDisplay(widget.student.car!.numberOfSeat.toString(),"Number of Seats".tr(),),
                    buildUserInfoDisplay(widget.student.car!.carNumber!,"Car Number".tr(),),
                    buildUserInfoDisplay(widget.student.licence!,"Driving licence Number".tr(),),
                    buildUserInfoDisplay(approvedStatus.tr(),"Request Status".tr(),),

                    SizedBox(
                      width: width*0.4,
                      child:  ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: appTheme.buttosColor),
                          onPressed: (){
                            showDialog<Image>(
                              context: context,
                              builder: (BuildContext
                              context) =>
                                  AlertDialog(
                                    content: Container(
                                      width: width,
                                      height: width,
                                      child: PhotoView(
                                        backgroundDecoration:
                                        BoxDecoration(
                                            color: Colors
                                                .transparent),
                                        imageProvider:
                                        NetworkImage(widget.student.licenceImg!),
                                      ),
                                    ),
                                  ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image),
                              Text("Show Licence".tr(),)
                          ],)
                      ),
                    ),
                  ],
                )
            ):
            SizedBox(),
          ],
        ),),
      )
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.student.type==2){
      type="Driver";
    }
    else if(widget.student.type==0) {
      type="Admin";
    }
  }
}
