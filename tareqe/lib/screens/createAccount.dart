import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tareqe/custom_widget/message.dart';
import 'package:tareqe/models/DAO.dart';
import 'package:tareqe/models/car.dart';
import 'package:tareqe/models/student.dart';
import 'package:tareqe/models/theme.dart';
import 'package:tareqe/screens/login.dart';

import '../custom_widget/custom_form_button.dart';
import '../custom_widget/custom_input_field.dart';
import '../custom_widget/page_header.dart';
import '../custom_widget/page_heading.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  File? _profileImage;

  final _signupFormKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController rePasswordController = TextEditingController();
  bool isSyncing=false;
  String gender="Male";

  Future _pickProfileImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return;

      final imageTemporary = File(image.path);
      setState(() => _profileImage = imageTemporary);
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: isSyncing,
        child:Scaffold(
          backgroundColor: const Color(0xffEEF1F3),
          body: SingleChildScrollView(
            child: Form(
              key: _signupFormKey,
              child: Column(
                children: [
                  const PageHeader(),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20),),
                    ),
                    child: Column(
                      children: [
                        PageHeading(title: 'Sign-up'.tr(),),
                        SizedBox(
                          width: 130,
                          height: 130,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: _pickProfileImage,
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade400,
                                        border: Border.all(color: Colors.white, width: 3),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_sharp,
                                        color: Colors.white,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16,),
                        CustomInputField(
                            keyboardType: TextInputType.text,
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
                              // if (!textValue.toLowerCase().endsWith("edu.jo")){
                              //   return 'Please enter a university email'.tr();
                              // }
                              return null;
                            }
                        ),
                        const SizedBox(height: 16,),
                        CustomInputField(
                          keyboardType: TextInputType.phone,
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
                                onChanged: (value){
                                  setState(() {
                                    gender=value!;
                                  });
                                },
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
                                onChanged: (value){
                                  setState(() {
                                    gender=value!;
                                  });
                                },
                              ),
                            )

                          ],
                        ),
                        const SizedBox(height: 16,),
                        Container(width: width*0.83,
                          child:
                          Divider(color: Colors.black45,thickness: 1,),
                        ),
                        const SizedBox(height: 16,),
                        CustomInputField(
                          keyboardType: TextInputType.text,
                          controller: passwordController,
                          labelText: 'Password'.tr(),
                          hintText: 'Your password'.tr(),
                          isDense: true,
                          obscureText: true,
                          validator: (textValue) {
                            if(textValue == null || textValue.isEmpty) {
                              return 'Password is required!'.tr();
                            }
                            if (textValue.length<6){
                              return 'password should be at least 6 characters'.tr();
                            }
                            return null;
                          },
                          suffixIcon: true,
                        ),
                        const SizedBox(height: 16,),
                        CustomInputField(
                          keyboardType: TextInputType.text,
                          controller: rePasswordController,
                          labelText: 'Confirm Password'.tr(),
                          hintText: 'Your password again'.tr(),
                          isDense: true,
                          obscureText: true,
                          validator: (textValue) {
                            if(textValue == null || textValue.isEmpty) {
                              return 'Password is required!'.tr();
                            }
                            if (textValue!=passwordController.text){
                              return "passwords does not match".tr();
                            }
                            return null;
                          },
                          suffixIcon: true,
                        ),
                        const SizedBox(height: 22,),
                        CustomFormButton(innerText: 'Signup'.tr(), onPressed: (){
                            _handleSignupUser();
                        },),
                        const SizedBox(height: 18,),
                        SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Already have an account ? '.tr(), style: TextStyle(fontSize: 13, color: Color(0xff939393), fontWeight: FontWeight.bold),),
                              GestureDetector(
                                onTap: () => {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const login()))
                                },
                                child: Text('Log-in'.tr(), style: TextStyle(fontSize: 15, color: appTheme.mainColor, fontWeight: FontWeight.bold),),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ),
    );
  }

  Future<void> _handleSignupUser() async {
    // signup user
    if (_signupFormKey.currentState!.validate()) {
      setState((){
        isSyncing = true;
      });
      Student newUser = Student(
          isDriving:false,
          approvedToBeDriver: false,
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text,
          gender: gender,
          photo: _profileImage?.path,
          type: 1,
          phoneNumber: phoneController.text,
          isActive:true,
          car: Car()
      );
      await newUser.signup().then((value) => {
       createAccountFeedback(value)
      });
    }
  }
  createAccountFeedback(value) async {
    setState((){
      isSyncing = false;
    });
    if (value){
      DataAccessObject db= DataAccessObject.instance;
      await db.sendEmailVerification().then((value) => db.logout().then((value) => sendVerificationEmailFeedback(value)));
    }
  }
  sendVerificationEmailFeedback(value){
    if (value){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                "Verification Email".tr()),
            content: Text(
                "We will send a verification email to you, you need to verify your email before Login".tr()
                    .tr()),
            actions: [
              TextButton(
                child:
                Text("OK".tr()),
                onPressed: () {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (context) => const sessionHandler()),
                        (route) => false);
                },
              )
            ],
          );
        },
      );
    }
  }
}
