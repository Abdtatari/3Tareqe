import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:location/location.dart';
import 'package:tareqe/models/PassengerRequest.dart';
import 'package:tareqe/models/sessionInfo.dart';
import 'package:tareqe/models/student.dart';
import 'package:tareqe/models/userFeedback.dart';
import 'package:uuid/uuid.dart';
import '../custom_widget/message.dart';
import 'car.dart';


//Data access model  access database

// Singleton design pattern used in this class
class DataAccessObject {
  static final DataAccessObject instance = DataAccessObject._internal();
  late final FirebaseFirestore firebaseFirestore;
  late final FirebaseStorage firebaseStorage;
  late final FirebaseAuth firebaseAuth;

  factory DataAccessObject() {
    return instance;
  }

  DataAccessObject._internal() {
    firebaseFirestore = FirebaseFirestore.instance;
    firebaseStorage = FirebaseStorage.instance;
    firebaseAuth = FirebaseAuth.instance;
  }

  //////////////////////////// register,login/out functions start ////////////////////////////

  Future<bool> signIn(String email, String password) async {
    bool result = false;
    try {
      await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password).then((value) async => ({
        result = await checkIfVerified(value)
      }));
    } on FirebaseAuthException catch (e) {
      print(e.message.toString());
    } catch (e) {
      print(e.toString());
    }
    if (!result){
      logout();
    }
    return result;
  }

  Future<bool> checkIfVerified (UserCredential userCredential) async {
    bool verified =  userCredential.user!.emailVerified ;
    bool active =  await checkIfActive(userCredential.user?.email);
    return active && verified;
}
  Future<bool> checkIfActive(email) async {
    Student student;
    bool result = false;
    try{
      await firebaseFirestore
          .collection("users")
          .where("email",isEqualTo: email)
          .get().then((value) {
            student = Student.fromJson(value.docs.first.data());
            result = student.isActive!;
      });
    }
    catch (error) {
      Message.showErrorToastMessage(error.toString().tr());
    }
    return result;
  }
  Future <bool> logout() async {
    try {
      await firebaseAuth.signOut();
      return true;
    } on FirebaseAuthException catch (e) {
     print(e.message.toString());
    } catch (e) {
      print(e.toString());
    }
    return false;
  }

  Future<bool> signUp(Student studentModel) async {
    try {
      await firebaseAuth
          .createUserWithEmailAndPassword(email: studentModel.email!, password: studentModel.password!)
          .then((value) => saveUserInfo(studentModel));
      return true;
    } on FirebaseAuthException catch (e) {
      Message.showErrorToastMessage(e.message.toString().tr());
      print(e.message.toString());
    } catch (e) {
      Message.showErrorToastMessage("somethingWentWrong".tr());
    }

    return false;
  }

  Future<bool> saveUserInfo(Student userInfo,
      {String? uid}) async {
    Map<String, dynamic> data = userInfo.toJson();

    try {
      if (data["photo"] != "") {
        data["photo"] = await uploadPhoto(data["photo"] ?? "");
      }

      await firebaseFirestore
          .collection("users")
          .doc(uid ?? firebaseAuth.currentUser?.uid)
          .set(data);

      return true;
    } catch (e) {
      Message.showErrorToastMessage("somethingWentWrong".tr());
    }
    return false;
  }

  Future<bool> resetPassword(String email) async {
    try {
      await firebaseAuth
          .sendPasswordResetEmail(email: email)
          .onError((error, stackTrace) => print(error));

      return true;
    } on FirebaseAuthException catch (e) {
      Message.showErrorToastMessage(e.message.toString());
    } catch (e) {
      Message.showErrorToastMessage("somethingWentWrong reset password".tr());
    }

    return false;
  }

  Future<bool> sendEmailVerification() async {
    try {
      await firebaseAuth.currentUser?.sendEmailVerification();

      return true;
    } on FirebaseAuthException catch (e) {
      Message.showErrorToastMessage(e.message.toString());
    } catch (e) {
      Message.showErrorToastMessage("somethingWentWrong send verification email".tr());
    }

    return false;
  }

  Future<Student?> getCurrentUserInfo(String id) async {
    Student? currentUserInfo;
    try {
      await firebaseFirestore.collection("users").doc(id).get().then((value) {
        currentUserInfo = Student.fromJson(value.data()!);
      });
    } catch (e) {
      Message.showErrorToastMessage("somethingWentWrong".tr());
    }
    return currentUserInfo;
  }

  Future<void> deleteAccount(email) async {
    Student student;
    try{
      await firebaseFirestore
          .collection("users")
          .where("email",isEqualTo: email)
          .get().then((value) {
        student = Student.fromJson(value.docs.first.data());
        student.isActive=false;
        firebaseFirestore.collection("users").doc(value.docs.first.id).update(student.toJson());
      });
    }
    catch (error) {
      Message.showErrorToastMessage(error.toString().tr());
    }
  }
  //////////////////////////// register,login/out functions end ////////////////////////////



  //////////////////////////// photos function start ////////////////////////////

  Future<String?> uploadPhoto(String photo) async {
    try {
      if (photo != "") {
        final snapshot = await firebaseStorage
            .ref()
            .child('Images/' + const Uuid().v4())
            .putFile(File(photo))
            .whenComplete(() => null);
        //to save the link of the photo
        return await snapshot.ref.getDownloadURL();
      }
    } catch (e) {
      Message.showErrorToastMessage("something Went Wrong uploading photo".tr());
    }
    return null;
  }

