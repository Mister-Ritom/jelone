import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:jelone/models/media_model.dart';
import 'package:jelone/utils/utils.dart';
import 'package:just_audio/just_audio.dart';
import 'package:native_video_player/native_video_player.dart';
import 'package:provider/provider.dart';

class MediaDialogs {
  static void listMedia(
      List<MediaModel> assets, bool isInternet, BuildContext statecontext) {
    if (assets.isEmpty) {
      return;
    }
    final player = AudioPlayer();
    showModalBottomSheet(
      context: statecontext,
      builder: (BuildContext _) {
        return ListView.builder(
          itemCount: assets.length,
          itemBuilder: (BuildContext context, int index) {
            final asset = assets[index];
            if (asset.mediaType == MediaType.image) {
              return buildImageWidget(isInternet, asset, context);
            } else if (asset.mediaType == MediaType.video) {
              NativeVideoPlayerController? controller;
              return buildWidgets(buildVideoWidget(controller, asset, isInternet),context);
            } else {
              return buildWidgets(buildAudioWidget(isInternet, asset, player), context);
            }
          },
        );
      },
    );
  }

  static Widget buildImageWidget(bool isInternet, MediaModel asset, BuildContext context) {
    return buildWidgets(isInternet
                ? Image.network(asset.mediaUrl)
                : Image.file(
                    File(asset.mediaUrl),
                  ), context);
  }

  static Widget buildWidgets(Widget child, context) {
    return SizedBox(
      //width and height both are same as the device width
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          child,
        ],
      ),
    );
  }

  static Widget buildAudioWidget(
      bool isInternet, MediaModel asset, AudioPlayer player) {
    return Stack(
      children: [
        FutureBuilder(
          future: isInternet
              ? Utils.getMediaMetadata(asset.mediaUrl)
              : MetadataRetriever.fromFile(File(asset.mediaUrl)),
          builder: (BuildContext context, AsyncSnapshot<Metadata?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null) {
              return Icon(
                Icons.music_note_outlined,
                size: 100,
                color: Colors.grey.shade300,
              );
            }
            final metadata = snapshot.data;
            if (metadata!.albumArt == null) {
              return Icon(
                Icons.music_note_outlined,
                size: 100,
                color: Colors.grey.shade300,
              );
            }
            return Image.memory(
              metadata.albumArt!,
              fit: BoxFit.cover,
            );
          },
        ),
        Center(
          child: IconButton(
            //icon is a future to check if controller is playing if yes show pause icon else show play icon
            icon: StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder:
                  (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return const Icon(Icons.play_arrow);
                }
                if (snapshot.data!.playing) {
                  return const Icon(Icons.pause);
                } else {
                  return const Icon(Icons.play_arrow);
                }
              },
            ),
            onPressed: () {
              player.setAudioSource(AudioSource.uri(Uri.parse(asset.mediaUrl)));
              player.play();
            },
          ),
        ),
      ],
    );
  }

  static Widget buildVideoWidget(NativeVideoPlayerController? controller,
      MediaModel asset, bool isInternet) {
    return Stack(
      children: [
        NativeVideoPlayerView(
          onViewReady: (e) {
            controller = e;
            controller!.loadVideoSource(
              VideoSource(
                  path: asset.mediaUrl,
                  type: isInternet
                      ? VideoSourceType.network
                      : VideoSourceType.file),
            );
          },
        ),
        Center(
          child: IconButton(
            icon: ChangeNotifierProvider(
              create: (context) => controller!.onPlaybackStatusChanged,
              child: Consumer<PlaybackStatus>(
                builder: (context, playbackStatus, child) {
                  if (playbackStatus == PlaybackStatus.playing) {
                    return const Icon(Icons.pause);
                  } else {
                    return const Icon(Icons.play_arrow);
                  }
                },
              ),
            ),
            onPressed: () async {
              if (await controller!.isPlaying()) {
                controller!.pause();
              } else {
                controller!.play();
              }
            },
          ),
        ),
      ],
    );
  }
}
