import 'package:dio/dio.dart';
import 'package:social_media_app/shared/keys.dart';

abstract class DioHelper {
  static late Dio _dio;
  static init() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://fcm.googleapis.com/v1/projects/zmlni-6c5f7/',
      receiveDataWhenStatusError: true,
    ));
  }

  static Future<void> post({
    required String token,
    required String title,
    required String bodyContent,
  }) async {
    await _dio.post(
      'messages:send',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${ApiKeys.cloudMessagingKey}',
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
