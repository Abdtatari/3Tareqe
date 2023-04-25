import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tareqe/custom_widget/message.dart';
import 'package:tareqe/models/sessionInfo.dart';
import 'package:tareqe/models/theme.dart';
import 'package:tareqe/models/userFeedback.dart';
import 'package:uuid/uuid.dart';
class writeReview extends StatefulWidget {
  const writeReview({Key? key}) : super(key: key);

  @override
  State<writeReview> createState() => _writeReviewState();
}

class _writeReviewState extends State<writeReview> {
  TextEditingController title_contoller = TextEditingController();
  TextEditingController content_contoller = TextEditingController();
  bool isSyncing =false;
  final _FormKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return ModalProgressHUD(
        inAsyncCall: isSyncing,
        child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Add Review".tr()),
          backgroundColor: appTheme.mainColor,
        ),
        body: SingleChildScrollView(
          child:Form(
            key: _FormKey,
            child:  Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: height*0.1,),
                Text("We will be more than happy hearing from you".tr(),style: TextStyle(color: appTheme.mainColor,fontSize: 20,),textAlign: TextAlign.center,),
                SizedBox(height: height*0.05,),
                Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: appTheme.mainColor)
                    ),
                    child: Container(
                      child: TextFormField(
                        controller: title_contoller,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            label: Text("Title".tr()),
                            labelStyle: TextStyle(fontSize: 14)
                        ),
                        validator: (textValue) {
                          if(textValue == null || textValue.isEmpty) {
                            return 'Please Enter message Title'.tr();
                          }
                          return null;
                        },
                      ),
                    )
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color:appTheme.mainColor)
                  ),
                  child: TextFormField(
                    maxLength: 400,
                    controller: content_contoller,
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        label: Text("Your Message".tr()),
                        labelStyle: TextStyle(fontSize: 14)
                    ),
                    validator: (textValue) {
                      if(textValue == null || textValue.isEmpty) {
                        return 'Please Enter your message'.tr();
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  width: width*0.5,
                  height: height*0.06,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: appTheme.buttosColor),
                    onPressed: () async {
                      if(_FormKey.currentState!.validate()){
                        setState((){
                          isSyncing=true;
                        });
                        Uuid uuid=Uuid();
                        UserFeedback feedback=UserFeedback(id:uuid.v4().toString() ,title:title_contoller.text ,content: content_contoller.text,photoPath:SessionInfo.currentStudent.photo, );
                        await SessionInfo.currentStudent.addFeedback(feedback).then((value) => Feedback(value));
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Send".tr()),
                        Icon(Icons.send,color: Colors.white,),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        )
    )
    );
  }
  Feedback(value){
    if (value){
      Message.showLongToastMessage("Thank you for your Feedback".tr());
      Navigator.pop(context);
    }
    else {
      Message.showErrorToastMessage("Something wrong happened");
    }
    setState((){
      isSyncing=false;
    });
  }
}
