import 'package:equatable/equatable.dart';

class ChatItemModel extends Equatable {
  final String uid, message;
  final DateTime dateTime;

  const ChatItemModel({
    required this.uid,
    required this.message,
    required this.dateTime,
  });
  
  @override
  List<Object?> get props => [uid, message, dateTime];
}
