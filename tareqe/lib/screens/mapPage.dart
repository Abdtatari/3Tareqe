import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:tareqe/models/PassengerRequest.dart';
import 'package:tareqe/models/car.dart';
import 'package:tareqe/models/sessionInfo.dart';
import 'package:tareqe/screens/driverMapPage.dart';
import 'package:tareqe/screens/login.dart';
import 'package:tareqe/models/theme.dart';
import 'package:tareqe/screens/passengerRequestPage.dart';
import '../custom_widget/custom_form_button.dart';
import '../custom_widget/drawer.dart';
import '../models/DAO.dart';
import '../models/student.dart';
import 'package:tareqe/models/pricing.dart';
import 'package:location/location.dart' as location_package;
class map_page extends StatefulWidget {
  const map_page({Key? key}) : super(key: key);

  @override
  State<map_page> createState() => _map_pageState();
}

class _map_pageState extends State<map_page> {

  late List<LatLng> destinations=[
   // LatLng(32.0469924, 35.7772887),
  ];
  late List<Color> lineColors=appTheme.mapLinesColors;
  Set<Polyline> polylines={};
  LatLng? pickupLocation;
  Completer<GoogleMapController> mapController=Completer();
  late StreamSubscription<LocationData> locationSubscription;
  LatLng? _currentPosition;
  Location _Location = Location();
  Marker? locationMarker;
  BitmapDescriptor? customIcon;
// make sure to initialize before map loading

  Set<Marker> markers={};
  Set<Circle> circles={
    Circle(
      center: LatLng(32.04654859397376, 35.77937610447407),
      circleId: CircleId("universityCircle"),
      radius: 500,
      fillColor: appTheme.circleMapColor.withOpacity(0.3),
      strokeWidth: 0,
    )
  };
  double searchRadius = 500;//in meters
  bool activeDriver=SessionInfo.currentStudent.isDriving!;
  bool isSyncing = false;
  late bool first;
  int? seatsNumber;
  bool fromUni=false;
  double price=0;
  TextEditingController destinationController = TextEditingController();
  final _FormKey = GlobalKey<FormState>();

  @override
  void initState() {
    seatsNumber=1;
    first=true;
    getCurrentUserData();
    super.initState();
  }

  @override
  void dispose() {
    mapController = Completer();
    locationSubscription.cancel();
    super.dispose();
  }

