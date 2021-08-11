import 'package:car_user/style/brand_color.dart';
import 'package:flutter/material.dart';

class TaxiOutlineButton extends StatelessWidget {
  final String title;
  final Function onPressed;
  final Color color;
  final bool whiteActive;

  TaxiOutlineButton(
      {this.title, this.onPressed, this.color, this.whiteActive: false});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0))),
        side: MaterialStateProperty.all(BorderSide(
            color: whiteActive ? color : Colors.blueGrey, width: 0.5)),
        backgroundColor: MaterialStateProperty.all<Color>(color),
      ),
      onPressed: onPressed,
      child: Container(
        height: 50.0,
        child: Center(
          child: Text(title,
              style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: whiteActive ? Colors.white : BrandColor.colorText)),
        ),
      ),
    );
  }
}
