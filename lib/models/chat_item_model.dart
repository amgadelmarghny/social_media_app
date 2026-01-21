import 'package:equatable/equatable.dart';

class ChatItemModel extends Equatable {
  final String uid;
  final DateTime dateTime;
  final String? textMessage, voiceRecord;
  final List? images;

  const ChatItemModel({
    required this.uid,
    this.textMessage,
    required this.dateTime,
    this.voiceRecord,
    this.images,
  });

  @override
  List<Object?> get props => [uid, textMessage, voiceRecord, images, dateTime];
}
