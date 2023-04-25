import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tareqe/custom_widget/custom_form_button.dart';
import 'package:tareqe/custom_widget/message.dart';
import 'package:tareqe/models/DAO.dart';
import 'package:tareqe/models/sessionInfo.dart';

import '../custom_widget/DisplayImage.dart';
import 'package:tareqe/models/theme.dart';

import '../models/student.dart';

class profile extends StatefulWidget {
  const profile({Key? key}) : super(key: key);

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  final _FormKey = GlobalKey<FormState>();

  String imgSrc="assets/images/defaultProfile.png";
  String approvedStatus ="Pending";
  bool edit=false;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool isSyncing=false;

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
                              textAlign:TextAlign.center,
                              getValue,
                              style: TextStyle(fontSize: 16, height: 1.4, color: appTheme.mainColor,fontWeight: FontWeight.bold,),
                            )),
                  ]))
            ],
          ));


  @override
  void initState() {
    nameController.text=SessionInfo.currentStudent!.name!;
    phoneController.text=SessionInfo.currentStudent!.phoneNumber!;
    if(SessionInfo.currentStudent.photo!=null && SessionInfo.currentStudent.photo!.isNotEmpty){
      imgSrc=SessionInfo.currentStudent.photo!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if (SessionInfo.currentStudent.approvedToBeDriver!){
      approvedStatus="Approved";
    }
    String type;

    if (SessionInfo.currentStudent.type==2){
      type="Driver";
    }
    else if (SessionInfo.currentStudent.type==0){
      type="Admin";
    }
    else {
      type="Passenger";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile".tr()),
        centerTitle: true,
        backgroundColor: appTheme.mainColor,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isSyncing,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30,),
              Container(
                margin: EdgeInsets.only(left:25,right:25),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      child: Icon(Icons.edit,color: appTheme.mainColor,size: 30,),
                      onTap: (){
                        setState((){
                          if (edit){
                            imgSrc=SessionInfo.currentStudent.photo!;
                          }
                          edit=!edit;
                        });
                      },
                    )
                  ],
                ),
              ),
              InkWell(
                child: DisplayImage(
                  showEditIcons: edit,
                  imagePath:imgSrc,
                  onPressed: () {
                  },
                ),
                onTap: () async {
                  if (edit){
                    final  img = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
                    setState((){
                      imgSrc=img!.path;
                    });
                  }
                },
              ),
              SizedBox(height: 20,),
              Form(
                  key: _FormKey,
                  child: Column(children: [
                    edit?
                    Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Name".tr(),
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
                                child:
                                TextFormField(
                                    controller:nameController,
                                    validator: (textValue) {
                                      if(textValue == null || textValue.isEmpty) {
                                        return 'Name field is required!'.tr();
                                      }
                                      return null;
                                    }
                                ))
                          ],
                        )):
                    buildUserInfoDisplay(SessionInfo.currentStudent.name!, 'Name'.tr()),
                    edit?
                    Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Phone".tr(),
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
                                child:
                                TextFormField(controller:phoneController,
                                    keyboardType: TextInputType.phone,
                                    validator: (textValue) {
                                      if(textValue == null || textValue.isEmpty) {
                                        return 'Contact number is required!'.tr();
                                      }
                                      return null;
                                    }
                                ))
                          ],
                        )):
                    buildUserInfoDisplay(SessionInfo.currentStudent.phoneNumber!, 'Phone'.tr(),),
              ],)),

              buildUserInfoDisplay(SessionInfo.currentStudent.email!, 'Email'.tr(),),
              buildUserInfoDisplay(SessionInfo.currentStudent.gender!, 'Gender'.tr(),),
              buildUserInfoDisplay(type.tr(), 'Account Type'.tr(),),
              SessionInfo.currentStudent.type==2?
              Visibility(
                  visible: SessionInfo.currentStudent.type==2,
                  child: Column(
                    children: [
                      buildUserInfoDisplay(SessionInfo.currentStudent.car!.carType!,"Car Brand".tr()),
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
                                        Icon(size:40,CupertinoIcons.car_detailed,color: Color((int.parse(SessionInfo.currentStudent.car!.carColor!,))),),
                                      ]))
                            ],
                          )),
                      buildUserInfoDisplay(SessionInfo.currentStudent.car!.numberOfSeat.toString(),"Number of Seats".tr(),),
                      buildUserInfoDisplay(SessionInfo.currentStudent.car!.carNumber!,"Car Number".tr(),),
                      buildUserInfoDisplay(SessionInfo.currentStudent.licence!,"Driving licence Number".tr(),),
                      buildUserInfoDisplay(approvedStatus.tr(),"Request Status".tr(),),
                      SizedBox(height: height*0.03,),
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
                                          NetworkImage(SessionInfo.currentStudent.licenceImg!),
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
              SizedBox(height:height*0.05,),
              edit?Column(
                children: [
                  CustomFormButton(innerText: "Save".tr(), onPressed: () async {
                    if (_FormKey.currentState!.validate()){
                      setState((){
                        isSyncing = true;
                      });
                      Student profile=SessionInfo.currentStudent;
                      profile.name= nameController.text;
                      profile.phoneNumber=phoneController.text;
                      if (imgSrc.contains("assets/images/")){
                        profile.photo="";
                      }
                      else {
                        profile.photo = imgSrc;
                      }
                      DataAccessObject db = DataAccessObject();
                      await db.updateProfile(profile).then((value) => feedback(value,profile));
                    }
                  }),
                  SizedBox(height:height*0.05,),
                ],
              ):SizedBox()

            ],
          ),
        ),
      )
    );
  }
  feedback(value,newProfile){
    if (value){
      setState(() {
        SessionInfo.currentStudent=newProfile;
        edit=false;
      });
      Message.showLongToastMessage("Change Saved".tr());
    }
    else{
      Message.showErrorToastMessage("Change not Saved".tr());
    }
    setState((){
      isSyncing = false;
    });
  }
}
