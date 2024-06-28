import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

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
      final filePath = isPublic ? 'public/$fileName' : 'private/$userId/$fileName';

      // Upload video to storage
      final response = await _supabase.storage
          .from('videos')
          .upload(filePath, videoFile);



      // Get the public URL for public videos, or a signed URL for private videos
      final String videoUrl = isPublic
          ? _supabase.storage.from('videos').getPublicUrl(filePath)
          : await _supabase.storage.from('videos').createSignedUrl(filePath, 3600); // 1 hour expiration

      // Insert video metadata into the database
      await _supabase.from('videos').insert({
        'user_id': userId,
        'title': title,
        'description': description,
        'file_path': filePath,
        'thumbnail_url': null, // You'll need to generate and upload a thumbnail
        'category': category,
        'tags': tags,
        'is_public': isPublic,
        'mature_content': isMatureContent,
        'status': 'processing', // Assuming you'll process the video after upload
      });

      return videoUrl;
    } catch (e) {
      print('Error uploading video: $e');
      return null;
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

  Future<String> getPrivateVideoUrl(String filePath) async {
    return await _supabase.storage.from('videos').createSignedUrl(filePath, 3600); // 1 hour expiration
  }
}