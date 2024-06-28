import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class VideoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> uploadVideo(
      File videoFile,
      String title, {
        String? description,
        String? category,
        List<String>? tags,
        bool isPublic = false,
        bool isMatureContent = false,
      }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final fileName = '${DateTime.now().toIso8601String()}_${path.basename(videoFile.path)}';
      final filePath = '$userId/$fileName';

      // Upload video to storage
      final response = await _supabase.storage
          .from('user_videos')
          .upload(filePath, videoFile);

      // Get the public URL for the video
      final String videoUrl = _supabase.storage.from('user_videos').getPublicUrl(filePath);

      // Insert video metadata into the database
      await _supabase.from('videos').insert({
        'user_id': userId,
        'title': title,
        'description': description,
        'file_path': videoUrl, // Store the public URL
        'thumbnail_url': null, // You'll need to generate and upload a thumbnail
        'category': category,
        'tags': tags,
        'is_public': isPublic,
        'mature_content': isMatureContent,
        'status': 'available', // Since we're not processing the video
        'view_count': 0,
        'like_count': 0,
        'dislike_count': 0,
      });

      return videoUrl;
    } catch (e) {
      print('Error uploading video: $e');
      return null;
    }
  }

  Future<bool> addPreExistingVideo(
      String videoUrl,
      String title, {
        String? description,
        String? category,
        List<String>? tags,
        bool isPublic = true,
        bool isMatureContent = false,
      }) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final fileName = '${DateTime.now().toIso8601String()}_${path.basename(videoUrl)}';
      final filePath = '$userId/$fileName';

      // Download the video from the provided URL
      final response = await http.get(Uri.parse(videoUrl));
      final videoBytes = response.bodyBytes;

      // Upload video to storage
      await _supabase.storage
          .from('user_videos')
          .uploadBinary(filePath, videoBytes);

      // Get the public URL for the video
      final String newVideoUrl = _supabase.storage.from('user_videos').getPublicUrl(filePath);

      // Insert video metadata into the database
      await _supabase.from('videos').insert({
        'user_id': userId,
        'title': title,
        'description': description,
        'file_path': newVideoUrl,
        'thumbnail_url': null, // You'll need to generate and upload a thumbnail
        'category': category,
        'tags': tags,
        'is_public': isPublic,
        'mature_content': isMatureContent,
        'status': 'available',
        'view_count': 0,
        'like_count': 0,
        'dislike_count': 0,
      });

      return true;
    } catch (e) {
      print('Error adding pre-existing video: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPublicVideos() async {
    try {
      final response = await _supabase
          .from('videos')
          .select('*, profiles:user_id(username)')
          .eq('is_public', true)
          .order('created_at', ascending: false);

      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching public videos: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPrivateVideosForCurrentUser() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('videos')
          .select()
          .eq('user_id', userId)
          .eq('is_public', false)
          .order('created_at', ascending: false);

      return (response as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching private videos: $e');
      return [];
    }
  }

  Future<bool> likeVideo(String videoId) async {
    try {
      await _supabase.rpc('like_video', params: {'video_id': videoId});
      return true;
    } catch (e) {
      print('Error liking video: $e');
      return false;
    }
  }

  Future<bool> dislikeVideo(String videoId) async {
    try {
      await _supabase.rpc('dislike_video', params: {'video_id': videoId});
      return true;
    } catch (e) {
      print('Error disliking video: $e');
      return false;
    }
  }

  Future<bool> incrementViewCount(String videoId) async {
    try {
      await _supabase.rpc('increment_view_count', params: {'video_id': videoId});
      return true;
    } catch (e) {
      print('Error incrementing view count: $e');
      return false;
    }
  }
}