import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tareqe/custom_widget/message.dart';
import 'package:tareqe/models/DAO.dart';
import 'package:tareqe/models/student.dart';
import 'package:tareqe/models/theme.dart';
import 'package:tareqe/screens/createAccount.dart';
import 'package:tareqe/screens/mapPage.dart';

import '../custom_widget/custom_form_button.dart';
import '../custom_widget/custom_input_field.dart';
import '../custom_widget/page_header.dart';
import '../custom_widget/page_heading.dart';
import 'forgetPassword.dart';


class sessionHandler extends StatefulWidget {
  const sessionHandler({Key? key}) : super(key: key);

  @override
  State<sessionHandler> createState() => _sessionHandler();
}

class _sessionHandler extends State<sessionHandler> {
  @override
  Widget build(BuildContext context) {
    DataAccessObject db=DataAccessObject();
    return StreamBuilder<User?>(
        stream: DataAccessObject().firebaseAuth.authStateChanges(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
                return  map_page();
          } else if (!snapshot.hasData) {
            return login();
          }
          else {
            return Center(child: CircularProgressIndicator());
          }
        }));
  }
}


class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {

  final _loginFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isSyncing=false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child:ModalProgressHUD(

        inAsyncCall: isSyncing,
        child:  Scaffold(
          backgroundColor: const Color(0xffEEF1F3),
          body: Column(
            children: [
              const PageHeader(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20),),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _loginFormKey,
                      child: Column(
                        children: [
                          PageHeading(title: 'Log-in'.tr(),),
                          CustomInputField(
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                              labelText: 'Email'.tr(),
                              hintText: 'Your university email'.tr(),
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
                            keyboardType: TextInputType.text,
                            controller: passwordController,
                            labelText: 'Password'.tr(),
                            hintText: 'Your password'.tr(),
                            obscureText: true,
                            suffixIcon: true,
                            validator: (textValue) {
                              if(textValue == null || textValue.isEmpty) {
                                return 'Password is required!'.tr();
                              }
                              if (textValue.length<6){
                                return 'password should be at least 6 characters'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16,),
                          Container(
                            width: size.width * 0.80,
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgetPasswordPage()))
                              },
                              child: Text(
                                'Forget password?'.tr(),
                                style: TextStyle(
                                  color: Color(0xff939393),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20,),
                          CustomFormButton(innerText: 'Login'.tr(), onPressed: _handleLoginUser,),
                          const SizedBox(height: 18,),
                          SizedBox(
                            width: size.width * 0.8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account ? ".tr(), style: TextStyle(fontSize: 13, color: Color(0xff939393), fontWeight: FontWeight.bold),),
                                GestureDetector(
                                  onTap: () => {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage()))
                                  },
                                  child:  Text('Sign-up'.tr(), style: TextStyle(fontSize: 15, color: appTheme.mainColor, fontWeight: FontWeight.bold),),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20,),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
  Future<void> _handleLoginUser() async {
    if (_loginFormKey.currentState!.validate()) {
      setState(() {
        isSyncing=true;
      });
      DataAccessObject db= DataAccessObject();
      await db.signIn(emailController.text, passwordController.text).then((value) =>loginFeedback(value));
      if (mounted)
      setState(() {
        isSyncing=false;
      });
    }
  }
  loginFeedback(bool value){
    if (value){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => map_page()),
      );
    }
    else {
      Message.showErrorToastMessage("Wrong Email Or Password".tr());
    }
  }
}