  void checkIfHaveRequest() async{
    await DataAccessObject.instance.checkHaveRequest(SessionInfo.currentStudent.email!).then((value){
      if (value != null){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PassengerRequestPage(request: value)),
        ).then((value) {
          checkIfHaveRequest();
        });
    }
    });
  }
  void getCurrentUserData() async{
    setState(() {
      isSyncing = true;
    });
    DataAccessObject db =DataAccessObject.instance;
    if (!await db.checkIfActive(db.firebaseAuth.currentUser!.email!)){
      db.logout().then((value) => SignoutFeedback(value));
    }
    else {
    SessionInfo.currentStudent = (await db.getCurrentUserInfo(db.firebaseAuth.currentUser!.uid))!;
    activeDriver=SessionInfo.currentStudent.isDriving!;
    checkIfHaveRequest();
    }
    if(mounted) {
      setState(() {
        isSyncing = false;
      });
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(6, 6)),
        'assets/images/car_icon.png')
        .then((d) {
      customIcon = d;
    });
    await _Location.getLocation().then((value) async {
      _currentPosition= LatLng(value.latitude!,value.longitude!);
      DataAccessObject db= DataAccessObject();
      await db.getActiveDrivers().then((value) {
        for (Student driver in value) {
          if (distance(LatLng(driver.latitude!, driver.longitude!),_currentPosition!)<=searchRadius){
            if (mounted)
            setState(() {
              markers.add(
                  Marker(
                    markerId: MarkerId(driver.email!+"marker-id"),
                    position: LatLng(driver.latitude!,driver.longitude!),
                    icon:  customIcon!,
                  ));
            });
          }
        }
      });
    });
    circles.add(
        Circle(
          circleId:CircleId("currentLocation"),
          center: _currentPosition!,
          strokeWidth: 0,
          fillColor: Colors.blue.withOpacity(0.3),
          radius: searchRadius
        ),);
    locationSubscription = _Location.onLocationChanged.listen((LocationData currentLocation) async {
      _currentPosition=LatLng(currentLocation.latitude!, currentLocation.longitude!);
      if(first&&!mapController.isCompleted){
        mapController.complete(controller);
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
        });
        first=false;
      }
      //getPolyPoints(LatLng(currentLocation.latitude!,currentLocation.longitude!));
    });
  }

  List <LatLng> fromPointLatLngtoLatLng(List<PointLatLng> points){
    List <LatLng> result=[];
    for (var point in points){
      result.add(LatLng(point.latitude, point.longitude));
    }
    return result;
  }

  Future <void> getPolyPoints(LatLng pickupLocation) async{
    PolylinePoints polylinePoint = PolylinePoints();
    int id=0;
    polylines.clear();
    for (LatLng destination in destinations ){
      PolylineResult result = await polylinePoint.getRouteBetweenCoordinates(
          "AIzaSyCeaTeAw2Y7uRE7GIL_KGCUPl2fRCBgzHs",
          PointLatLng(pickupLocation!.latitude, pickupLocation!.longitude),
          PointLatLng(destination.latitude,destination.longitude),
        optimizeWaypoints: true
      );
      List <LatLng> castedPoint=fromPointLatLngtoLatLng(result.points);
      polylines.add(
          Polyline(
            polylineId: PolylineId("polyline"+id.toString()),
            points: castedPoint,
              color: id<lineColors.length?lineColors[id]:Colors.blue,
              width: 6
          )
      );
      id++;
    }
    setState(() {
    });
  }

  Future _addMarkerLongPressed(LatLng pickupLatLng) async {
    pickupLocation=pickupLatLng;
    print(pickupLocation);
    if (locationMarker!=null){
      markers.remove(locationMarker);
    }
      final MarkerId markerId = MarkerId("positionMarker");
      Marker marker = Marker(
        markerId: markerId,
        draggable: true,
        position: pickupLatLng,
        icon: BitmapDescriptor.defaultMarker,
      );
      locationMarker=marker;
      markers.add(marker);
      if (distance(pickupLatLng, LatLng(32.04654859397376, 35.77937610447407))<=500){
        fromUni=true;
        await geocoding.placemarkFromCoordinates(pickupLatLng.latitude, pickupLatLng.longitude).then((value) {
          print(value.first.subLocality);
          if (pricing.price.containsKey(value.first.subLocality)){
          price= pricing.price[value.first.subLocality]!;
          }
          else{
            price=3;
          }
        });
        setState(() {

        });
      }
      else{
        destinationController.text="";
        fromUni=false;
        destinations.clear();
        destinations.add(LatLng(32.0469879,35.7772887));
        getPolyPoints(pickupLocation!);
        await geocoding.placemarkFromCoordinates(pickupLatLng.latitude, pickupLatLng.longitude,localeIdentifier: "en").then((value) {
          print(value.first.subLocality);
          if (pricing.price.containsKey(value.first.subLocality)){
            price= pricing.price[value.first.subLocality]!;
          }
          else{
            price=3;
          }
        });
      }
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
          onLongPress: (pickupLatLng) {
            _addMarkerLongPressed(pickupLatLng); //we will call this function when pressed on the map
          },
          polylines: polylines,
          markers: markers,
          circles: circles,
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          trafficEnabled: false,
          initialCameraPosition: CameraPosition(
              target: _currentPosition ??
                  LatLng(32.0469879,35.7772887),
              zoom: 16),
        ),
        Form(
            child: Column(
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
                    child: pickupLocation == null ? Center(child:Text("Long press to select pickup location".tr(),style: TextStyle(color: Colors.white,fontSize: 18),)):
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        !fromUni?
                            Column(
                              children: [
                                Text("You are going to university".tr(),style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18
                                ),),
                                Row(
                                  children: [
                                    SizedBox(width: 20,),
                                    Text(price.toString()+"JD".tr(),style: TextStyle(color: Colors.green),),
                                    Icon(Icons.attach_money,color: Colors.green,),
                                    SizedBox(width: 20,),
                                  ],
                                ),
                              ],
                            )
                            :
                        Column(
                          children: [
                                Text("You are going back from university".tr(),style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18
                                ),),
                            Row(
                              children: [
                                SizedBox(width: 20,),
                                Text(price.toString()+"JD".tr(),style: TextStyle(color: Colors.green),),
                                Icon(Icons.attach_money,color: Colors.green,),
                                SizedBox(width: 20,),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Container(
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.only(left: 5,right: 5),
                              width: width*0.8,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              child:InkWell(
                                onTap: () async {
                                  const kGoogleApiKey = "AIzaSyCeaTeAw2Y7uRE7GIL_KGCUPl2fRCBgzHs";
                                  await PlacesAutocomplete.show(
                                      types: [],
                                      components: [],
                                      strictbounds:false,
                                      context: context,
                                      apiKey: kGoogleApiKey,
                                      mode: Mode.fullscreen, // Mode.fullscreen
                                      language: "en").then((value) async {
                                    destinationController.text=value!.description!;
                                    await geocoding.GeocodingPlatform.instance.locationFromAddress(
                                      destinationController.text
                                      ).then((value){
                                      setState(() {
                                        destinations.clear();
                                        destinations.add(LatLng(value[0].latitude,value[0].longitude));
                                        getPolyPoints(pickupLocation!);
                                      });
                                    });
                                  });
                                },
                                child: TextFormField(
                                  enabled: false,
                                  validator: (textValue) {
                                    if(textValue == null || textValue.isEmpty) {
                                      return 'Destination is required!'.tr();
                                    }
                                    return null;
                                  },
                                  controller: destinationController,
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(color: Colors.red),
                                      border: InputBorder.none,
                                      labelText: "Destination".tr(),
                                      labelStyle: TextStyle(
                                        color: Colors.white60,
                                      ),
                                      icon: Icon(CupertinoIcons.search,color: Colors.white,)
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("Number of Seats".tr(),style: TextStyle(color: Colors.white,fontSize: 18),),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: (){
                                      if (seatsNumber!<5){
                                        setState((){
                                          seatsNumber=seatsNumber!+1;
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:context.locale==Locale("en")? BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10)):BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10)),
                                        color: Colors.white,
                                      ),
                                      width: 40,
                                      height: 30,
                                      child: Icon(CupertinoIcons.plus),
                                    ),),
                                  Container(
                                    width: 40,
                                    height: 30,
                                    color: Colors.white,
                                    child: Center(
                                      child:Text(
                                        seatsNumber.toString(),
                                        style: TextStyle(
                                          color: appTheme.passengerRequestCard,
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: (){
                                      setState(() {
                                        if (seatsNumber!>1){
                                          seatsNumber=seatsNumber!-1;
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: context.locale==Locale("en")?BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10)):BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10)),
                                        color: Colors.white,
                                      ),
                                      width: 40,
                                      height: 30,
                                      child: Icon(CupertinoIcons.minus),
                                    ),)
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: width * 0.8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: TextButton(
                            onPressed: () async {
                                if (_FormKey.currentState!.validate()!){
                                setState(() {
                                  isSyncing=true;
                                });
                                PassengerRequest request = PassengerRequest(
                                    passengerEmail:
                                    SessionInfo.currentStudent.email,
                                    passengerName: SessionInfo.currentStudent.name,
                                    passengerNumber: SessionInfo.currentStudent.phoneNumber,
                                    location: fromUni?LatLng(32.0470046, 35.7769198):pickupLocation,
                                    destination: fromUni?destinations.first: LatLng(32.0470046, 35.7769198),
                                    seatNumber: seatsNumber,
                                    price: price,
                                    status: "searching",
                                  driver: Student(name: "",email: "",password: "",gender: "",phoneNumber: "0", isActive: false, photo: "", approvedToBeDriver: false, isDriving: false, type: 1,car: Car()));
                                DataAccessObject db = DataAccessObject();
                                db.addPassengerRequest(request).then((value) {
                                  if(value){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => PassengerRequestPage(request: request)),
                                    ).then((value) {
                                      checkIfHaveRequest();
                                    });
                                  }
                                  setState((){
                                    isSyncing=false;
                                  });
                                });
                                }
                              },
                            child: Text("Send Request".tr(), style: const TextStyle(color: Colors.white, fontSize: 20),),
                          ),
                        )
                      ],
                    )
                ),
              ],
            )
          ],
        ),
          key: _FormKey,
        )
      ],)
    )
    );
  }
  SignoutFeedback(value){
    SessionInfo.clear();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => sessionHandler()),
            (route) => false);
  }
}