//////////////////////////// photos function end ////////////////////////////

/////////////////////////// get users start /////////////////////////////////

Future <List<Student>> getUserByType(int type) async {
  List<Student> students = [];
  try {
    await firebaseFirestore
        .collection("users")
        .where("type", isEqualTo: type)
        .get()
        .then((value) {
      for (var element in value.docs) {
        Student student = Student.fromJson(element.data());
        if (student.isActive!) {
          students.add(student);
        }
      }
    });
  } catch (e) {
    Message.showErrorToastMessage("somethingWentWrong".tr()+e.toString());
  }

  return students;
}

/////////////////////////// get users end /////////////////////////////////

////////////////////////// feedback function start ////////////////////////

  Future <List<UserFeedback>> getFeedbacks() async {
    List<UserFeedback> feedbacks = [];
    try {
      await firebaseFirestore
          .collection("feedback")
          .get()
          .then((value) {
        for (var element in value.docs) {
          UserFeedback userFeedback = UserFeedback.fromJson(element.data());
          feedbacks.add(userFeedback);
        }
      });
    } catch (e) {
      Message.showErrorToastMessage("somethingWentWrong".tr());
    }

    return feedbacks;
  }

  Future <bool> addFeedback(UserFeedback feedback) async {
    try {
       await firebaseFirestore.collection("feedback").add(feedback.toJson());
       return true;
    }
    catch (e){
      Message.showErrorToastMessage("somethingWentWrong".tr());
    }
    return false;
  }

  Future <bool> adduserTemp(Student user) async {
    try {
      await firebaseFirestore.collection("users").add(user.toJson());
      return true;
    }
    catch (e){
      Message.showErrorToastMessage("somethingWentWrong".tr());
    }
    return false;
  }
////////////////////////// feedback function end //////////////////////////

