import 'dart:convert';

import 'package:mobile/data/models/chat.dart';
import 'package:mobile/data/services/auth/auth_service.dart';
import 'package:mobile/data/utils.dart';

class ChatService {
  final AuthService _authService;

  ChatService(this._authService);

  Future<Chat> createChat() async {
    if (_authService.accessToken == null) {
      throw Exception('Not authenticated - cannot create chat');
    }

    final response = await _authService.post(ApiEndpoints.chats, {});
    if (response.statusCode == 201) {
      return Chat.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create chat');
    }
  }

  Future<Map<String, dynamic>> fetchChats({int page = 1}) async {
    if (_authService.accessToken == null) {
      return {
        'success': false,
        'error': 'Not authenticated - cannot fetch chats',
      };
    }

    try {
      final response = await _authService.get(
        '${ApiEndpoints.chats}?page=$page',
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;

        final dataList = List<Map<String, dynamic>>.from(body['chats'] ?? []);
        final chats = dataList.map((json) => Chat.fromJson(json)).toList();

        final int totalPages = body['total_pages'] ?? 1;
        final int? nextPage = page < totalPages ? page + 1 : null;
        final int? previousPage = page > 1 ? page - 1 : null;

        return {
          'success': true,
          'chats': chats,
          'nextPage': nextPage,
          'previousPage': previousPage,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch chats: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to fetch chats: $e'};
    }
  }
}
