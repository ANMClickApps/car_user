import 'package:car_user/models/address.dart';
import 'package:flutter/material.dart';

class AppData extends ChangeNotifier {
  Address pickupAddress;
  Address destinationAddress;

  void updatePickupAddress(Address pickup) {
    pickupAddress = pickup;
    notifyListeners();
  }

  void updateDestinationAddress(Address destination) {
    destinationAddress = destination;
    notifyListeners();
  }
}
