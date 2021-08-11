import 'package:car_user/helpers/helper_methods.dart';
import 'package:car_user/widgets/custom_divider.dart';
import 'package:car_user/widgets/taxi_button.dart';
import 'package:flutter/material.dart';

class CollectPayment extends StatelessWidget {
  final String paymentMethod;
  final int fares;
  CollectPayment({this.paymentMethod, this.fares});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(40.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20.0),
            Text('${paymentMethod.toUpperCase()} PAYMENT'),
            SizedBox(height: 20.0),
            CustomDivider(),
            SizedBox(height: 16.0),
            Text(
              '\$$fares',
              style: TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Amount above is the total fares to be charged to the rider',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30.0),
            Container(
              width: 230.0,
              child: TaxiButton(
                text: (paymentMethod == 'cash') ? 'PAY CASH' : 'CONFIRM',
                onPressed: () {
                  Navigator.pop(context, 'close');
                },
              ),
            ),
            SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }
}
