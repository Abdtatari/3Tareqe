import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tareqe/custom_widget/message.dart';
import 'package:tareqe/models/DAO.dart';

import '../custom_widget/DisplayImage.dart';
import 'package:tareqe/models/theme.dart';

import '../models/student.dart';
class requestDetails extends StatefulWidget {
  final Student request ;
  const requestDetails({Key? key,required this.request}) : super(key: key);

  @override
  State<requestDetails> createState() => _requestDetailsState();
}

class _requestDetailsState extends State<requestDetails> {
  String type = "Passenger";
  String imgSrc ="assets/images/defaultProfile.png";
  bool isSyncing=false;
  final _licenceFormKey = GlobalKey<FormState>();
  DateTime? expirationDate;

  @override
  Widget build(BuildContext context) {
    if (widget.request.type==2){
      type="Driver";
    }
    else if (widget.request.type==0){
      type="Admin";
    }
    if (widget.request.photo!=null && widget.request.photo!.isNotEmpty){
      imgSrc=widget.request.photo!;
    }
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text("Request Details".tr()),
          centerTitle: true,
          backgroundColor: appTheme.mainColor,
        ),
        body: ModalProgressHUD(

          inAsyncCall: isSyncing,
          child: SingleChildScrollView(
            child: Column(
            children: [
              SizedBox(height: height*0.05,),
              DisplayImage(
                imagePath: imgSrc,
                showEditIcons: false,
                onPressed: () {
                },
              ),
              SizedBox(height: 20,),
              buildUserInfoDisplay(widget.request.name!, 'Name'.tr()),
              buildUserInfoDisplay(widget.request.phoneNumber!, 'Phone'.tr(),),
              buildUserInfoDisplay(widget.request.email!, 'Email'.tr(),),
              buildUserInfoDisplay(widget.request.gender!.tr(), 'Gender'.tr(),),
              buildUserInfoDisplay(type.tr(), 'Account Type'.tr(),),
              buildUserInfoDisplay(widget.request.car!.carType!,"Car Brand".tr()),
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
                                Icon(size:40,CupertinoIcons.car_detailed,color: Color((int.parse(widget.request.car!.carColor!,))),),
                              ]))
                    ],
                  )),
              buildUserInfoDisplay(widget.request.car!.numberOfSeat!.toString(),"Number of Seats".tr(),),
              buildUserInfoDisplay(widget.request.car!.carNumber!,"Car Number".tr(),),
              buildUserInfoDisplay(widget.request.licence!,"Driving licence Number".tr(),),
              SizedBox(height: 15,),
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
                                  NetworkImage(widget.request.licenceImg!),
                                ),
                              ),
                            ),
                      );
                    },
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image),
                        Text("Show Licence".tr(),)
                    ],)
                ),
              ),
              SizedBox(height: 15,),
              Container(
                width: width*0.9,
                child: Divider(color: Colors.grey,thickness: 1,),
              ),
              SizedBox(height: 15,),
            Padding(
                padding: EdgeInsets.only(bottom: 10,left: 30,right: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(
                        "Licence expiration date".tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color:expirationDate==null?Colors.red: Colors.green,
                        ),
                      ),
                      expirationDate==null?
                      Text("*",style: TextStyle(color: Colors.red),):
                          SizedBox()
                    ],),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child:  SizedBox(
                        height: 100,
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: DateTime.now(),
                          maximumYear: DateTime.now().year+10,
                          dateOrder: DatePickerDateOrder.dmy,
                          minimumYear: DateTime.now().year-10,
                          onDateTimeChanged: (DateTime newDateTime) {
                            setState((){
                              expirationDate=newDateTime;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )),
              SizedBox(height: 15,),
              Container(
                width: width*0.9,
                child: Divider(color: Colors.grey,thickness: 1,),
              ),
              SizedBox(height: 15,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                    onPressed: () {
                      if (expirationDate!=null){
                      setState((){
                        isSyncing=true;
                      });
                      widget.request.type=2;
                      widget.request.approvedToBeDriver=true;
                      widget.request.licenceExpirationDate=expirationDate.toString();
                      DataAccessObject db=DataAccessObject();
                      db.updateRequestStatus(widget.request).then((value) => feedback(value,"Accepted Successfully"));
                    }
                      else{
                        Message.showErrorToastMessage("Please enter the licence Expiration Date".tr());
                      }
                      },
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 18,
                        ),
                        Text("Accept".tr()),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 40,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    onPressed: () {
                      setState((){
                        isSyncing=true;
                      });
                      widget.request.type=1;
                      widget.request.approvedToBeDriver=false;
                      DataAccessObject db=DataAccessObject();
                      db.updateRequestStatus(widget.request).then((value) => feedback(value,"Declined Successfully"));
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.remove_circle,
                          color: Colors.white,
                          size: 18,
                        ),
                        Text("Decline".tr()),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30,),
            ],
          ),
          ),
        )
    );
  }
  feedback(value,message){
    if (value){
      Message.showLongToastMessage(message);
      Navigator.pop(context,true);
    }
    setState(() {
      isSyncing=false;
    });
  }
}
