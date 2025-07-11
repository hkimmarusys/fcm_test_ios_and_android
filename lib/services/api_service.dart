import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fcm_ios_and_android/controller.dart';

class ApiService {
  final MainController controller = Get.find<MainController>();
  final Uri baseUrl = Uri.parse('https://demo.marusys.com/brcm/');

  static const _key = 'token_history';



  Future<String?> receiveNotification({required String said}) async {
    try {
      final response = await http.post(
        baseUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'mode': 'list',
          'said': said,
        }),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'failed to receive notification: ${response.body}';
      }
    } catch (e) {
      print('Error: $e');
      return 'Error: $e';
    }
  }


  Future<bool> sendToken({ required String said }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = controller.fcmToken.value;
    final type = controller.type.value;
    final rawLists = prefs.getStringList(_key) ?? [];

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
        return true;
      } else {
        print('Failed to save token: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error occurred while sending token: $e');
      return false;
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

