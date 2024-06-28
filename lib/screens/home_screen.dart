import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'video_screen.dart';
import 'video_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final VideoService _videoService = VideoService();
  List<Map<String, dynamic>> _publicVideos = [];
  List<Map<String, dynamic>> _privateVideos = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVideos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final publicVideos = await _videoService.getPublicVideos();
      final privateVideos = await _videoService.getPrivateVideosForCurrentUser();
      setState(() {
        _publicVideos = publicVideos;
        _privateVideos = privateVideos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading videos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      File videoFile = File(result.files.single.path!);
      Map<String, dynamic> videoDetails = await _showVideoDetailsDialog();
      if (videoDetails['title'].isNotEmpty) {
        setState(() {
          _isLoading = true;
        });
        await _videoService.uploadVideo(
          videoFile,
          videoDetails['title'],
          description: videoDetails['description'],
          category: videoDetails['category'],
          tags: videoDetails['tags'],
          isPublic: videoDetails['isPublic'],
          isMatureContent: videoDetails['isMatureContent'],
        );
        await _loadVideos();
      }
    }
  }

  Future<Map<String, dynamic>> _showVideoDetailsDialog() async {
    String title = '';
    String description = '';
    String category = '';
    List<String> tags = [];
    bool isPublic = false;
    bool isMatureContent = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Video Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => title = value,
                decoration: InputDecoration(
                  hintText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                onChanged: (value) => description = value,
                decoration: InputDecoration(
                  hintText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 8),
              TextField(
                onChanged: (value) => category = value,
                decoration: InputDecoration(
                  hintText: "Category",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                onChanged: (value) => tags = value.split(','),
                decoration: InputDecoration(
                  hintText: "Tags (comma-separated)",
                  border: OutlineInputBorder(),
                ),
              ),
              SwitchListTile(
                title: Text('Public'),
                value: isPublic,
                onChanged: (value) => setState(() => isPublic = value),
              ),
              SwitchListTile(
                title: Text('Mature Content'),
                value: isMatureContent,
                onChanged: (value) => setState(() => isMatureContent = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Upload'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );

    return {
      'title': title,
      'description': description,
      'category': category,
      'tags': tags,
      'isPublic': isPublic,
      'isMatureContent': isMatureContent,
    };
  }

  void _handleVideoAction(String action, String videoId) async {
    switch (action) {
      case 'like':
        await _videoService.likeVideo(videoId);
        break;
      case 'dislike':
        await _videoService.dislikeVideo(videoId);
        break;
    }
    await _loadVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: Colors.black,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('YouTube Clone', style: TextStyle(color: Colors.white)),

              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.cast, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: CircleAvatar(
                    backgroundImage: NetworkImage('https://placekitten.com/100/100'),
                    radius: 12,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Public'),
                  Tab(text: 'Private'),
                ],
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.red,
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _isLoading
                ? _buildShimmerLoading()
                : _buildVideoList(_publicVideos),
            _isLoading
                ? _buildShimmerLoading()
                : _buildVideoList(_privateVideos),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.explore, color: Colors.white),
              onPressed: () {},
            ),
            FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: _uploadVideo,
              mini: true,
              backgroundColor: Colors.red,
            ),
            IconButton(
              icon: Icon(Icons.subscriptions, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.video_library, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Container(height: 250),
          );
        },
      ),
    );
  }

  Widget _buildVideoList(List<Map<String, dynamic>> videos) {
    return RefreshIndicator(
      onRefresh: _loadVideos,
      child: videos.isEmpty
          ? Center(child: Text('No videos available', style: TextStyle(color: Colors.white)))
          : AnimationLimiter(
        child: ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildVideoItem(video),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoItem(Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoScreen(
              videoUrl: video['file_path'],
              videoTitle: video['title'],
            ),
          ),
        );
      },
      child: Card(
        color: Colors.grey[900],
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: video['thumbnail_url'] ?? 'https://picsum.photos/640/360',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[800]!,
                      highlightColor: Colors.grey[700]!,
                      child: Container(
                        height: 200,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${video['duration']}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['title'],
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Views: ${video['view_count']} • Likes: ${video['like_count']}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Category: ${video['category']} • ${video['is_public'] ? 'Public' : 'Private'}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage('https://placekitten.com/100/100'),
                        radius: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        video['user_name'] ?? 'Unknown User',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String result) {
                      _handleVideoAction(result, video['id']);
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'like',
                        child: Row(
                          children: [
                            Icon(Icons.thumb_up, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Like'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'dislike',
                        child: Row(
                          children: [
                            Icon(Icons.thumb_down, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Dislike'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}