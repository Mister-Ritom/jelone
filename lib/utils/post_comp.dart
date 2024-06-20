// Suggested code may be subject to a license. Learn more: ~LicenseLog:2189599623.
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:jelone/models/media_model.dart';
import 'package:jelone/models/post_model.dart';
import 'package:jelone/models/user_model.dart';
import 'package:jelone/utils/media_dialogs.dart';
import 'package:jelone/utils/utils.dart';
import 'package:native_video_player/native_video_player.dart';

class PostComponent extends StatefulWidget {
  final PostModel post;
  const PostComponent(this.post, {super.key});

  @override
  State<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> {
  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          buildUserWidget(post),
          SizedBox(
            height: (MediaQuery.of(context).size.width - 16) * 4 / 3,
            child: PageView(
              children: mapToWidget(post, context).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Iterable<Widget> mapToWidget(PostModel post, BuildContext context) {
    return post.mediaList.map(
      (media) => media.mediaType == MediaType.image
          ? MediaDialogs.buildImageWidget(true, media, context)
          : media.mediaType == MediaType.video
              ? buildVideo(media.mediaUrl)
              : const SizedBox(
                  width: 50,
                  height: 50,
                ),
    );
  }

  Widget buildVideo(String url) {
    return NativeVideoPlayerView(
      onViewReady: (_controller) {
        _controller.loadVideoSource(
          VideoSource(
            path: url,
            type: VideoSourceType.network,
          ),
        );
      },
    );
  }

  FutureBuilder<UserModel?> buildUserWidget(PostModel post) {
    return FutureBuilder(
      future: Utils.getUser(post.uploaderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (snapshot.hasError) {
          return const Text('Error');
        }
        final user = snapshot.data;
        if (user == null) {
          return const Text('User not found');
        }
        return ListTile(
          leading: ProfilePicture(
            name: user.name,
            radius: 20,
            fontsize: 16,
            img: user.photoUrl,
          ),
          title: Text(user.name),
          subtitle: Text(
            user.username,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [],
          ),
        );
      },
    );
  }
}
