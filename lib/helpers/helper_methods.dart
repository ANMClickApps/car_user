import 'dart:convert';
import 'dart:math';

import 'package:car_user/dataprovider/app_data.dart';
import 'package:car_user/global_varible.dart';
import 'package:car_user/helpers/request_helper.dart';
import 'package:car_user/models/address.dart';
import 'package:car_user/models/direction_detail.dart';
import 'package:car_user/models/user_model.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HelperMethods {
  static void getCurrenUserInfo() {
    //currentFirebaseUser and currenUserInfo from global variables
    currentFirebaseUser = FirebaseAuth.instance.currentUser;
    String userId = currentFirebaseUser.uid;
    DatabaseReference userRef =
        FirebaseDatabase.instance.reference().child('user/$userId');
    userRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        currentUserInfo = UserModel.fromSnapshot(snapshot);
        print('My name is ${currentUserInfo.fullName}');
      }
    });
  }

  static Future<String> findCordinateAddress(Position position, context) async {
    String placeAddress = '';

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return placeAddress;
    }
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&language=ru&key=$mapKeyAndroid';

    var response = await RequestHelper.getRequest(url);

    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];
      Address pickupAddress = Address();
      pickupAddress.latitude = position.latitude;
      pickupAddress.longitude = position.longitude;
      pickupAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(pickupAddress);
    }
    return placeAddress;
  }

  static Future<DirectionDetail> getDirectionDetails(
      LatLng startPosition, LatLng endPosition) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKeyAndroid';

    var response = await RequestHelper.getRequest(url);

    if (response == 'failed') {
      return null;
    }

    DirectionDetail directionDetails = DirectionDetail();

    directionDetails.durationText =
        response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue =
        response['routes'][0]['legs'][0]['duration']['value'];
    directionDetails.distanceText =
        response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue =
        response['routes'][0]['legs'][0]['distance']['value'];

    directionDetails.encodedPoints =
        response['routes'][0]['overview_polyline']['points'];
    return directionDetails;
  }

  static int estimateFares(DirectionDetail details) {
    //per km = $0.7
    //per minute = $0.5,
    //base fare = $3
    double baseFare = 3;
    double distanceFare = (details.distanceValue / 1000) * 0.3;
    double timeFare = (details.durationValue / 60) * 0.2;

    double totalFare = baseFare + distanceFare + timeFare;
    return totalFare.truncate();
  }

  static double generateRandomNumber(int max) {
    var randomGenerator = Random();
    int randInt = randomGenerator.nextInt(max);
    return randInt.toDouble();
  }

  static sendNotification(String token, context, String rideID) async {
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Authorization': serverKey,
    };

    Map<String, dynamic> notificationMap = {
      'title': 'NEW TRIP REQUEST',
      'body': 'Destination, ${destination.placeName}',
    };

    Map<String, dynamic> dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'ride_id': rideID,
    };

    Map<String, dynamic> bodyMap = {
      'notification': notificationMap,
      'data': dataMap,
      'priority': 'high',
      'to': token,
    };
    var response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: headerMap,
      body: jsonEncode(bodyMap),
    );
    print(response.body);
  }
}
