import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  String _username = 'Loading...';
  String _email = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        setState(() {
          _email = user.email ?? 'No email';
          _username = user.userMetadata?['username'] ?? 'No username';
        });

        if (_username == 'No username') {
          final response = await _supabase
              .from('profiles')
              .select('username')
              .eq('user_id', user.id)
              .single();

          if (response != null && response['username'] != null) {
            setState(() {
              _username = response['username'];
            });

            await _supabase.auth.updateUser(
              UserAttributes(
                data: {'username': _username},
              ),
            );
          }
        }
      } else {
        setState(() {
          _username = 'Not signed in';
          _email = 'Not signed in';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _username = 'Error loading';
        _email = 'Error loading';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _supabase.auth.signOut();
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.red))
          : RefreshIndicator(
        onRefresh: _loadUserData,
        color: Colors.red,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(_username,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.red, Colors.black],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                              'https://placekitten.com/200/200'),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      _email,
                      style: TextStyle(color: Colors.grey[400]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    _buildSection('Account', [
                      _buildListTile(Icons.person, 'Edit Profile'),
                      _buildListTile(Icons.security, 'Security'),
                      _buildListTile(Icons.notifications, 'Notifications'),
                    ]),
                    SizedBox(height: 20),
                    _buildSection('Content', [
                      _buildListTile(Icons.video_library, 'My Videos'),
                      _buildListTile(Icons.favorite, 'Liked Videos'),
                      _buildListTile(Icons.history, 'Watch History'),
                    ]),
                    SizedBox(height: 20),
                    _buildSection('Support', [
                      _buildListTile(Icons.help, 'Help & Feedback'),
                      _buildListTile(Icons.info, 'About'),
                    ]),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.logout, color: Colors.white),
                        label: Text('Logout',
                            style: TextStyle(color: Colors.white)),
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title, style: TextStyle(color: Colors.white)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Handle tap
        },
      ),
    );
  }
}