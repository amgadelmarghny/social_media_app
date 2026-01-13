import 'package:equatable/equatable.dart';

class ChatItemModel extends Equatable {
  final String uid;
  final DateTime dateTime;
  final String? message, voiceRecord, image;

  const ChatItemModel({
    required this.uid,
    this.message,
    required this.dateTime,
    this.voiceRecord,
    this.image,
  });

  @override
  List<Object?> get props => [uid, message, voiceRecord, image, dateTime];
}
