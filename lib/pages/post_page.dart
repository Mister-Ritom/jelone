import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jelone/models/media_model.dart';
import 'package:jelone/models/post_model.dart';
import 'package:jelone/utils/dialogs.dart';
import 'package:jelone/utils/media_dialogs.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<AssetEntity> _assets = [];
  final auth = FirebaseAuth.instance;
  final audioPlayer = AudioPlayer();

  bool _isPublic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: const Text('Create a new post'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            onPressed: () {},
            child: RichText(
              text: TextSpan(
                children: [
                  const WidgetSpan(
                    child: Icon(
                      FontAwesomeIcons.book,
                      size: 16,
                    ),
                  ),
                  const WidgetSpan(
                      child: SizedBox(
                    width: 4,
                  )),
                  TextSpan(
                    text: 'Draft',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: _createDialog,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.inverseSurface,
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Post',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                  const WidgetSpan(
                      child: SizedBox(
                    width: 4,
                  )),
                  const WidgetSpan(
                    child: Icon(
                      FontAwesomeIcons.paperPlane,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                //add image button
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                const SizedBox(
                  width: 12,
                ),
                //add video button
                IconButton(
                  icon: const Icon(Icons.video_collection),
                  onPressed: _pickVideo,
                ),
                //add document button
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    //Coming soon tip
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Coming soon'),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  width: 12,
                ),
                //Add audio button
                IconButton(
                  icon: const Icon(FontAwesomeIcons.fileAudio),
                  onPressed: _pickAudio,
                ),
                const SizedBox(
                  width: 12,
                ),
                const Spacer(),
                //Public switch
                const Text('Public:'),
                const SizedBox(
                  width: 8,
                ),
                SizedBox(
                  width: 42,
                  child: FittedBox(
                    child: Switch(
                      value: _isPublic,
                      onChanged: (value) {
                        setState(() {
                          _isPublic = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              //Post title
              TextField(
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
                maxLines: 4,
                minLines: 3,
                controller: _titleController,
                decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Title',
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              //Post content
              TextField(
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
                minLines: 10,
                maxLines: 15,
                controller: _contentController,
                decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintText: 'Content (Markdown supported)',
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Visibility(
                visible: _assets.isNotEmpty,
                child: ElevatedButton(
                  onPressed: () async {
                    final List<MediaModel> mediaList = [];
                    for (var asset in _assets) {
                      final media = MediaModel(
                        mediaUrl: (await asset.file)!.path,
                        mediaType: asset.type == AssetType.image
                            ? MediaType.image
                            : asset.type == AssetType.video
                                ? MediaType.video
                                : MediaType.document,
                      );
                      mediaList.add(media);
                    }
                    if (mounted && context.mounted) {
                      MediaDialogs.listMedia(mediaList, false, context);
                    }
                  },
                  child: const Text('Show media list'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  void _createDialog() async {
    try {
      Dialogs.showLoadingDialog(context, _keyLoader); //invoking login
      await _createPost();
      if (_keyLoader.currentContext != null && mounted && context.mounted) {
        Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
            .pop(); //close the dialoge
        Navigator.pop(context);
      }
    } catch (e) {
      log("Something went wrong while trying to open dialog", error: e);
    }
  }

  Future<void> _createPost() async {
    final postId = const Uuid().v4();
    final userId = auth.currentUser!.uid;
    final title = _titleController.text;
    final content = _contentController.text;
    final mediaList = await _uploadMedia(postId);

    final post = PostModel(
      mediaList: mediaList,
      title: title,
      content: content,
      uploaderId: userId,
      postId: postId,
      isPublic: _isPublic,
    );

    // Save the post to Firestore
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    await postRef.set(post.toJson());
  }

  Future<List<MediaModel>> _uploadMedia(String postId) async {
    final List<MediaModel> mediaList = [];
    for (var asset in _assets) {
      // Get the file associated with the asset
      final file = await asset.file;
      if (file == null) {
        log('Post ${asset.title} file is null');
        continue;
      }
      // Create a reference to the file in Firebase Storage
      final storageReference = FirebaseStorage.instance.ref().child(
          'posts/$postId/${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}');

      // Upload the file to Firebase Storage
      final uploadTask = await storageReference.putFile(file);

      // Get the download URL of the uploaded file
      final downloadURL = await uploadTask.ref.getDownloadURL();

      // Create a MediaModel object
      final media = MediaModel(
        mediaType: asset.type == AssetType.image
            ? MediaType.image
            : asset.type == AssetType.video
                ? MediaType.video
                : MediaType.document,
        mediaUrl: downloadURL,
      );
      mediaList.add(media);
    }
    return mediaList;
  }

  void _pickAudio() async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
          maxAssets: 3,
          requestType: RequestType.audio,
          pickerTheme: Theme.of(context)),
    );
    if (result != null) {
      addFromResult(result);
    }
  }

  void _pickImage() async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 9,
        requestType: RequestType.image,
        pickerTheme: Theme.of(context),
      ),
    );
    if (result != null) {
      addFromResult(result);
    }
  }

  void _pickVideo() async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 9,
        requestType: RequestType.video,
        pickerTheme: Theme.of(context),
      ),
    );
    if (result != null) {
      addFromResult(result);
    }
  }

  void addFromResult(List<AssetEntity> result) {
    setState(
      () {
        for (var asset in result) {
          if (_assets.length < 9) {
            _assets.add(asset);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You can only upto 9 files')));
            break;
          }
        }
      },
    );
  }
}
