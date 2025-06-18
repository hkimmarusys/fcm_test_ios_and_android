import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../controller.dart';

class ApiService {
  final MainController controller = Get.find<MainController>();
  final Uri baseUrl = Uri.parse('https://demo.marusys.com/brcm/');

  Future<void> sendToken({ required String said }) async {
    final token = controller.fcmToken.value;
    var type = controller.type.value;

    try {
      final response = await http.post(
        baseUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'mode': 'registor',
          'said': said,
          'type': type,
          'token': token,
        }),
      );

      print('said : $said, type : $type, token : $token');


      if (response.statusCode == 200) {
        print('Token saved on server successfully: ${response.body}');
      } else {
        print('Failed to save token: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while sending token: $e');
    }
  }
}
