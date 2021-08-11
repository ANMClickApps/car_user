//API Keys Google Map
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'models/user_model.dart';

String mapKeyAndroid = 'YOUR KEY HERE';
String mapKeyIos = 'YOUR KEY HERE';

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

User currentFirebaseUser;
UserModel currentUserInfo;
String serverKey = 'key=YOUR KEY HERE CLOUD MESSAGING';
