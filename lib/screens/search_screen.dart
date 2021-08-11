import 'package:car_user/constant_text.dart';
import 'package:car_user/dataprovider/app_data.dart';
import 'package:car_user/global_varible.dart';
import 'package:car_user/helpers/request_helper.dart';
import 'package:car_user/models/prediction.dart';
import 'package:car_user/style/brand_color.dart';
import 'package:car_user/widgets/custom_divider.dart';
import 'package:car_user/widgets/prediction_tile.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var pickupController = TextEditingController();
  var destinationController = TextEditingController();

  var focusDestination = FocusNode();
  bool focused = false;

  void setFocus() {
    focusDestination.requestFocus();
    focused = true;
  }

  List<Prediction> destinationsPredictionList = [];

  void searchPlace(String placeName) async {
    if (placeName.length > 1) {
      String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKeyAndroid&sessiontoken=1234567890';

      var response = await RequestHelper.getRequest(url);

      if (response == 'failed') {
        return;
      }
      if (response['status'] == 'OK') {
        var predictionJson = response['predictions'];

        var thisList = (predictionJson as List)
            .map((e) => Prediction.fromJson(e))
            .toList();
        setState(() {
          destinationsPredictionList = thisList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    setFocus();
    String address =
        Provider.of<AppData>(context).pickupAddress.placeName ?? '';
    pickupController.text = address;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 210.0,
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                )
              ]),
              child: Padding(
                padding: EdgeInsets.only(
                    left: 24.0, top: 48.0, right: 24.0, bottom: 20.0),
                child: Column(
                  children: [
                    SizedBox(height: 5.0),
                    Stack(
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.arrow_back)),
                        Center(
                          child: Text(
                            textSearchScreenTitle,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 18.0),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/pickicon.png',
                          height: 16.0,
                          width: 16.0,
                          color: Colors.green,
                        ),
                        SizedBox(width: 18.0),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: BrandColor.colorLightGrayFair,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(2.0),
                              child: TextField(
                                controller: pickupController,
                                decoration: InputDecoration(
                                    hintText: textSearchMyPosition,
                                    fillColor: BrandColor.colorLightGrayFair,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 10.0, top: 8, bottom: 8.0)),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/desticon.png',
                          height: 18.0,
                          width: 18.0,
                          color: Colors.blueAccent,
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: BrandColor.colorLightGrayFair,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(2.0),
                              child: TextField(
                                onChanged: (value) {
                                  searchPlace(value);
                                },
                                focusNode: focusDestination,
                                controller: destinationController,
                                decoration: InputDecoration(
                                    hintText: textSearchMyDestionation,
                                    fillColor: BrandColor.colorLightGrayFair,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 10.0, top: 8, bottom: 8.0)),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            (destinationsPredictionList.length > 1)
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListView.separated(
                      padding: EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        return PredictionTile(
                          prediction: destinationsPredictionList[index],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          CustomDivider(),
                      itemCount: destinationsPredictionList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
