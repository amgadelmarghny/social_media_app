import 'package:dio/dio.dart';
import 'package:social_media_app/shared/keys.dart';

abstract class DioHelper {
  static late Dio _dio;
  static init() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://fcm.googleapis.com/v1/projects/zmlni-6c5f7/messages:',
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
          'Authorization': 'Bearer ${ApiKeys.cloudMessagingKey}',
        },
      ),
      data: {
        'to': token,
        'notification': {
          'title': title,
          'body': bodyContent,
          'sound': 'default',
        },
        'android': {
          'priority': 'HIGH',
          'notification': {
            'notification_priority': 'PRIORITY_MAX',
            'sound': 'default',
            'default_sound': true,
            'default_vibrate_timings': true,
            'default_light_settings': true,
          },
        },
        'data': {
          'type': 'order',
          'id': '87',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        }
      },
    );
  }
}
