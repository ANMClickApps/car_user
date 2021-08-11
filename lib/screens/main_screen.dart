import 'dart:async';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:car_user/constant_text.dart';
import 'package:car_user/dataprovider/app_data.dart';
import 'package:car_user/helpers/fire_helper.dart';
import 'package:car_user/helpers/helper_methods.dart';
import 'package:car_user/models/direction_detail.dart';
import 'package:car_user/models/nearbydriver.dart';
import 'package:car_user/ride_variable.dart';
import 'package:car_user/screens/search_screen.dart';
import 'package:car_user/style/brand_color.dart';
import 'package:car_user/style/style.dart';
import 'package:car_user/widgets/collect_payment_dialog.dart';
import 'package:car_user/widgets/custom_divider.dart';
import 'package:car_user/widgets/nodriver_dialog.dart';
import 'package:car_user/widgets/progress_dialog.dart';
import 'package:car_user/widgets/taxi_button.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import '../global_varible.dart';

class MainScreen extends StatefulWidget {
  static const String id = 'main';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  double searchSheetHeight = (Platform.isIOS) ? 270.0 : 260.0;
  double rideDetailsSheetHeight = 0; // (Platform.isAndroid) ? 235 : 260
  double requestingSheetHeight = 0; // (Platform.isAndroid) ? 195 : 220
  double tripSheetHeight = 0; //(Platform.isAndroid) ? 275 : 300

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottomPadding = 0;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  BitmapDescriptor nearbyIcon;
  Position currenPosition;
  DirectionDetail tripDirectionDetails;
  bool drawerCanOpen = true;
  DatabaseReference rideRequest;
  List<NearbyDriver> availableDrivers;
  bool nearbyDriversKeysLoaded = false;
  String appState = 'NORMAL';
  StreamSubscription<Event> rideSubscription;

  bool isRequestingLocationDetails = false;

  @override
  void initState() {
    super.initState();
    HelperMethods.getCurrenUserInfo();
  }

