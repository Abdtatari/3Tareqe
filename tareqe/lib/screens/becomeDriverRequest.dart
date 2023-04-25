import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tareqe/custom_widget/message.dart';
import 'package:tareqe/models/DAO.dart';
import 'package:tareqe/models/sessionInfo.dart';
import 'package:tareqe/models/theme.dart';
import 'package:tareqe/screens/login.dart';

import '../custom_widget/custom_form_button.dart';
import '../custom_widget/custom_input_field.dart';
import '../custom_widget/page_header.dart';
import '../custom_widget/page_heading.dart';
import '../models/car.dart';
import '../models/student.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class becomeDriver extends StatefulWidget {
  const becomeDriver({Key? key}) : super(key: key);

  @override
  State<becomeDriver> createState() => _becomeDriverState();
}

class _becomeDriverState extends State<becomeDriver> {
  bool isSyncing =false;
  final _becomeDriverFormKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController carNumberController = TextEditingController();
  TextEditingController carColorController = TextEditingController();

  TextEditingController numberOfSeatController=TextEditingController();
  TextEditingController engineCapacityController=TextEditingController();
  TextEditingController carTypeController=TextEditingController();

  TextEditingController licenceNumbeController = TextEditingController();
  String licencePath="";

  Student? currentUser = SessionInfo.currentStudent!;
   late String? gender= currentUser?.gender!;
   late ImageProvider image;

  Color placeholderColor = Color(0xfff1a200);
  Color selectedColor = Color(0xff000000);
  List<Color> colors=[
    Color(0xff000000),
    Color(0xffffd700),
    Color(0xffc0c0c0),
    Color(0xff9c27b0),
    Color(0xff2196f3),
    Color(0xff000080),
    Color(0xfff44336),
    Color(0xff4caf50),
  ];
  bool colorPickerFlag=false;


