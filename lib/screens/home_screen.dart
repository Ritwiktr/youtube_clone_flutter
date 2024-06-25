import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'video_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> videos = [
    {
      'title': 'Flutter Tutorial for Beginners',
      'channel': 'Flutter Dev',
      'thumbnail': 'https://img.youtube.com/vi/1ukSR1GRtMU/0.jpg',
      'videoUrl': 'https://www.example.com/fluttertutorial.mp4',
    },
    {
      'title': 'Building a YouTube Clone',
      'channel': 'Mobile Dev',
      'thumbnail': 'https://img.youtube.com/vi/h-igXZCCrrc/0.jpg',
      'videoUrl': 'https://www.example.com/youtubeclone.mp4',
    },
    // Add more video entries here
  ];

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
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoScreen(videoUrl: videos[index]['videoUrl']!),
                ),
              );
            },
            child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: videos[index]['thumbnail']!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage('https://placekitten.com/100/100'),
                  ),
                  title: Text(
                    videos[index]['title']!,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    videos[index]['channel']!,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  trailing: Icon(Icons.more_vert, color: Colors.white),
                ),
                Divider(color: Colors.grey[800], height: 1),
              ],
            ),
          );
        },
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
      ),
    );
  }
}