  void createMarker() {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration,
              (Platform.isIOS)
                  ? 'assets/images/car-ios.png'
                  : 'assets/images/car-android.png')
          .then((icon) {
        nearbyIcon = icon;
      });
    }
  }

  void setupPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currenPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));

    startGeofirelistener();
    //Geocoding request and response
    String address =
        await HelperMethods.findCordinateAddress(position, context);
    print(address);
  }

  void showDetailSheet() async {
    await getDirection();
    setState(() {
      searchSheetHeight = 0;
      rideDetailsSheetHeight = (Platform.isAndroid) ? 240.0 : 230.0;
      mapBottomPadding = (Platform.isAndroid) ? 240.0 : 230.0;
      drawerCanOpen = false;
    });
  }

  void showRequestingSheet() {
    setState(() {
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = (Platform.isAndroid) ? 195.0 : 220.0;
      mapBottomPadding = (Platform.isAndroid) ? 200.0 : 190.0;
      drawerCanOpen = true;
    });
    createRideRequest();
  }

  showTripSheet() {
    setState(() {
      requestingSheetHeight = 0;
      tripSheetHeight = (Platform.isAndroid) ? 275.0 : 300.0;
      mapBottomPadding = (Platform.isAndroid) ? 280.0 : 270.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    createMarker();
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Container(
          width: 250.0,
          color: Colors.white,
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.all(0),
              children: [
                Container(
                  color: Colors.white,
                  height: 160.0,
                  child: DrawerHeader(
                    margin: EdgeInsets.only(bottom: 0),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/user_icon.png',
                          height: 60.0,
                          width: 60.0,
                        ),
                        SizedBox(width: 15.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Alex',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5.0),
                            Text('View Profile'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                CustomDivider(),
                SizedBox(height: 10.0),
                ListTile(
                    leading: Icon(OMIcons.cardGiftcard),
                    title: Text(textDrawedItem1, style: kDrawerItemStyle)),
                ListTile(
                    leading: Icon(OMIcons.creditCard),
                    title: Text(textDrawedItem2, style: kDrawerItemStyle)),
                ListTile(
                    leading: Icon(OMIcons.history),
                    title: Text(textDrawedItem3, style: kDrawerItemStyle)),
                ListTile(
                    leading: Icon(OMIcons.contactSupport),
                    title: Text(textDrawedItem4, style: kDrawerItemStyle)),
                ListTile(
                    leading: Icon(OMIcons.info),
                    title: Text(textDrawedItem5, style: kDrawerItemStyle)),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(bottom: mapBottomPadding),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              polylines: _polylines,
              markers: _markers,
              circles: _circles,
              initialCameraPosition: googlePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                mapController = controller;
                setState(() {
                  mapBottomPadding = (Platform.isAndroid) ? 280.0 : 270.0;
                });
                setupPositionLocator();
              },
            ),
            Positioned(
              top: 20.0,
              left: 20.0,
              child: GestureDetector(
                onTap: () {
                  if (drawerCanOpen) {
                    _scaffoldKey.currentState.openDrawer();
                  } else {
                    resetApp();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7),
                        )
                      ]),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20.0,
                    child: Icon(
                      (drawerCanOpen) ? Icons.menu : Icons.arrow_back,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            //Search Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 150),
                curve: Curves.easeIn,
                child: Container(
                  height: searchSheetHeight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7),
                        ),
                      ]),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            textWelcome,
                            style: TextStyle(fontSize: 10.0),
                          ),
                          Text(
                            textYouGo,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          GestureDetector(
                            onTap: () async {
                              var response = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchScreen()));

                              if (response == 'getDirection') {
                                showDetailSheet();
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.0),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5.0,
                                        spreadRadius: 0.5,
                                        offset: Offset(0.7, 0.7))
                                  ]),
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: Colors.blueAccent,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(textSearchDestination)
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 22.0,
                          ),
                          Row(
                            children: [
                              Icon(
                                OMIcons.home,
                                color: BrandColor.colorDimText,
                              ),
                              SizedBox(
                                width: 12.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(textAddHome),
                                  SizedBox(
                                    height: 3.0,
                                  ),
                                  Text(
                                    textHomeAddress,
                                    style: TextStyle(
                                        fontSize: 11.0,
                                        color: BrandColor.colorDimText),
                                  )
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          CustomDivider(),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: [
                              Icon(
                                OMIcons.workOutline,
                                color: BrandColor.colorDimText,
                              ),
                              SizedBox(
                                width: 12.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(textAddWork),
                                  SizedBox(
                                    height: 3.0,
                                  ),
                                  Text(
                                    textWorkAddress,
                                    style: TextStyle(
                                        fontSize: 11.0,
                                        color: BrandColor.colorDimText),
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //RideDetails Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 150),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7),
                        )
                      ]),
                  height: rideDetailsSheetHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 18.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: BrandColor.colorAccent1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/taxi-min.png',
                                  height: 70.0,
                                  width: 70.0,
                                ),
                                SizedBox(width: 16.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Taxi',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      (tripDirectionDetails != null)
                                          ? tripDirectionDetails.distanceText
                                          : '',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: BrandColor.colorTextLight),
                                    ),
                                  ],
                                ),
                                Expanded(child: Container()),
                                Text(
                                  (tripDirectionDetails != null)
                                      ? '${HelperMethods.estimateFares(tripDirectionDetails)} \$'
                                      : '',
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 22.0),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.moneyBillAlt,
                                size: 18.0,
                                color: BrandColor.colorTextLight,
                              ),
                              SizedBox(width: 16.0),
                              Text('Cash'),
                              SizedBox(width: 5.0),
                              Icon(Icons.keyboard_arrow_down,
                                  color: BrandColor.colorTextLight, size: 16.0)
                            ],
                          ),
                        ),
                        SizedBox(height: 22.0),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: TaxiButton(
                            text: textRequestTaxi,
                            onPressed: () {
                              setState(() {
                                appState = 'REQUESTING';
                              });
                              showRequestingSheet();

                              availableDrivers = FireHelper.nearbyDriverList;
                              findDriver();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            //Request Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 150),
                curve: Curves.easeIn,
                child: GestureDetector(
                  onTap: () {
                    cancelRequest();
                    resetApp();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15.0,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7),
                          )
                        ]),
                    height: requestingSheetHeight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10.0),
                          SizedBox(
                            width: double.infinity,
                            child: TextLiquidFill(
                              text: textRequestTrip,
                              waveColor: BrandColor.colorTextSemiLight,
                              boxBackgroundColor: Colors.white,
                              textStyle: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                              boxHeight: 40.0,
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Container(
                            height: 50.0,
                            width: 50.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25.0),
                              border: Border.all(
                                  width: 1.0,
                                  color: BrandColor.colorLightGrayFair),
                            ),
                            child: Icon(
                              Icons.close,
                              size: 25.0,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            width: double.infinity,
                            child: Text(
                              textTripCancel,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12.0),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //Trip Sheet
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 150),
                curve: Curves.easeIn,
                child: GestureDetector(
                  onTap: () {
                    cancelRequest();
                    resetApp();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15.0,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7),
                          )
                        ]),
                    height: tripSheetHeight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tripStatusDisplay,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 20.0),
                          CustomDivider(),
                          SizedBox(height: 20.0),
                          Text(
                            driverCarDetails,
                            style: TextStyle(
                              color: BrandColor.colorTextLight,
                            ),
                          ),
                          Text(
                            driverFullName,
                            style: TextStyle(fontSize: 20.0),
                          ),
                          SizedBox(height: 20.0),
                          CustomDivider(),
                          SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 50.0,
                                    width: 50.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                      border: Border.all(
                                          width: 1.0,
                                          color: BrandColor.colorTextLight),
                                    ),
                                    child: Icon(Icons.call),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text('Call')
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 50.0,
                                    width: 50.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                      border: Border.all(
                                          width: 1.0,
                                          color: BrandColor.colorTextLight),
                                    ),
                                    child: Icon(Icons.list),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text('Details')
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 50.0,
                                    width: 50.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25.0)),
                                      border: Border.all(
                                          width: 1.0,
                                          color: BrandColor.colorTextLight),
                                    ),
                                    child: Icon(OMIcons.clear),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text('Cancel')
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatLng = LatLng(destination.latitude, destination.longitude);

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(
              status: textLoading,
            ));

    var thisDetails =
        await HelperMethods.getDirectionDetails(pickLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetails = thisDetails;
    });

    Navigator.pop(context);

    //print(thisDetails.encodedPoints);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> result =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);
    polylineCoordinates.clear();
    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _polylines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polylines.add(polyline);
    });

    LatLngBounds bounds;

    if (pickLatLng.latitude > destinationLatLng.latitude &&
        pickLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
    } else if (pickLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickLatLng.longitude));
    } else if (pickLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickLatLng, northeast: destinationLatLng);
    }

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70.0));
    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup.placeName, snippet: 'Моя позиция'),
    );
    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: destination.placeName, snippet: 'Пункт назначения'),
    );
    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: BrandColor.colorGreen,
    );
    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColor.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: BrandColor.colorAccentPurple,
    );
    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

  void startGeofirelistener() {
    Geofire.initialize('driversAvailable');

    Geofire.queryAtLocation(
            currenPosition.latitude, currenPosition.longitude, 20)
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];
        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];
            FireHelper.nearbyDriverList.add(nearbyDriver);
            if (nearbyDriversKeysLoaded) {
              updateDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            FireHelper.removeFromList(map['key']);
            updateDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            // Update your key's location
            NearbyDriver nearbyDriver = NearbyDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];
            FireHelper.updateNearbyLocation(nearbyDriver);
            updateDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            // print(map['result']);
            nearbyDriversKeysLoaded = true;
            updateDriversOnMap();

            break;
        }
      }

      setState(() {});
    });
  }

  void updateDriversOnMap() {
    setState(() {
      _markers.clear();
    });

    Set<Marker> tempMarkers = Set<Marker>();
    for (NearbyDriver driver in FireHelper.nearbyDriverList) {
      LatLng driverPosition = LatLng(driver.latitude, driver.longitude);

      Marker thisMarker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverPosition,
        icon: nearbyIcon,
        rotation: HelperMethods.generateRandomNumber(360),
      );
      tempMarkers.add(thisMarker);
    }
    setState(() {
      _markers = tempMarkers;
    });
  }

  void createRideRequest() {
    rideRequest =
        FirebaseDatabase.instance.reference().child('rideRequest').push();

    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    Map pickupMap = {
      'latitude': pickup.latitude.toString(),
      'longitude': pickup.longitude.toString(),
    };

    Map destinationMap = {
      'latitude': destination.latitude.toString(),
      'longitude': destination.longitude.toString(),
    };

    Map rideMap = {
      'create_at': DateTime.now().toString(),
      'rider_name': currentUserInfo.fullName,
      'rider_phone': currentUserInfo.phone,
      'pickup_address': pickup.placeName,
      'destination_address': destination.placeName,
      'location': pickupMap,
      'destination': destinationMap,
      'payment_method': 'card',
      'driver_id': 'waiting',
    };
    rideRequest.set(rideMap);

    rideSubscription = rideRequest.onValue.listen((event) async {
      //check for null snapshot
      if (event.snapshot.value == null) {
        return;
      }

      //get car details
      if (event.snapshot.value['car_details'] != null) {
        setState(() {
          driverCarDetails = event.snapshot.value['car_details'].toString();
        });
      }
      //get driver name
      if (event.snapshot.value['driver_name'] != null) {
        setState(() {
          driverFullName = event.snapshot.value['driver_name'].toString();
        });
      }
      //get driver phone number
      if (event.snapshot.value['driver_phone'] != null) {
        setState(() {
          driverPhoneNumber = event.snapshot.value['driver_phone'].toString();
        });
      }

      //get and use driver location updates
      if (event.snapshot.value['driver_location'] != null) {
        double driverLat = double.parse(
            event.snapshot.value['driver_location']['latitude'].toString());
        double driverLng = double.parse(
            event.snapshot.value['driver_location']['longitude'].toString());
        LatLng driverLocation = LatLng(driverLat, driverLng);

        if (status == 'accepted') {
          updateToPickup(driverLocation);
        } else if (status == 'ontrip') {
          updateToDestination(driverLocation);
        } else if (status == 'arrived') {
          setState(() {
            tripStatusDisplay = 'Driver has arrived';
          });
        }
      }

      if (event.snapshot.value['status'] != null) {
        status = event.snapshot.value['status'].toString();
      }

      if (status == 'accepted') {
        showTripSheet();
        Geofire.stopListener();
        removeGeofireMarkers();
      }
      if (status == 'ended') {
        if (event.snapshot.value['fares'] != null) {
          int fares = int.parse(event.snapshot.value['fares'].toString());

          var response = await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => CollectPayment(
              paymentMethod: 'cash',
              fares: fares,
            ),
          );
          if (response == 'close') {
            rideRequest.onDisconnect();
            rideRequest = null;
            rideSubscription.cancel();
            rideSubscription = null;
            resetApp();
          }
        }
      }
    });
  }

  void removeGeofireMarkers() {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value.contains('driver'));
    });
  }

  void updateToPickup(LatLng driverLocation) async {
    if (!isRequestingLocationDetails) {
      isRequestingLocationDetails = true;

      var positionLatLng =
          LatLng(currenPosition.latitude, currenPosition.longitude);

      var thisDetails = await HelperMethods.getDirectionDetails(
          driverLocation, positionLatLng);

      if (thisDetails == null) {
        return;
      }

      setState(() {
        tripStatusDisplay = 'Driver is Arriving - ${thisDetails.durationText}';
      });

      isRequestingLocationDetails = false;
    }
  }

  void updateToDestination(LatLng driverLocation) async {
    if (!isRequestingLocationDetails) {
      isRequestingLocationDetails = true;

      var destination =
          Provider.of<AppData>(context, listen: false).destinationAddress;
      var destinationLatLng =
          LatLng(destination.latitude, destination.longitude);

      var thisDetails = await HelperMethods.getDirectionDetails(
          driverLocation, destinationLatLng);

      if (thisDetails == null) {
        return;
      }

      setState(() {
        tripStatusDisplay =
            'Driving to Destination - ${thisDetails.durationText}';
      });

      isRequestingLocationDetails = false;
    }
  }

  void cancelRequest() {
    rideRequest.remove();
    setState(() {
      appState = 'NORMAL';
    });
  }

  resetApp() {
    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
      _markers.clear();
      _circles.clear();
      rideDetailsSheetHeight = 0;
      requestingSheetHeight = 0;
      tripSheetHeight = 0;
      searchSheetHeight = (Platform.isIOS) ? 270.0 : 260.0;
      mapBottomPadding = (Platform.isAndroid) ? 280.0 : 270.0;
      drawerCanOpen = true;

      status = '';
      driverFullName = '';
      driverPhoneNumber = '';
      driverCarDetails = '';
      tripStatusDisplay = 'Driver is Arriving';
    });
    setupPositionLocator();
  }

  void noDriverFound() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NoDriverDialog());
  }

  void findDriver() {
    if (availableDrivers.length == 0) {
      cancelRequest();
      resetApp();
      noDriverFound();
      return;
    }
    var driver = availableDrivers[0];
    notifyDriver(driver);
    availableDrivers.removeAt(0);
    print(driver.key);
  }

  void notifyDriver(NearbyDriver driver) {
    DatabaseReference driverTripRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${driver.key}/newtrip');

    driverTripRef.set(rideRequest.key);
    //Get and notify driver using token
    DatabaseReference tokenRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${driver.key}/token');
    tokenRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        String token = snapshot.value.toString();
        //send notification to selected driver
        HelperMethods.sendNotification(token, context, rideRequest.key);
      } else {
        return;
      }
      const oneSecTick = Duration(seconds: 1);

      var timer = Timer.periodic(oneSecTick, (timer) {
        //stop timer when ride request is cancelled
        if (appState != 'REQUESTING') {
          driverTripRef.set('cancelled');
          driverTripRef.onDisconnect();
          timer.cancel();
          driverRequestTimeout = 30;
        }

        driverRequestTimeout--;

        //a value event listener for driver accepting trip request
        driverTripRef.onValue.listen((event) {
          //confirm that driver has clicked accepted for the new trip request
          if (event.snapshot.value.toString() == 'accepted') {
            driverTripRef.onDisconnect();
            timer.cancel();
            driverRequestTimeout = 30;
          }
        });

        if (driverRequestTimeout == 0) {
          //inform driver that ride has timed out
          driverTripRef.set('timeout');
          driverTripRef.onDisconnect();
          driverRequestTimeout = 30;
          timer.cancel();

          //select the next closest driver
          findDriver();
        }
      });
    });
  }
}
