import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
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
    final publicVideos = await _videoService.getPublicVideos();
    final privateVideos = await _videoService.getPrivateVideosForCurrentUser();
    setState(() {
      _publicVideos = publicVideos;
      _privateVideos = privateVideos;
      _isLoading = false;
    });
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
                decoration: InputDecoration(hintText: "Title"),
              ),
              TextField(
                onChanged: (value) => description = value,
                decoration: InputDecoration(hintText: "Description"),
              ),
              TextField(
                onChanged: (value) => category = value,
                decoration: InputDecoration(hintText: "Category"),
              ),
              TextField(
                onChanged: (value) => tags = value.split(','),
                decoration: InputDecoration(hintText: "Tags (comma-separated)"),
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
          TextButton(
            child: Text('OK'),
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
    // Add more cases as needed
    }
    await _loadVideos(); // Refresh the video list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Image.asset(
          'assets/youtube_logo.png',
          height: 40,
        ),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Public'),
            Tab(text: 'Private'),
          ],
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
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildVideoList(_publicVideos),
          _buildVideoList(_privateVideos),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[700],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.subscriptions), label: 'Subscriptions'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: 'Library'),
        ],
        onTap: (index) {
          if (index == 2) {
            _uploadVideo();
          }
        },
      ),
    );
  }

  Widget _buildVideoList(List<Map<String, dynamic>> videos) {
    return RefreshIndicator(
      onRefresh: _loadVideos,
      child: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return _buildVideoItem(video);
        },
      ),
    );
  }

  Widget _buildVideoItem(Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () async {
        String videoUrl = video['is_public']
            ? video['file_path']
            : await _videoService.getPrivateVideoUrl(video['file_path']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoScreen(videoUrl: videoUrl),
          ),
        );
      },
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: video['thumbnail_url'] ?? 'https://placekitten.com/640/360',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage('https://placekitten.com/100/100'),
            ),
            title: Text(
              video['title'],
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Views: ${video['view_count']} • Likes: ${video['like_count']}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                Text(
                  'Category: ${video['category']} • ${video['is_public'] ? 'Public' : 'Private'}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (String result) {
                _handleVideoAction(result, video['id']);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'like',
                  child: Text('Like'),
                ),
                const PopupMenuItem<String>(
                  value: 'dislike',
                  child: Text('Dislike'),
                ),
                // Add more options as needed
              ],
            ),
          ),
          Divider(color: Colors.grey[800], height: 1),
        ],
      ),
    );
  }
}