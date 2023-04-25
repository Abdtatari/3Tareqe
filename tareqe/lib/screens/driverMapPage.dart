import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tareqe/models/theme.dart';
import 'package:tareqe/screens/passengerRequestPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart' as geocoding;


import '../custom_widget/drawer.dart';
import '../custom_widget/message.dart';
import '../models/DAO.dart';
import '../models/PassengerRequest.dart';
import '../models/sessionInfo.dart';

class driverMapPage extends StatefulWidget {
  const driverMapPage({Key? key}) : super(key: key);

  @override
  State<driverMapPage> createState() => _driverMapPageState();
}

class _driverMapPageState extends State<driverMapPage> {

  Future<void> _onMapCreated(GoogleMapController controller) async {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(6, 6)),
        'assets/images/car_icon.png')
        .then((d) {
      customIcon = d;
    });

    locationSubscription = _Location.onLocationChanged.listen((LocationData currentLocation) async {
      if (SessionInfo.currentStudent!.isDriving!) {
        DataAccessObject.instance.updateDriverLocation(
            SessionInfo.currentStudent.email!,currentLocation);
      }
      _currentPosition=LatLng(currentLocation.latitude!, currentLocation.longitude!);
      if(first && !mapController.isCompleted){
        mapController.future.then((value) {
          value.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(
                  currentLocation.latitude as double,
                  currentLocation.longitude as double,
                ),
                zoom: 16,
              ),
            ),
          );
          first=false;
        });
      }
      if (destinations.isNotEmpty)
        await getPolyPoints(_currentPosition!,destinations.first);
      if (mounted){setState(() {

      });}
    });
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
        setState(() {});
      }
    });
  }
  double distance(LatLng location1, LatLng location2) {
    var p = pi / 180; // Math.PI / 180
    var c = cos;
    num lat1 = location1.latitude;
    num lat2 = location2.latitude;
    num lon1 = location1.longitude;
    num lon2 = location2.longitude;
    num latitudeDef = lat2 - lat1;
    num longitudeDef = lon2 - lon1;

    var a = 0.5 -
        c((latitudeDef) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((longitudeDef) * p)) / 2;

    return (12742 * asin(sqrt(a))) * 1000;
  }
  getDestinationSourceName(PassengerRequest request) async {
    await geocoding.placemarkFromCoordinates(request.destination!.latitude,request.destination!.longitude).then((value) {
        destinationName =value.first.locality!+" - "+value.first.subLocality!;
    });
    await geocoding.placemarkFromCoordinates(request.location!.latitude,request.location!.longitude).then((value) {
      sourceName = value.first.locality!+" - "+value.first.subLocality!;
    });
  }
  checkIfInRide(){
    DataAccessObject().checkIfInRide(SessionInfo.currentStudent).then((value) {
      if (value!=null){
        requestStream=DataAccessObject().RequestStream(value);
        getDestinationSourceName(value);
        inDrive=true;
      }
    });
  }

  String destinationName="";
  String sourceName="";
  bool isSyncing = false;
  bool first=true;
  Set <Polyline> polylines={};
  Set<Marker> markers={};
  Set<Circle> circles={};
  BitmapDescriptor? customIcon;
  Completer<GoogleMapController> mapController=Completer();
  Location _Location = Location();
  late StreamSubscription<LocationData> locationSubscription;
  LatLng? _currentPosition;
  double searchRadius = 1000;
  List<LatLng> destinations=[];
  List<PassengerRequest> rejectedRequests=[];

  Stream<List<PassengerRequest>>?allRequestsStream;
  Stream<List<PassengerRequest>>?requestStream;
  bool ?inDrive;

  @override
  void initState() {
    inDrive=false;
    allRequestsStream=DataAccessObject.instance.getRequests();
    first=true;
    checkIfInRide();
    super.initState();
  }


  @override
  void dispose() {
    destinations.clear();
    locationSubscription?.cancel();
    polylines.clear();
    destinationName="";
    sourceName="";
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
                    target: _currentPosition??
                        LatLng(32.0469879,35.7772887),
                    zoom: 16),
                padding: EdgeInsets.only(bottom:550,),
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
                                        stream: inDrive! ?requestStream:allRequestsStream,
                                        builder: (context, snapshot) {
                                          if (_currentPosition==null) {
                                            return Center(child: CircularProgressIndicator(),);
                                          }
                                          if (snapshot.connectionState==ConnectionState.waiting){
                                            return Center(child: CircularProgressIndicator(),);
                                          }
                                          if (snapshot.hasError) {
                                            return Center(child: Text(snapshot.error.toString()));
                                          }
                                            if (snapshot.hasData) {
                                              if (snapshot.data!.isEmpty) {
                                                if (inDrive!){
                                                  polylines.clear();
                                                  markers.clear();
                                                  inDrive=false;
                                                }
                                              return Column(
                                                children: [
                                                  CircularProgressIndicator(),
                                                  SizedBox(height: 10,),
                                                  Text("Searching".tr(),style: TextStyle(color: Colors.white),),
                                                ],
                                              );
                                            }
                                             PassengerRequest? request;
                                              for (int i=0;i<snapshot.data!.length;i++){
                                                request=snapshot.data![i];
                                                for (int j=0;j<rejectedRequests.length;j++){
                                                    if ((rejectedRequests[j].passengerEmail == request!.passengerEmail)){
                                                      request=null;
                                                    }
                                              }
                                            }
                                            if (request==null){
                                                return Column(
                                                  children: [
                                                    CircularProgressIndicator(),
                                                    SizedBox(height: 10,),
                                                    Text("Searching".tr(),style: TextStyle(color: Colors.white),),
                                                  ],
                                                );
                                            }
                                            else if (request.status=="Driver is on his way"){
                                              inDrive=true;
                                            return Container(
                                              padding: EdgeInsets.only(left:20,right: 20),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(request.passengerName!, style: const TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold),),
                                                  InkWell(
                                                      onTap: () async {
                                                        final Uri _phoneUri = Uri(
                                                            scheme: "tel",
                                                            path: request!.passengerNumber!
                                                        );
                                                        try {
                                                          if (await canLaunch(_phoneUri.toString()))
                                                            await launch(_phoneUri.toString());
                                                        } catch (error) {
                                                          throw("Cannot dial");
                                                        }
                                                      },
                                                      child:
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                          Icon(Icons.call,color: Colors.green,size: 28,),
                                                        ],
                                                      )
                                                  ),
                                                  SizedBox(height: height*0.03,),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(request!.price.toString() +" "+ "JD".tr(),style: TextStyle(color: Colors.white,fontSize: 16),textAlign: TextAlign.left,),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(request.seatNumber.toString(),style: TextStyle(color: Colors.white,fontSize: 16),textAlign: TextAlign.left,),
                                                          Icon(Icons.event_seat_rounded,color: Colors.white,size: 26,),
                                                        ],
                                                      ),

                                                    ],
                                                  ),
                                                  sourceName.isNotEmpty?
                                                  Text(sourceName, style: const TextStyle(color: Colors.white, fontSize: 16),):Container(width: 20,height: 20,child: CircularProgressIndicator(),),
                                                  SizedBox(height: height*0.01,),
                                                  Icon(CupertinoIcons.arrow_up_arrow_down_circle,color: Colors.white,size: 32,),
                                                  SizedBox(height: height*0.01,),
                                                  destinationName.isNotEmpty?
                                                  Text(destinationName, style: const TextStyle(color: Colors.white, fontSize: 16),):Container(width: 20,height: 20,child: CircularProgressIndicator(),),                                                  SizedBox(height: height*0.02,),
                                                  Container(
                                                    width: width * 0.8,
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.withOpacity(0.8),
                                                      borderRadius: BorderRadius.circular(26),
                                                    ),
                                                    child: TextButton(
                                                      onPressed: () async {
                                                        setState((){
                                                          isSyncing=true;
                                                        });
                                                        await DataAccessObject.instance.driverArrived(request!).then((value) {
                                                          setState((){
                                                            isSyncing=false;
                                                          });
                                                          markers.clear();
                                                          destinations.clear();
                                                          polylines.clear();
                                                          markers.add(Marker(markerId: MarkerId(request!.passengerEmail!+"DestinatonID"),position: request!.destination!,icon: BitmapDescriptor.defaultMarker));
                                                          destinations.add(request!.destination!);
                                                          mapController.future.then((value) {
                                                            value.animateCamera(
                                                              CameraUpdate.newCameraPosition(
                                                                CameraPosition(
                                                                  target: LatLng(
                                                                    request!.location!.latitude as double,
                                                                    request!.location!.longitude as double,
                                                                  ),
                                                                  zoom: 14,
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                        });
                                                      },
                                                      child: Text("Arrived".tr(), style: const TextStyle(color: Colors.white, fontSize: 20),),
                                                    ),
                                                  ),
                                                  SizedBox(height: height*0.03,),
                                                  Container(
                                                    width: width * 0.8,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.withOpacity(0.8),
                                                      borderRadius: BorderRadius.circular(26),
                                                    ),
                                                    child: TextButton(
                                                      onPressed: () async {
                                                        setState((){
                                                          isSyncing=true;
                                                        });
                                                        await DataAccessObject.instance.cancelRide(request!).then((value) {
                                                          if(mounted)
                                                          setState((){
                                                            inDrive=false;
                                                          });
                                                        });
                                                      },
                                                      child: Text("Cancel".tr(), style: const TextStyle(color: Colors.white, fontSize: 20),),
                                                    ),
                                                  )

                                                ],
                                              ),
                                            );

                                          }
                                            else if (distance(request.location!, _currentPosition!)<=100000000 && request.status=="searching") {
                                              inDrive=false;
                                              getDestinationSourceName(request);
                                              markers.add(Marker(markerId: MarkerId(request!.passengerEmail!+"LocationID"),position: request!.location!,icon: BitmapDescriptor.defaultMarker));
                                              markers.add(Marker(markerId: MarkerId(request!.passengerEmail!+"DestinatonID"),position: request!.destination!,icon: BitmapDescriptor.defaultMarker));
                                              destinations.clear();
                                              destinations.add(request!.location!);
                                              return Container(
                                                padding: EdgeInsets.only(left:20,right: 20),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(request.passengerName!, style: const TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold),),
                                                    InkWell(
                                                        onTap: () async {
                                                          final Uri _phoneUri = Uri(
                                                              scheme: "tel",
                                                              path: request!.passengerNumber!
                                                          );
                                                          try {
                                                            if (await canLaunch(_phoneUri.toString()))
                                                              await launch(_phoneUri.toString());
                                                          } catch (error) {
                                                            throw("Cannot dial");
                                                          }
                                                        },
                                                        child:
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            Icon(Icons.call,color: Colors.green,size: 28,),
                                                          ],
                                                        )
                                                    ),
                                                    SizedBox(height: height*0.03,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(request!.price.toString() +" "+"JD".tr(),style: TextStyle(color: Colors.white,fontSize: 16),textAlign: TextAlign.left,),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(request.seatNumber.toString(),style: TextStyle(color: Colors.white,fontSize: 16),textAlign: TextAlign.left,),
                                                            Icon(Icons.event_seat_rounded,color: Colors.white,size: 26,),
                                                          ],
                                                        ),

                                                      ],
                                                    ),
                                                    sourceName.isNotEmpty?
                                                    Text(sourceName, style: const TextStyle(color: Colors.white, fontSize: 16),):Container(width: 20,height: 20,child: CircularProgressIndicator(),),
                                                    SizedBox(height: height*0.01,),
                                                    Icon(CupertinoIcons.arrow_up_arrow_down_circle,color: Colors.white,size: 32,),
                                                    SizedBox(height: height*0.01,),
                                                    destinationName.isNotEmpty?
                                                    Text(destinationName, style: const TextStyle(color: Colors.white, fontSize: 16),):Container(width: 20,height: 20,child: CircularProgressIndicator(),),
                                                    SizedBox(height: height*0.02,),
                                                    Container(
                                                      width: width * 0.8,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.withOpacity(0.8),
                                                        borderRadius: BorderRadius.circular(26),
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () async {
                                                          setState((){
                                                            isSyncing=true;
                                                          });
                                                          await DataAccessObject.instance.acceptRequest(request!).then((value) {
                                                            setState((){
                                                              isSyncing=false;
                                                              inDrive=true;
                                                            });
                                                            requestStream=DataAccessObject().RequestStream(request!);
                                                            mapController.future.then((value) {
                                                              value.animateCamera(
                                                                CameraUpdate.newCameraPosition(
                                                                  CameraPosition(
                                                                    target: LatLng(
                                                                      request!.location!.latitude as double,
                                                                      request!.location!.longitude as double,
                                                                    ),
                                                                    zoom: 16,
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                          });
                                                        },
                                                        child: Text("Agree".tr(), style: const TextStyle(color: Colors.white, fontSize: 20),),
                                                      ),
                                                    ),
                                                    SizedBox(height: height*0.03,),
                                                    Container(
                                                      width: width * 0.8,
                                                      decoration: BoxDecoration(
                                                        color: Colors.red.withOpacity(0.8),
                                                        borderRadius: BorderRadius.circular(26),
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () async {
                                                          setState((){
                                                            requestStream=DataAccessObject().RequestStream(request!);
                                                            isSyncing=true;
                                                          });
                                                          DataAccessObject().rejectRequest(request!).then((value) {
                                                            rejectedRequests.add(request!);
                                                            destinations.clear();
                                                            polylines.clear();
                                                            markers.clear();
                                                            request=null;
                                                            setState((){
                                                              inDrive=false;
                                                              isSyncing=false;
                                                            });
                                                          });
                                                        },
                                                        child: Text("Decline".tr(), style: const TextStyle(color: Colors.white, fontSize: 20),),
                                                      ),
                                                    )

                                                  ],
                                                ),
                                              );
                                          }
                                            else if (request.status == "Driver Arrived"){
                                              inDrive=true;
                                              return  Container(
                                                padding: EdgeInsets.only(left:20,right: 20),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(request.passengerName!, style: const TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold),),
                                                    InkWell(
                                                        onTap: () async {
                                                          final Uri _phoneUri = Uri(
                                                              scheme: "tel",
                                                              path: request!.passengerNumber!
                                                          );
                                                          try {
                                                            if (await canLaunch(_phoneUri.toString()))
                                                              await launch(_phoneUri.toString());
                                                          } catch (error) {
                                                            throw("Cannot dial");
                                                          }
                                                        },
                                                        child:
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            Icon(Icons.call,color: Colors.green,size: 28,),
                                                          ],
                                                        )
                                                    ),
                                                    SizedBox(height: height*0.03,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(request!.price.toString() +" "+"JD".tr(),style: TextStyle(color: Colors.white,fontSize: 16),textAlign: TextAlign.left,),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(request.seatNumber.toString(),style: TextStyle(color: Colors.white,fontSize: 16),textAlign: TextAlign.left,),
                                                            Icon(Icons.event_seat_rounded,color: Colors.white,size: 26,),
                                                          ],
                                                        ),

                                                      ],
                                                    ),
                                                    sourceName.isNotEmpty?
                                                    Text(sourceName, style: const TextStyle(color: Colors.white, fontSize: 16),):Container(width: 20,height: 20,child: CircularProgressIndicator(),),                                                    SizedBox(height: height*0.01,),
                                                    Icon(CupertinoIcons.arrow_up_arrow_down_circle,color: Colors.white,size: 32,),
                                                    SizedBox(height: height*0.01,),
                                                    destinationName.isNotEmpty?
                                                    Text(destinationName, style: const TextStyle(color: Colors.white, fontSize: 16),):Container(width: 20,height: 20,child: CircularProgressIndicator(),),                                                    SizedBox(height: height*0.02,),
                                                    Container(
                                                      width: width * 0.8,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.withOpacity(0.8),
                                                        borderRadius: BorderRadius.circular(26),
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () async {
                                                          setState((){
                                                            isSyncing=true;
                                                          });
                                                          await DataAccessObject.instance.startRide(request!).then((value) {
                                                            setState((){
                                                              inDrive=true;
                                                              isSyncing=false;
                                                            });

                                                          });
                                                        },
                                                        child: Text("Start Ride".tr(), style: const TextStyle(color: Colors.white, fontSize: 20),),
                                                      ),
                                                    ),
                                                    SizedBox(height: height*0.03,),
                                                    Container(
                                                      width: width * 0.8,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.withOpacity(0.8),
                                                        borderRadius: BorderRadius.circular(26),
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () async {
                                                          setState((){
                                                            isSyncing=true;
                                                          });
                                                          await DataAccessObject.instance.cancelRide(request!).then((value) {
                                                            setState((){
                                                              isSyncing=false;
                                                              inDrive=false;
                                                            });
                                                          });
                                                        },
                                                        child: Text("Cancel".tr(), style: const TextStyle(color: Colors.white, fontSize: 20),),
                                                      ),
                                                    )

                                                  ],
                                                ),
                                              );
                                          }
                                            else if (request.status == "on the way"){
                                              inDrive=true;
                                              return Container(
                                                padding: EdgeInsets.only(left:20,right: 20),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(request.passengerName!, style: const TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold),),
                                                    InkWell(
                                                        onTap: () async {
                                                          final Uri _phoneUri = Uri(
                                                              scheme: "tel",
                                                              path: request!.passengerNumber!
                                                          );
                                                          try {
                                                            if (await canLaunch(_phoneUri.toString()))
                                                              await launch(_phoneUri.toString());
                                                          } catch (error) {
                                                            throw("Cannot dial");
                                                          }
                                                        },
                                                        child:
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            Icon(Icons.call,color: Colors.green,size: 28,),
                                                          ],
                                                        )
                                                    ),
                                                    SizedBox(height: height*0.03,),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(request!.price.toString() +" "+"JD".tr(),style: TextStyle(color: Colors.white,fontSize: 16),textAlign: TextAlign.left,),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(request.seatNumber.toString(),style: TextStyle(color: Colors.white,fontSize: 16),textAlign: TextAlign.left,),
                                                            Icon(Icons.event_seat_rounded,color: Colors.white,size: 26,),
                                                          ],
                                                        ),

                                                      ],
                                                    ),
                                                    sourceName.isNotEmpty?
                                                    Text(sourceName, style: const TextStyle(color: Colors.white, fontSize: 16),):Container(width: 20,height: 20,child: CircularProgressIndicator(),),                                                    SizedBox(height: height*0.01,),
                                                    Icon(CupertinoIcons.arrow_up_arrow_down_circle,color: Colors.white,size: 32,),
                                                    SizedBox(height: height*0.01,),
                                                    destinationName.isNotEmpty?
                                                    Text(destinationName, style: const TextStyle(color: Colors.white, fontSize: 16),):Container(width: 20,height: 20,child: CircularProgressIndicator(),),                                                    SizedBox(height: height*0.02,),
                                                    Container(
                                                      width: width * 0.8,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.withOpacity(0.8),
                                                        borderRadius: BorderRadius.circular(26),
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () async {
                                                          setState((){
                                                            isSyncing=true;
                                                          });
                                                          await DataAccessObject.instance.onPayment(request!).then((value) {
                                                            setState((){
                                                              isSyncing=false;
                                                            });
                                                            destinations.clear();
                                                            markers.clear();
                                                            polylines.clear();
                                                            mapController.future.then((value){
                                                              value.animateCamera(
                                                                CameraUpdate.newCameraPosition(
                                                                  CameraPosition(
                                                                    target: LatLng(
                                                                      request!.location!.latitude as double,
                                                                      request!.location!.longitude as double,
                                                                    ),
                                                                    zoom: 16,
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                          });
                                                        },
                                                        child: Text("Finish Ride".tr(), style: const TextStyle(color: Colors.white, fontSize: 20),),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                          }
                                            else if(request.status == "on payment"){
                                              inDrive=true;
                                              return Column(
                                                 children: [
                                                   Text("Total Price is".tr(),style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
                                                   SizedBox(height: 20,),
                                                   Text(request!.price.toString()+" "+"JD".tr(),style: TextStyle(color: Colors.green,fontSize: 18),),
                                                   SizedBox(height: 20,),
                                                   Container(
                                                     width: width * 0.8,
                                                     decoration: BoxDecoration(
                                                       color: Colors.green.withOpacity(0.8),
                                                       borderRadius: BorderRadius.circular(26),
                                                     ),
                                                     child: TextButton(
                                                       onPressed: () async {
                                                         setState((){
                                                           isSyncing=true;
                                                         });
                                                         await DataAccessObject.instance.finishRide(request!).then((value) {
                                                           setState((){
                                                             inDrive=false;
                                                             isSyncing=false;
                                                             destinations.clear();
                                                             markers.clear();
                                                           });
                                                           mapController.future.then((value) {
                                                             value.animateCamera(
                                                               CameraUpdate.newCameraPosition(
                                                                 CameraPosition(
                                                                   target: LatLng(
                                                                     request!.location!.latitude as double,
                                                                     request!.location!.longitude as double,
                                                                   ),
                                                                   zoom: 16,
                                                                 ),
                                                               ),
                                                             );
                                                           });
                                                         });
                                                       },
                                                       child: Text("Done".tr(), style: const TextStyle(color: Colors.white, fontSize: 20),),
                                                     ),
                                                   ),

                                                 ],
                                              );
                                            }
                                          }
                                            return Center(
                                              child: CircularProgressIndicator(),
                                            );
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
    );
  }
}
