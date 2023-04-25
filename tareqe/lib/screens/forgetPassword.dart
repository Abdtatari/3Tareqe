import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tareqe/models/DAO.dart';
import 'package:tareqe/screens/login.dart';

import '../custom_widget/custom_form_button.dart';
import '../custom_widget/custom_input_field.dart';
import '../custom_widget/page_header.dart';
import '../custom_widget/page_heading.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {

  final _forgetPasswordFormKey = GlobalKey<FormState>();
  TextEditingController emailController= TextEditingController();
  bool isSyncing=false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(inAsyncCall: isSyncing,
        child: SafeArea(
      child: Scaffold(
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
                    key: _forgetPasswordFormKey,
                    child: Column(
                      children: [
                        PageHeading(title: 'Forgot password'.tr(),),
                        CustomInputField(
                            keyboardType: TextInputType.text,
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
                        const SizedBox(height: 20,),
                        CustomFormButton(innerText: 'Submit'.tr(), onPressed: _handleForgetPassword,),
                        const SizedBox(height: 20,),
                        Container(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () => {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const login()))
                            },
                            child:  Text(
                              'Back to login'.tr(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xff939393),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
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

  Future<void> _handleForgetPassword() async {
    // forget password
    if (_forgetPasswordFormKey.currentState!.validate()) {
      setState(() {
        isSyncing=true;
      });
      DataAccessObject db=DataAccessObject.instance;
      await db.resetPassword(emailController.text).then((value) => sendResetEmailFeedback(value));
      setState(() {
        isSyncing=false;
      });
    }
  }
  sendResetEmailFeedback(value){
    if (true){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
                "Reset Password".tr()),
            content: Text(
                "Reset password link will be send to your Email if you are already registered"
                    .tr()),
            actions: [
              TextButton(
                child:
                Text("OK".tr()),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);

                },
              )
            ],
          );
        },
      );
    }
  }
}
