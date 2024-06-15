//A media model with a media type of image, video or document and a media url

class MediaModel {
  final String mediaUrl;
  final MediaType mediaType;

  MediaModel({required this.mediaUrl, required this.mediaType});

  factory MediaModel.fromJson(Map<String, dynamic> data) {
    return MediaModel(
      mediaUrl: data['mediaUrl'] as String,
      mediaType: data['mediaType'] == 'image'
          ? MediaType.image
          : data['mediaType'] == 'video'
              ? MediaType.video
              : MediaType.document,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaUrl': mediaUrl,
      'mediaType': mediaType == MediaType.image
          ? 'image'
          : mediaType == MediaType.video
              ? 'video'
              : 'document',
    };
  }
}

enum MediaType { image, video, document }