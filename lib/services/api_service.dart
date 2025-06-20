import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller.dart';

class ApiService {
  final MainController controller = Get.find<MainController>();
  final Uri baseUrl = Uri.parse('https://demo.marusys.com/brcm/1111');

  static const _key = 'token_history';

  Future<void> sendToken({ required String said }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = controller.fcmToken.value;
    final type = controller.type.value;
    final rawLists =prefs.getStringList(_key) ?? [];


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

      final entry = {
        'token' : token,
        'said' : said,
      };

       if (response.statusCode == 200) {
        print('Token saved on server successfully: ${response.body}');
        rawLists.add(json.encode(entry));
        await prefs.setStringList(_key, rawLists);
      } else {
        print('Failed to save token: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while sending token: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTokenHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    return rawList.map((e) => json.decode(e) as Map<String, dynamic>).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

