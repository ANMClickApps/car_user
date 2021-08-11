import 'package:car_user/constant_text.dart';
import 'package:car_user/dataprovider/app_data.dart';
import 'package:car_user/global_varible.dart';
import 'package:car_user/helpers/request_helper.dart';
import 'package:car_user/models/address.dart';
import 'package:car_user/models/prediction.dart';
import 'package:car_user/style/brand_color.dart';
import 'package:car_user/widgets/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  PredictionTile({this.prediction});

  void getPlaceDetails(String placeID, context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(status: textLoading));

    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$mapKeyAndroid';

    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context); //when dialog complite => navigator close dialog

    if (response == 'failed') {
      return;
    }
    if (response['status'] == 'OK') {
      Address thisPlace = Address();
      thisPlace.placeName = response['result']['name'];
      thisPlace.placeId = placeID;
      thisPlace.latitude = response['result']['geometry']['location']['lat'];
      thisPlace.longitude = response['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context, listen: false)
          .updateDestinationAddress(thisPlace);

      print(thisPlace.placeName);

      Navigator.pop(context, 'getDirection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        getPlaceDetails(prediction.placeId, context);
      },
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
      ),
      child: Container(
        child: Column(
          children: [
            SizedBox(height: 8.0),
            Row(
              children: [
                Icon(
                  OMIcons.locationOn,
                  color: BrandColor.colorDimText,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prediction.mainText,
                        style: TextStyle(fontSize: 16.0),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      Text(
                        prediction.secondaryText,
                        style: TextStyle(
                            fontSize: 12.0, color: BrandColor.colorDimText),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
