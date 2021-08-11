import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestHelper {
  static Future<dynamic> getRequest(String url) async {
    http.Response response = await http.get(url);

    try {
      if (response.statusCode == 200) {
        String data = response.body;
        var decodeData = jsonDecode(data);
        return decodeData;
      } else {
        return 'failed';
      }
    } catch (e) {
      return 'failed';
    }
  }
}
