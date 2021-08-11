import 'package:car_user/style/brand_color.dart';
import 'package:car_user/widgets/taxi_outline_button.dart';
import 'package:flutter/material.dart';

class NoDriverDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(6.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10.0),
                Text(
                  'No driver found',
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 25.0),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No available driver close by, we suggest you try again shortly',
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 30.0),
                Container(
                  width: 200.0,
                  child: TaxiOutlineButton(
                      title: 'Close',
                      color: BrandColor.colorLightGrayFair,
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
                SizedBox(height: 10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
