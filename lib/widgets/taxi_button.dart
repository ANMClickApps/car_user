import 'package:flutter/material.dart';

class TaxiButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  const TaxiButton({Key key, this.text, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Container(
        height: 50.0,
        child: Center(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.8),
          ),
        ),
      ),
    );
  }
}
