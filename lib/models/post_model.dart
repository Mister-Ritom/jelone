import 'package:jelone/models/comment_model.dart';
import 'package:jelone/models/media_model.dart';

class PostModel {
  List<MediaModel> mediaList;
  String uploaderId, postId;
  String title;
  String content;
  int likesCount;
  int viewsCount;
  List<CommentModel> comments;
  bool isPublic;

  // Constructor with likesCount and viewsCount default to 0 and comments to an empty list
  PostModel({
    required this.mediaList,
    required this.title,
    required this.content,
    required this.uploaderId,
    required this.postId,
    this.likesCount = 0,
    this.viewsCount = 0,
    this.isPublic = true,
    this.comments = const <CommentModel>[],
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      mediaList: List<MediaModel>.from(
        json['mediaList'].map((x) => MediaModel.fromJson(x)),
      ),
      title: json['title'],
      content: json['content'],
      likesCount: json['likesCount'],
      viewsCount: json['viewsCount'],
      uploaderId: json['uploaderId'],
      postId: json['postId'],
      isPublic: json['isPublic'],
      comments: List<CommentModel>.from(
        json['comments'].map((x) => CommentModel.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaList': mediaList.map((x) => x.toJson()).toList(),
      'title': title,
      'content': content,
      'uploaderId': uploaderId,
      'postId': postId,
      'likesCount': likesCount,
      'viewsCount': viewsCount,
      'isPublic': isPublic,
      'comments': comments.map((x) => x.toJson()).toList(),
    };
  }
  
}