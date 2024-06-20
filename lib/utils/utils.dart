import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:http/http.dart' as http;
import 'package:jelone/models/user_model.dart';
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
  return MetadataRetriever.fromBytes(Uint8List.fromList(bytes));
}

  static Future<UserModel?> getUser(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection('users').doc(userId);
    final document = await userRef.get();
    final data = document.data();
    if (data == null) {
      return null;
    }
    return UserModel.fromJson(data);
  }

}