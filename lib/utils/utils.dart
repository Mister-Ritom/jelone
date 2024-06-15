import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:http/http.dart' as http;
class Utils {
static Future<List<int>?> getBytesFromUrl(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      // Handle unsuccessful response (e.g., print an error)
      return null;
    }
  } catch (error) {
    // Handle exceptions (e.g., print an error)
    return null;
  }
}

static Future<Metadata?> getMediaMetadata(String url) async {
  final bytes = await getBytesFromUrl(url);
  if (bytes == null) {
    return null;
  }
  return MetadataRetriever.fromBytes(bytes);
}

}