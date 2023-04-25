import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tareqe/custom_widget/message.dart';
import 'package:tareqe/models/DAO.dart';
import 'package:tareqe/models/PassengerRequest.dart';
import 'package:tareqe/models/theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../custom_widget/drawer.dart';
import '../models/sessionInfo.dart';

class PassengerRequestPage extends StatefulWidget {
  final PassengerRequest request;
  const PassengerRequestPage({Key? key,required this.request}) : super(key: key);

  @override
  State<PassengerRequestPage> createState() => _PassengerRequestPageState();
}
bool isSyncing = false;
Set <Polyline> polylines={};
Set<Marker> markers={};
Set<Circle> circles={};
BitmapDescriptor? customIcon;
Completer<GoogleMapController> mapController=Completer();
Location _Location = Location();
late StreamSubscription<LocationData> locationSubscription;
LatLng? _currentPosition;
bool driverComingFlag=false;
late Stream<List<PassengerRequest>> streamFunction;

class _PassengerRequestPageState extends State<PassengerRequestPage> {

  Future<void> _onMapCreated(GoogleMapController controller) async {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(6, 6)),
        'assets/images/car_icon.png')
        .then((d) {
      customIcon = d;
    });
    locationSubscription = _Location.onLocationChanged.listen((LocationData currentLocation) async {
      _currentPosition=LatLng(currentLocation.latitude!, currentLocation.longitude!);
      if (!driverComingFlag){
      await getPolyPoints(widget.request.location!,widget.request.destination!);
      }
    });
    if(!mapController.isCompleted){
      mapController.complete(controller);
    }
  }
  List <LatLng> fromPointLatLngtoLatLng(List<PointLatLng> points){
    List <LatLng> result=[];
    for (var point in points){
      result.add(LatLng(point.latitude, point.longitude));
    }
    return result;
  }

  Future <void> getPolyPoints(LatLng pickupLocation,LatLng destination) async{
    PolylinePoints polylinePoint = PolylinePoints();
    polylines.clear();
    List <LatLng> castedPoint;
    await polylinePoint.getRouteBetweenCoordinates(
        "AIzaSyCeaTeAw2Y7uRE7GIL_KGCUPl2fRCBgzHs",
        PointLatLng(pickupLocation!.latitude, pickupLocation!.longitude),
        PointLatLng(destination.latitude,destination.longitude),
        optimizeWaypoints: true
    ).then((value) {
      castedPoint=fromPointLatLngtoLatLng(value.points);
      polylines.add(
          Polyline(
              polylineId: PolylineId("polyline"),
              points: castedPoint,
              color: appTheme.mapLinesColors.first,
              width: 6
          )
      );
      if(!locationSubscription.isPaused) {
        if(mounted){
        setState(() {});
        }
      }
    });
  }

  @override
  void initState() {
    markers.clear();
    polylines.clear();
    circles.clear();
    isSyncing = false;
    _Location = new Location();
    streamFunction= DataAccessObject.instance.checkRequestStatus(widget.request.passengerEmail!);
    super.initState();
  }


  @override
  void dispose() {
    markers.clear();
    polylines.clear();
    circles.clear();
    mapController=Completer();
    locationSubscription.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return ModalProgressHUD(
        inAsyncCall: isSyncing,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: appTheme.mainColor,
              title: Text("3 Tareqe".tr()),
              centerTitle: true,
            ),
            drawer: appDrawer(),
            body:Stack(children: [
              GoogleMap(
                polylines: polylines,
                markers: markers,
                circles: circles,
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                trafficEnabled: false,
                initialCameraPosition: CameraPosition(
                    target: widget.request.location!,
                    zoom: 12),
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Wrap(
                      children: [
                        Container(
                            padding: EdgeInsets.only(top:20,bottom: 30),
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color:appTheme.passengerRequestCard.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            width: width,
                            child:
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                    StreamBuilder(
                                      stream:streamFunction,
                                      builder: (context, snapshot) {
                                        if(snapshot.connectionState==ConnectionState.waiting){
                                          return Center(child: CircularProgressIndicator(),);
                                        }
                                        if (snapshot.hasError) {
                                          return Center(child: Text(snapshot.error.toString()));
                                        }
                                        if (snapshot.data!.isEmpty){
                                          Navigator.pop(context);
                                          return Center(child: CircularProgressIndicator(),);
                                        }
                                        if (snapshot.hasData) {
                                          final request = snapshot.data!.first!;
                                          if (request.status=="searching") {
                                            driverComingFlag=false;
                                            return Column(
                                              children: [
                                                CircularProgressIndicator(),
                                                SizedBox(height: 10,),
                                                Text("Searching".tr(),style: TextStyle(color: Colors.white),),
                                                SizedBox(height: 10,),
                                                Container(
                                                  width: width * 0.8,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.withOpacity(0.5),
                                                    borderRadius: BorderRadius.circular(26),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                "Cancel warning".tr()),
                                                            content: Text(
                                                                "Are you sure you want to cancel this request?"
                                                                    .tr()),
                                                            actions: [
                                                              TextButton(
                                                                child: Text(
                                                                  "Yes".tr(),
                                                                  style: TextStyle(
                                                                      color: Colors.red),
                                                                ),
                                                                onPressed: () async {
                                                                  setState(() {
                                                                    isSyncing=true;
                                                                  });
                                                                  DataAccessObject db= DataAccessObject();
                                                                  await db.deletePassengerRequest(widget.request).then((value){
                                                                    setState((){
                                                                      isSyncing=false;
                                                                    });
                                                                    Navigator.pop(context);
                                                                    if (value) {
                                                                      Message
                                                                          .showShortToastMessage(
                                                                          "Canceled".tr());
                                                                      Navigator.pop(context);
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              TextButton(
                                                                child:
                                                                Text("No".tr()),
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                },
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Text("Cancel".tr(), style: const TextStyle(color: Colors.white, fontSize: 20),),
                                                  ),
                                                )

                                              ],
                                            );
                                          }
                                          else if (request.status =="Driver is on his way") {
                                            markers.clear();
                                            markers.add(Marker(
                                                markerId: MarkerId(request.driver!.email! + "driverMarker"),
                                                position: LatLng(request.driver!.latitude!,request.driver!.longitude!),
                                                icon: customIcon!,
                                                rotation: request.driverHeading!
                                            ));

                                            driverComingFlag=true;
                                            getPolyPoints(LatLng(request.driver!.latitude!,request.driver!.longitude!),request.location!);
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        width: 70,
                                                        height: height*0.1,
                                                        margin: EdgeInsets.only(left: 15,right: 15),
                                                        child:
                                                        SessionInfo.currentStudent.photo!=null
                                                            && SessionInfo.currentStudent.photo!.isNotEmpty?
                                                        CircleAvatar(
                                                            backgroundImage:
                                                            NetworkImage(request.driver!.photo!)
                                                        ):
                                                        CircleAvatar(
                                                            backgroundImage:
                                                            AssetImage("assets/images/defaultProfile.png")
                                                        )
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(request.driver!.name!,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),textAlign: TextAlign.left,),
                                                        SizedBox(height: 20,),
                                                        Container(
                                                          width: width*0.42,
                                                          child:
                                                          AutoSizeText(request.status!.tr(),style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,),
                                                        ),
                                                        SizedBox(height: 5,),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: width*0.2,
                                                              child:
                                                              AutoSizeText(request.driver!.car!.carType!,style: TextStyle(color: Colors.white,fontSize: 14),maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.left,),
                                                            ),
                                                            SizedBox(width: 10,),
                                                            Container(
                                                              width: width*0.2,
                                                              child:
                                                              AutoSizeText(request.driver!.car!.carNumber!,style: TextStyle(color: Colors.white,fontSize: 14),maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.left,),
                                                            ),
                                                            SizedBox(width: 10,),
                                                            Icon(CupertinoIcons.car_detailed,size: 28,color: Color(int.parse(request.driver!.car!.carColor!)),),
                                                          ],
                                                        ),
                                                        SizedBox(height: 10,),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    final Uri _phoneUri = Uri(
                                                        scheme: "tel",
                                                        path: request.driver!.phoneNumber!
                                                    );
                                                    try {
                                                      if (await canLaunch(_phoneUri.toString()))
                                                        await launch(_phoneUri.toString());
                                                    } catch (error) {
                                                      Message.showErrorToastMessage("Cannot dial");
                                                      throw("Cannot dial");
                                                    }
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(top: 10,bottom: 10),
                                                    padding: EdgeInsets.only(top: 5,bottom: 5),
                                                    width: width*0.5,
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(Icons.call,color: Colors.white,size: 20,),
                                                                SizedBox(width: 5,),
                                                                Text("Call".tr(),style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                                                              ],
                                                            ),
                                                            SizedBox(height: 5,),
                                                            Text(request.driver!.phoneNumber!,style: TextStyle(color: Colors.white,),textAlign: TextAlign.center,),

                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: width * 0.8,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.withOpacity(0.5),
                                                    borderRadius: BorderRadius.circular(26),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                "Cancel warning".tr()),
                                                            content: Text(
                                                                "Are you sure you want to cancel this request?"
                                                                    .tr()),
                                                            actions: [
                                                              TextButton(
                                                                child: Text(
                                                                  "Yes".tr(),
                                                                  style: TextStyle(
                                                                      color: Colors.red),
                                                                ),
                                                                onPressed: () async {
                                                                  setState(() {
                                                                    isSyncing=true;
                                                                  });
                                                                  DataAccessObject db= DataAccessObject();
                                                                  await db.deletePassengerRequest(widget.request).then((value){
                                                                    setState((){
                                                                      isSyncing=false;
                                                                    });
                                                                    Navigator.pop(context);
                                                                    if (value) {
                                                                      Message
                                                                          .showShortToastMessage(
                                                                          "Canceled".tr());
                                                                      Navigator.pop(context);
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              TextButton(
                                                                child:
                                                                Text("No".tr()),
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                },
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Text("Cancel".tr(), style: const TextStyle(color: Colors.white, fontSize: 20),),
                                                  ),
                                                )
                                              ],
                                            );
                                          }
                                          else if (request.status =="Driver Arrived") {
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text("Your college Arrived, please meet him at the pickup point".tr(),style: TextStyle(color: Colors.white,fontSize: 18,),textAlign: TextAlign.center,),
                                                SizedBox(height: 20,),
                                                Container(
                                                  width: width * 0.8,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.withOpacity(0.5),
                                                    borderRadius: BorderRadius.circular(26),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                "Cancel warning".tr()),
                                                            content: Text(
                                                                "Are you sure you want to cancel this request?"
                                                                    .tr()),
                                                            actions: [
                                                              TextButton(
                                                                child: Text(
                                                                  "Yes".tr(),
                                                                  style: TextStyle(
                                                                      color: Colors.red),
                                                                ),
                                                                onPressed: () async {
                                                                  setState(() {
                                                                    isSyncing=true;
                                                                  });
                                                                  DataAccessObject db= DataAccessObject();
                                                                  await db.deletePassengerRequest(widget.request).then((value){
                                                                    setState((){
                                                                      isSyncing=false;
                                                                    });
                                                                    Navigator.pop(context);
                                                                    if (value) {
                                                                      Message
                                                                          .showShortToastMessage(
                                                                          "Canceled".tr());
                                                                      Navigator.pop(context);
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              TextButton(
                                                                child:
                                                                Text("No".tr()),
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                },
                                                              )
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Text("Cancel".tr(), style: const TextStyle(color: Colors.white, fontSize: 20),),
                                                  ),
                                                )
                                              ],
                                            );
                                          }
                                          else if (request.status =="on the way") {
                                            polylines.clear();
                                            markers.clear();
                                            markers.add(Marker(
                                                markerId: MarkerId(request.driver!.email! + "driverMarker"),
                                                position: _currentPosition!,
                                                icon: customIcon!,
                                                rotation: request.driverHeading!
                                            ));
                                            return Center(
                                              child:
                                                Text("Ride started, you are on the way to the destination".tr(),style: TextStyle(color: Colors.white,fontSize: 18,),textAlign: TextAlign.center,),
                                            );
                                          }
                                          else if (request.status =="on payment"||request.status =="done") {
                                            polylines.clear();
                                            markers.clear();
                                            return Column(
                                              children:[
                                              Text("Total Price is".tr(),style: TextStyle(color: Colors.white,fontSize: 18,),textAlign: TextAlign.center,),
                                              SizedBox(height: 10,),
                                              Text(request!.price.toString()+" "+"JD".tr(),style: TextStyle(color: Colors.green,fontSize: 18,),textAlign: TextAlign.center,),
                                                SizedBox(height: 20,),
                                                Container(
                                                  width: width * 0.8,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.withOpacity(0.8),
                                                    borderRadius: BorderRadius.circular(26),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      setState((){
                                                       Navigator.pop(context);
                                                      });
                                                    },
                                                    child: Text("Done".tr(), style: const TextStyle(color: Colors.white, fontSize: 20),),
                                                  ),
                                                ),
                                              ]
                                            );
                                          }

                                          else {return CircularProgressIndicator();}
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                      },
                                    ),

                                  ],),
                                ),
                              ]
                            )),
                      ],
                    )
                  ],
                ),
            ],)
        )
    );  }
}
