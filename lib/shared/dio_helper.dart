import 'package:dio/dio.dart';

abstract class DioHelper {
  static late Dio _dio;
  static init() {
    _dio = Dio(BaseOptions(
      // TODO: change api to the new one
      baseUrl: 'https://fcm.googleapis.com/fcm/',
      receiveDataWhenStatusError: true,
    ));
  }

  static Future<void> post({
    required String token,
    required String title,
    required String bodyContent,
  }) async {
    await _dio.post(
      'send',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'key=$YOUR_SERVER_KEY', // ✨ من Firebase Console > Project settings > Cloud Messaging > Server key
        },
      ),
      data: {
        'to': token,
        'notification': {
          'title': title,
          'body': bodyContent,
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        }
      },
    );
  }
}