  @override
  void initState() {
    super.initState();
    nameController.text=currentUser!.name!;
    emailController.text=currentUser!.email!;
    phoneController.text=currentUser!.phoneNumber!;
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser?.photo != null && currentUser!.photo!.isNotEmpty){
     image=NetworkImage(currentUser!.photo!);
    }
    else{
      image=const AssetImage("assets/images/defaultProfile.png");
    }
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Become Driver".tr()),
        backgroundColor: appTheme.mainColor,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isSyncing,
        child:SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20),),
                  ),
                  child: Column(
                    children: [
                      PageHeading(title: 'Student Information'.tr(),),
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage:image ,
                        ),
                      ),
                      const SizedBox(height: 16,),
                      CustomInputField(
                        keyboardType: TextInputType.text,
                        enabled: false,
                          controller: nameController,
                          labelText: 'Name'.tr(),
                          hintText: 'Your name'.tr(),
                          isDense: true,
                          validator: (textValue) {
                            if(textValue == null || textValue.isEmpty) {
                              return 'Name field is required!'.tr();
                            }
                            return null;
                          }
                      ),
                      const SizedBox(height: 16,),
                      CustomInputField(
                        keyboardType: TextInputType.emailAddress,
                          enabled: false,
                          controller: emailController,
                          labelText: 'Email'.tr(),
                          hintText: 'Your university email'.tr(),
                          isDense: true,
                          validator: (textValue) {
                            if(textValue == null || textValue.isEmpty) {
                              return 'Email is required!'.tr();
                            }
                            if(!EmailValidator.validate(textValue)) {
                              return 'Please enter a valid email'.tr();
                            }
                            if (!textValue.toLowerCase().endsWith("edu.jo")){
                              return 'Please enter a university email'.tr();
                            }
                            return null;
                          }
                      ),
                      const SizedBox(height: 16,),
                      CustomInputField(
                          keyboardType: TextInputType.phone,
                          enabled: false,
                          controller: phoneController,
                          labelText: 'Phone.'.tr(),
                          hintText: 'Your phone number'.tr(),
                          isDense: true,
                          validator: (textValue) {
                            if(textValue == null || textValue.isEmpty) {
                              return 'Contact number is required!'.tr();
                            }
                            return null;
                          }
                      ),
                      const SizedBox(height: 16,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 5,right: 5),
                            width: width*0.4,
                            height: 50,
                            child: RadioListTile(
                              title: AutoSizeText("Male".tr(),maxLines: 1,),
                              value: "Male",
                              groupValue: gender,
                              onChanged: null,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5,right: 5),
                            width: width*0.4,
                            height: 50,
                            child: RadioListTile(
                              title: AutoSizeText("Female".tr(),maxLines: 1,),
                              value: "Female",
                              groupValue: gender,
                              onChanged: null
                            ),
                          )

                        ],
                      ),
                      const SizedBox(height: 16,),
                      Form(
                        key:_becomeDriverFormKey,
                        child:
                        Column(
                        children: [
                          Divider(color: Colors.black,),
                          PageHeading(title: 'Car Information'.tr(),),
                          const SizedBox(height: 16,),
                          CustomInputField(
                              keyboardType: TextInputType.text,
                              controller: carTypeController,
                              labelText: 'Car Brand and Name'.tr(),
                              hintText: 'Your Brand and Name'.tr(),
                              isDense: true,
                              validator: (textValue) {
                                if(textValue == null || textValue.isEmpty) {
                                  return 'Car Brand and Name required'.tr();
                                }
                                return null;
                              }
                          ),
                          const SizedBox(height: 16,),
                          CustomInputField(
                              keyboardType: TextInputType.text,
                              controller: carNumberController,
                              labelText: 'Car Number'.tr(),
                              hintText: 'Your Car Number'.tr(),
                              isDense: true,
                              validator: (textValue) {
                                if(textValue == null || textValue.isEmpty) {
                                  return 'Car Number is required!'.tr();
                                }
                                return null;
                              }
                          ),
                          const SizedBox(height: 16,),
                          Container(
                            margin: EdgeInsets.only(left: width*0.1,right: width*0.1),
                            child: Stack(
                              children: [
                                Column(
                                  children: [
                                    Align(
                                      alignment: context.locale ==  Locale("en") ?Alignment.centerLeft:Alignment.centerRight,
                                      child: Text("Car Color".tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                    ),
                                    Container(
                                      width: width*0.8,
                                      height: height*0.2,
                                      child:
                                      BlockPicker(
                                        useInShowDialog: false,
                                        availableColors: colors,
                                        onColorChanged: (value){
                                          setState(() {
                                            selectedColor=value;
                                          });
                                        },
                                        pickerColor:placeholderColor,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text("Current".tr()+" "),
                                            Container(
                                              width: 25,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                  color: selectedColor,
                                                  borderRadius: BorderRadius.circular(25)
                                              ),
                                            ),
                                          ],
                                        ),
                                        InkWell(
                                            child: Container(
                                              width: 50,
                                              height: 50,
                                              child: Image.asset("assets/images/color_logo.png"),
                                            ),
                                            onTap: (){
                                              setState((){
                                                colorPickerFlag = !colorPickerFlag;
                                              });
                                            }
                                        ),
                                      ],
                                    ),
                                    colorPickerFlag?
                                    ColorPicker(
                                        pickerAreaHeightPercent: 0.3,
                                        enableAlpha: false,
                                        labelTypes: [],
                                        pickerColor: selectedColor,
                                        onColorChanged: (value){
                                          setState((){
                                            selectedColor=value;
                                          });
                                        })
                                        :SizedBox(),
                                    const SizedBox(height: 16,),
                                    Container(width: width*0.83,
                                      child:
                                      Divider(color: Colors.black45,thickness: 1,),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),

                          const SizedBox(height: 16,),
                          CustomInputField(
                              keyboardType: TextInputType.number,
                              numeric: true,
                              controller: numberOfSeatController,
                              labelText: 'Number Of seats.'.tr(),
                              hintText: 'your Number Of seats'.tr(),
                              isDense: true,
                              validator: (textValue) {
                                if(textValue == null || textValue.isEmpty) {
                                  return 'Number Of seats required'.tr();
                                }
                                return null;
                              }
                          ),
                          const SizedBox(height: 16,),
                          Divider(color: Colors.black,),
                          const SizedBox(height: 16,),
                          PageHeading(title: 'Licence Information'.tr(),),
                          const SizedBox(height: 16,),
                          CustomInputField(
                              keyboardType: TextInputType.text,
                              controller: licenceNumbeController,
                              labelText: 'Licence Number'.tr(),
                              hintText: 'your Licence Number'.tr(),
                              isDense: true,
                              validator: (textValue) {
                                if(textValue == null || textValue.isEmpty) {
                                  return 'Licence Number required'.tr();
                                }
                                return null;
                              }
                          ),
                          const SizedBox(height: 16,),
                          Container(
                            margin: EdgeInsets.only(left: width*0.1,right:width*0.1),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: (){
                                    ImagePicker.platform.pickImage(source: ImageSource.gallery).then((value) => ({
                                      setState(() {
                                        licencePath=value!.path;
                                      })
                                    }));
                                  },
                                  child: Row(children: [
                                    Icon(Icons.upload,color: Colors.white,),
                                    Text("Upload Licence".tr())
                                  ],),
                                  style: ElevatedButton.styleFrom(backgroundColor: appTheme.buttosColor),
                                ),
                                licencePath.isEmpty?
                                AutoSizeText("No File".tr()):
                                Container(
                                  width: width*0.4,
                                  child: AutoSizeText(
                                    licencePath.split("/")[licencePath.split("/").length-1],
                                    maxLines: 1,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(width: width*0.83,
                            child:
                            Divider(color: Colors.black45,thickness: 1,),
                          ),
                          const SizedBox(height: 22,),
                          CustomFormButton(innerText: 'Submit Request'.tr(), onPressed: () async {
                            if (_becomeDriverFormKey.currentState!.validate()){
                              if (licencePath.isNotEmpty){
                                setState((){
                                  isSyncing=true;
                                });
                                Car newCar = Car(
                                    carColor: selectedColor.value.toString(),
                                    carNumber: carNumberController.text,
                                    carType: carTypeController.text,
                                    numberOfSeat: int.parse(numberOfSeatController.text)
                                );
                                currentUser?.car=newCar;
                                currentUser?.licence=licenceNumbeController.text;
                                currentUser?.licenceImg=licencePath;
                                currentUser?.type=2;

                                DataAccessObject db= DataAccessObject.instance;
                                await db.sendBecomeDriverRequest(currentUser!).then((value) => feedback(value,currentUser));
                              }
                              else {
                                Message.showErrorToastMessage("Please add driving Licence photo".tr());
                              }
                            }
                            else{
                              print(_becomeDriverFormKey.currentState.toString());
                            }
                          },),
                          const SizedBox(height: 18,),
                        ],
                      ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
  feedback(value,currentUser){
    if (value){
      SessionInfo.currentStudent=currentUser;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                "Request received".tr()),
            content: Text(
                "we received your request,and working to review it as soon as possible".tr()
                    .tr()),
            actions: [
              TextButton(
                child:
                Text("OK".tr()),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              )
            ],
          );
        },
      );
    }
    setState((){
      isSyncing=false;
    });
  }
}