///////////////////////// become driver function start ////////////////////
  Future<bool> sendBecomeDriverRequest (Student student) async {
    try {
      if (student.licenceImg!.isNotEmpty) {
        student.licenceImg = await uploadPhoto(student.licenceImg?? "");
      }
      await firebaseFirestore
          .collection("users")
          .where("email",isEqualTo: student.email)
          .get().then((value) {
            firebaseFirestore.collection("users").doc(value.docs.first.id).update(student.toJson());
          });
      return true;
    }
    catch (e){
      Message.showErrorToastMessage("somethingWentWrong".tr());
    }
    return false;
  }

  Future <List<Student>> getDriversRequest() async {
    List<Student> requests = [];
    try {
      await firebaseFirestore
          .collection("users")
          .where("type",isEqualTo: 2,)
          .where("approvedToBeDriver",isEqualTo:false)
          .where("isActive",isEqualTo:true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          Student request = Student.fromJson(element.data());
          requests.add(request);
        }
      });
    } catch (e) {
      Message.showErrorToastMessage("somethingWentWrong".tr());
    }

    return requests;
  }

  Future<bool> updateRequestStatus(Student student) async{
    try {
      await firebaseFirestore
          .collection("users")
          .where("email",isEqualTo: student.email)
          .get().then((value) {
        firebaseFirestore.collection("users").doc(value.docs.first.id).update(student.toJson());
      });
      return true;
    }
    catch (e){
      Message.showErrorToastMessage("somethingWentWrong".tr());
    }
    return false;
  }
///////////////////////// become driver function end /////////////////////


