import 'package:equatable/equatable.dart';

class CreatePostImplModel extends Equatable {
  final String? content;
  final String? postImage;
  final int commentsNum;
  final DateTime dateTime;

  const CreatePostImplModel(
      {required this.content,
      required this.postImage,
      required this.dateTime,
      required this.commentsNum});

  @override
  List<Object?> get props => [content, postImage, dateTime, commentsNum];
}
