import 'package:tareqe/models/DAO.dart';
import 'package:tareqe/models/car.dart';
import 'package:tareqe/models/userFeedback.dart';

class Student {
  String? name;
  String? email;
  String? gender;
  String? password;
  String? phoneNumber;
  String? photo;
  int? type;
  Car? car;
  String? licence;
  bool? isActive;
  String? licenceImg;
  bool? approvedToBeDriver;
  bool? isDriving ;
  double? latitude;
  double? longitude;
  String? licenceExpirationDate;
  Student(
      {required this.name,required this.email,required this.isActive,required this.password,required this.gender, required this.phoneNumber,required this.photo,required this.approvedToBeDriver,required this.isDriving,required this.type, this.car,this.licence,this.licenceImg,this.latitude,this.longitude,this.licenceExpirationDate});

  Student.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    password = json['password'];
    photo = json['photo'];
    type = json['type'];
    car = Car.fromJson(json['car']);
    licence=json['licence'];
    gender=json['gender'];
    phoneNumber=json['phoneNumber'];
    isActive=json['isActive'];
    licenceImg=json['licenceImg'];
    approvedToBeDriver = json['approvedToBeDriver'];
    isDriving = json['isDriving'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    licenceExpirationDate=json['licenceExpirationDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['photo'] = this.photo;
    data['type'] = this.type;
    data['car'] = this.car?.toJson();
    data['licence']=this.licence;
    data['gender']=this.gender;
    data['phoneNumber']=this.phoneNumber;
    data['isActive']=this.isActive;
    data['licenceImg']=this.licenceImg;
    data['approvedToBeDriver']=this.approvedToBeDriver;
    data['isDriving']=this.isDriving;
    data['latitude']= this.latitude;
    data['longitude']= this.longitude;
    data['licenceExpirationDate']=this.licenceExpirationDate;
    return data;
  }
  Future<bool> signup () async {
    DataAccessObject db = DataAccessObject.instance;
    bool result=false;
    try {
      return await db.signUp(this);
    }
    catch (error){
      print(error.toString());
    }
    return result;
  }
  Future<bool> addFeedback (UserFeedback feedback) async {
    DataAccessObject db = DataAccessObject.instance;
    try {
       await db.addFeedback(feedback);
       return true;
    }
    catch (error){
      print(error.toString());
    }
    return false;
  }

  @override
  String toString() {
    return 'Student{name: $name, email: $email, gender: $gender, password: $password, phoneNumber: $phoneNumber, photo: $photo, type: $type, car: $car, licence: $licence, isActive: $isActive, licenceImg: $licenceImg, approvedToBeDriver: $approvedToBeDriver, isDriving: $isDriving}';
  }
}