///////////////////////// driver functions start /////////////////////////
  Future<bool> becomeActive_notActive(Student student) async{
    if (await checkIfActive(student.email!)) {
      try {
        await firebaseFirestore
            .collection("users")
            .where("email", isEqualTo: student.email)
            .get().then((value) {
          firebaseFirestore.collection("users").doc(value.docs.first.id).update(
              student.toJson());
        });
        return true;
      }
      catch (e) {
        Message.showErrorToastMessage("somethingWentWrong".tr());
      }
    }
    //if admin remove driver Account and he is logged in
    else {
      try {
        await firebaseFirestore
            .collection("users")
            .where("email", isEqualTo: student.email)
            .get().then((value) {
              student = Student.fromJson(value.docs.first.data());
              student.isDriving=false;
          firebaseFirestore.collection("users").doc(value.docs.first.id).update(
              student.toJson());
        });
        Message.showErrorToastMessage("Your Account deleted".tr());
        return false;
      }
      catch (e) {
        Message.showErrorToastMessage("somethingWentWrong".tr());
      }
    }
    return false;
  }

  Stream <List<PassengerRequest>> getRequests(){
    return firebaseFirestore
        .collection('passengerRequests')
        .where("status",isEqualTo: "searching")
        .snapshots()
        .map((event) =>
        event.docs.map((e) => PassengerRequest.fromJson(e.data())).toList());
  }



  Future<bool> acceptRequest(PassengerRequest request) async {
    try {
    await firebaseFirestore
        .collection("passengerRequests")
        .where("passengerEmail", isEqualTo: request.passengerEmail)
        .where("status",isEqualTo: "searching")
        .get().then((value) {
          request=PassengerRequest.fromJson(value.docs.first.data());
            request.driver=SessionInfo.currentStudent;
            request.status = "Driver is on his way";
          firebaseFirestore.collection("passengerRequests").doc(value.docs.first.id).update(request.toJson());
    });
      return true;
    }
    catch (e){
       Message.showErrorToastMessage("somethingWentWrong".tr()+e.toString());
    }
    return false;
  }


  Future<bool> rejectRequest(PassengerRequest request) async {
    try {
      await firebaseFirestore
          .collection("passengerRequests")
          .where("passengerEmail", isEqualTo: request.passengerEmail)
          .where("status",isEqualTo: "searching")
          .get().then((value) {
        request=PassengerRequest.fromJson(value.docs.first.data());
        firebaseFirestore.collection("passengerRequests").doc(value.docs.first.id).update(request.toJson());
      });
      return true;
    }
    catch (e){
      Message.showErrorToastMessage("somethingWentWrong".tr()+e.toString());
    }
    return false;
  }

  Future <bool> driverArrived(PassengerRequest request) async {
    try {
      await firebaseFirestore
          .collection("passengerRequests")
          .where("passengerEmail", isEqualTo: request.passengerEmail)
          .where("status",isEqualTo: "Driver is on his way")
          .get().then((value) {
        request=PassengerRequest.fromJson(value.docs.first.data());
        request.status = "Driver Arrived";
        firebaseFirestore.collection("passengerRequests").doc(value.docs.first.id).update(request.toJson());
      });
      return true;
    }
    catch (e){
      Message.showErrorToastMessage("somethingWentWrong".tr()+e.toString());
    }
    return false;
  }
  Future <bool> startRide(PassengerRequest request) async {
    try {
      await firebaseFirestore
          .collection("passengerRequests")
          .where("passengerEmail", isEqualTo: request.passengerEmail)
          .where("status",isEqualTo: "Driver Arrived")
          .get().then((value) {
        request=PassengerRequest.fromJson(value.docs.first.data());
        request.status = "on the way";
        firebaseFirestore.collection("passengerRequests").doc(value.docs.first.id).update(request.toJson());
      });
      return true;
    }
    catch (e){
      Message.showErrorToastMessage("somethingWentWrong".tr()+e.toString());
    }
    return false;
  }
  Future <bool> onPayment(PassengerRequest request) async {
    try {
      await firebaseFirestore
          .collection("passengerRequests")
          .where("passengerEmail", isEqualTo: request.passengerEmail)
          .where("status",isEqualTo: "on the way")
          .get().then((value) {
        request=PassengerRequest.fromJson(value.docs.first.data());
        request.status = "on payment";
        firebaseFirestore.collection("passengerRequests").doc(value.docs.first.id).update(request.toJson());
      });
      return true;
    }
    catch (e){
      Message.showErrorToastMessage("somethingWentWrong".tr()+e.toString());
    }
    return false;
  }

  Future <bool> finishRide(PassengerRequest request) async {
    try {
      await firebaseFirestore
          .collection("passengerRequests")
          .where("passengerEmail", isEqualTo: request.passengerEmail)
          .where("status",isEqualTo: "on payment")
          .get().then((value) {
        request=PassengerRequest.fromJson(value.docs.first.data());
        request.status = "done";
        firebaseFirestore.collection("passengerRequests").doc(value.docs.first.id).update(request.toJson());
      });
      return true;
    }
    catch (e){
      Message.showErrorToastMessage("somethingWentWrong".tr()+e.toString());
    }
    return false;
  }

  Future <bool> cancelRide(PassengerRequest request) async {
    try {
      await firebaseFirestore
          .collection("passengerRequests")
          .where("passengerEmail", isEqualTo: request.passengerEmail)
          .where("status",isEqualTo:request.status)
          .get().then((value) {
        request=PassengerRequest.fromJson(value.docs.first.data());
        request.driver= Student(name: "",email: "",password: "",gender: "",phoneNumber: "0", isActive: false, photo: "", approvedToBeDriver: false, isDriving: false, type: 1,car: Car());
        request.status = "searching";
        firebaseFirestore.collection("passengerRequests").doc(value.docs.first.id).update(request.toJson());
      });
      return true;
    }
    catch (e){
      Message.showErrorToastMessage("somethingWentWrong".tr()+e.toString());
    }
    return false;
  }

  Stream <List<PassengerRequest>> RequestStream(PassengerRequest request){
      return firebaseFirestore
          .collection('passengerRequests')
          .where("status", whereIn: [
        "Driver Arrived",
        "Driver is on his way",
        "on the way",
        "on payment"
      ])
          .where("passengerEmail", isEqualTo: request.passengerEmail)
          .snapshots()
          .map((event) =>
          event.docs.map((e) => PassengerRequest.fromJson(e.data())).toList());
  }
  Future<PassengerRequest?> checkIfInRide(Student driver) async {
    PassengerRequest? result;
    try {
      await firebaseFirestore
          .collection("passengerRequests")
          .where("driver.email", isEqualTo: driver.email)
          .where("status",whereNotIn: ["canceled","done","searching"])
          .get()
          .then((value) {
        if (value.size==0){
          return result;
        }
        result=PassengerRequest.fromJson(value.docs.first.data());
        return result;
      });
    }
    catch (e) {
      Message.showErrorToastMessage("somethingWentWrong".tr()+e.toString());
    }
    return result;
  }

  Future<bool> updateDriverLocation(String email,LocationData location) async {
    try {
      await firebaseFirestore
          .collection("passengerRequests")
          .where("driver.email", isEqualTo: email)
          .where("status",whereNotIn: ["done,canceled"])
          .get().then((value) {
        PassengerRequest request=PassengerRequest.fromJson(value.docs.first.data());
        request.driver!.latitude=location.latitude;
        request.driver!.longitude=location.longitude;
        request.driverHeading=location.heading;
        firebaseFirestore.collection("passengerRequests").doc(value.docs.first.id).update(request.toJson());
      });
      return true;
    }
    catch (e){
      Message.showErrorToastMessage("somethingWentWrong".tr()+e.toString());
    }
    return false;
  }
