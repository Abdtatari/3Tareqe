import 'package:tareqe/models/student.dart';

class SessionInfo {
  static Student currentStudent=Student(name: "", email: "", password: "", gender: "", phoneNumber: "", photo: "", type: 1,isActive:true,approvedToBeDriver: false,isDriving: false);
  static void clear(){
    currentStudent=Student(name: "", email: "", password: "", gender: "", phoneNumber: "", photo: "", type: 1,isActive:true,approvedToBeDriver: false,isDriving: false);
  }
}