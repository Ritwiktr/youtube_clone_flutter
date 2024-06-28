import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoScreen extends StatefulWidget {
  final String videoUrl;
  final String videoTitle;

  VideoScreen({required this.videoUrl, required this.videoTitle});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _liked = false;
  bool _disliked = false;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    await _videoPlayerController.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      placeholder: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.redAccent,
        handleColor: Colors.redAccent,
        backgroundColor: Colors.grey[800]!,
        bufferedColor: Colors.grey[600]!,
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Video Player', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
                ? AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            )
                : AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.videoTitle,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildIconButton(
                        icon: _liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                        color: _liked ? Colors.redAccent : Colors.white,
                        onPressed: () => setState(() => _liked = !_liked),
                      ),
                      SizedBox(width: 16),
                      _buildIconButton(
                        icon: _disliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                        color: _disliked ? Colors.blue : Colors.white,
                        onPressed: () => setState(() => _disliked = !_disliked),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildIconButton(
                        icon: Icons.share,
                        onPressed: () {
                          // Implement share functionality
                        },
                      ),
                      SizedBox(width: 16),
                      _buildIconButton(
                        icon: Icons.download,
                        onPressed: () {
                          // Implement download functionality
                        },
                      ),
                      SizedBox(width: 16),
                      _buildIconButton(
                        icon: Icons.playlist_add,
                        onPressed: () {
                          // Implement add to playlist functionality
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[800]),
            _buildSectionTitle('Description'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'This is a sample video description. You can add more details about the video here.',
                style: TextStyle(fontSize: 16, color: Colors.grey[300]),
              ),
            ),
            SizedBox(height: 24),
            _buildSectionTitle('Comments'),
            _buildCommentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, Color? color, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon, size: 28),
      color: color ?? Colors.white,
      onPressed: onPressed,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildCommentSection() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 3, // Replace with actual comment count
      itemBuilder: (context, index) {
        return _buildCommentItem();
      },
    );
  }

  Widget _buildCommentItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[800],
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Name',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  'This is a sample comment. It can be multiple lines long and contain various thoughts about the video.',
                  style: TextStyle(color: Colors.grey[300]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}