///////////////////////// driver functions end ///////////////////////////

///////////////////////// edit profile functions start ///////////////////

Future<bool> updateProfile(Student profile) async {
    try {
      if(await checkIfActive(profile.email)) {
        if (profile.photo!.isNotEmpty && !profile.photo!.contains("https://firebasestorage.googleapis.com/")) {
          profile.photo = await uploadPhoto(profile.photo?? "");
        }
        await firebaseFirestore
            .collection("users")
            .where("email", isEqualTo: profile.email)
            .get().then((value) {
          firebaseFirestore.collection("users").doc(value.docs.first.id).update(
              profile.toJson());
        });
        return true;
      }
      else {
        return false;
      }
    }
    catch (e){
      Message.showErrorToastMessage("somethingWentWrong".tr());
    }
    return false;
}
///////////////////////// edit profile functions end ////////////////////

///////////////////////// passenger functions start ////////////////////

Future<List<Student>> getActiveDrivers() async {
    List<Student> result =[];
    try {
      await firebaseFirestore
          .collection("users")
          .where("type",isEqualTo: 2,)
          .where("approvedToBeDriver",isEqualTo:true)
          .where("isActive",isEqualTo:true)
          .where("isDriving",isEqualTo:true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          Student driver = Student.fromJson(element.data());
          result.add(driver);
        }
      });
    } catch (e) {
      Message.showErrorToastMessage("somethingWentWrong".tr());
    }
    return result;
}

  Future <bool> addPassengerRequest(PassengerRequest request) async{
  try {
    await firebaseFirestore.collection("passengerRequests").add(request.toJson());
    return true;
  }
  catch (e){
    Message.showErrorToastMessage("somethingWentWrong".tr()+e.toString());
  }
  return false;
  }

  Future <bool> deletePassengerRequest(PassengerRequest request) async{
      try {
        await firebaseFirestore
            .collection("passengerRequests")
            .where("passengerEmail", isEqualTo: request.passengerEmail)
            .where("status",whereNotIn: ["canceled","done"])
            .get()
            .then((value) {
          request.status="canceled";
          firebaseFirestore.collection("passengerRequests").doc(value.docs.first.id).update(
              request.toJson());
        });
        return true;
      }
      catch (e) {
        Message.showErrorToastMessage("somethingWentWrong".tr()+e.toString());
      }
      return false;
  }

  Future <PassengerRequest?> checkHaveRequest(String email) async{
    PassengerRequest? result;
    try {
      await firebaseFirestore
          .collection("passengerRequests")
          .where("passengerEmail", isEqualTo: email)
          .where("status",whereNotIn: ["canceled","done"])
          .get()
          .then((value) {
            if (value.size==0){
              return result;
            }
        result=PassengerRequest.fromJson(value.docs.first.data());
        return result;
      });
    }
    catch (e) {
      Message.showErrorToastMessage("somethingWentWrong".tr()+e.toString());
    }
    return result;
  }
  Stream <List<PassengerRequest>> checkRequestStatus(String email){
    return firebaseFirestore
        .collection('passengerRequests')
        .where("passengerEmail", isEqualTo: email)
        .where("status",whereNotIn: ["canceled","done"])
        .snapshots()
        .map((event) =>
        event.docs.map((e) => PassengerRequest.fromJson(e.data())).toList());
  }
///////////////////////// passenger functions end ////////////////////

}
