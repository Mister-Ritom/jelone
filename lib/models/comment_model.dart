class CommentModel {
  String writerId;
  String content;

  CommentModel({required this.writerId, required this.content});

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      writerId: json['writerId'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'writerId': writerId,
      'content': content,
    };
  }

}