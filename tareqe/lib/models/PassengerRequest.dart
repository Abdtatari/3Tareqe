import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tareqe/models/student.dart';

class PassengerRequest {
  String? passengerName;
  String? passengerEmail;
  String? passengerNumber;
  LatLng? location;
  LatLng? destination;
  int? seatNumber;
  double? price;
  String? status;
  Student? driver;
  double? driverHeading;

  PassengerRequest({required this.passengerName,required this.passengerEmail,required this.passengerNumber ,required this.location,required this.destination,required this.seatNumber,required this.price,required this.status,this.driver,this.driverHeading=0});

  PassengerRequest.fromJson(Map<String, dynamic> json) {
    passengerName=json['passengerName'];
    passengerEmail = json['passengerEmail'];
    location =LatLng.fromJson(json['location']);
    destination =LatLng.fromJson(json['destination']);
    seatNumber = json['seatNumber'];
    price = json['price'];
    status = json['status'];
    driver =Student.fromJson(json['driver']);
    passengerNumber=json['passengerNumber'];
    driverHeading=json['driverHeading'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['passengerName']=this.passengerName;
    data['passengerEmail'] = this.passengerEmail;
    data['location'] = this.location?.toJson();
    data['destination']=this.destination?.toJson();
    data['seatNumber'] = this.seatNumber;
    data['price']= this.price;
    data['status'] = this.status;
    data['passengerNumber']=this.passengerNumber;
    data['driver'] = this.driver?.toJson();
    data['driverHeading']=this.driverHeading;
    return data;
  }


}