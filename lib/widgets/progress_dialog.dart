import 'package:car_user/style/brand_color.dart';
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final String status;
  const ProgressDialog({Key key, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(16.0),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 5.0,
              ),
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(BrandColor.colorAccent),
              ),
              SizedBox(
                width: 25.0,
              ),
              Expanded(
                child: Text(
                  status,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 15.0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
