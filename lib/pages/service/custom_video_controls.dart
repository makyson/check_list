




import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:untitled/flutter_flow/flutter_flow_theme.dart';
import 'blob_url_creator.dart';
import 'model.dart';

class YoutubeStyleVideoControls extends StatefulWidget {
  final PickedFilesType file; // Receive a single file

  YoutubeStyleVideoControls({required this.file});

  @override
  _YoutubeStyleVideoControlsState createState() => _YoutubeStyleVideoControlsState();
}

class _YoutubeStyleVideoControlsState extends State<YoutubeStyleVideoControls> {
  late VideoPlayerController _controller; // Renamed for clarity

  bool showControls = true;
  bool isFullscreen = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    if (widget.file.file == 'video') {
      final url = BlobUrlCreator.createBlobUrl(widget.file.bytes, 'video/${widget.file.type}');

      _controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          setState(() {}); // Update UI once initialized
          _controller.play(); // Auto-play after loading
        });

      _controller.addListener(() {
        setState(() {}); // Update UI when video state changes
      });
    } else {
      // Handle the case where the file isn't a video (e.g., error message)
      // You could display a dialog or change the UI accordingly.
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }


  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }



  Widget _buildPlayPauseButton() {
    return IconButton(
      icon: Icon(
        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        color: Colors.white,
        size: 50.0,
      ),
      onPressed: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
    );
  }



  Widget _buildVolumeButton() {
    return Row(children: [ IconButton(
      icon: Icon(
        _controller.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
        color: Colors.white,
        size: 30.0,
      ),
      onPressed: () {
        setState(() {
          if (_controller.value.volume > 0) {
            _controller.setVolume(0);
          } else {
            _controller.setVolume(1);
          }
        });
      },
    ),
    SliderTheme( // Apply a theme for the volume slider
    data: SliderTheme.of(context).copyWith(
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
    activeTrackColor: Colors.red, // Customize slider appearance
    inactiveTrackColor: Colors.grey,
    thumbColor: Colors.white,
    ),
    child: Slider(
    value: _controller.value.volume,
    min: 0.0,
    max: 1.0,
    onChanged: (value) {
    setState(() {
    _controller.setVolume(value);
    });
    },
    ),
    )
    ]);
  }

  Widget _buildProgressBar() {
    return Slider(
      value: _controller.value.position.inMilliseconds.toDouble(),
      min: 0.0,
      max: _controller.value.duration.inMilliseconds.toDouble(),
      onChanged: (value) {
        _controller.seekTo(Duration(milliseconds: value.toInt()));
      },
    );
  }

  Widget _buildTimeIndicator() {
    return  Text(
      _formatDuration(_controller.value.position) + ' / ' + _formatDuration(_controller.value.duration),
      style: TextStyle(color: FlutterFlowTheme.of(context).primaryText),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Stack(
      alignment: Alignment.bottomCenter,
      children: [

        Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
              : const CircularProgressIndicator(),
        ),
        Center(child: _buildPlayPauseButton(),),


        if (showControls) ...[
          AnimatedOpacity(
            opacity: showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(

              color: Colors.black38,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimeIndicator(),
                      _buildVolumeButton(),
                    ],
                  ),
                  _buildProgressBar(),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  } // ... rest of your code ( _build functions)




  }


