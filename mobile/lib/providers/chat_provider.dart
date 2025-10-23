import 'package:flutter/material.dart';
import 'package:mobile/data/models/chat.dart';
import 'package:mobile/data/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _service;

  ChatProvider(this._service);

  List<Chat> _chats = [];
  Chat? _activeChat;
  bool _isLoading = false;
  bool _hasMoreChats = true;
  String? _error;
  int _currentPage = 1;

  List<Chat> get chats => List.unmodifiable(_chats);
  Chat? get activeChat => _activeChat;
  bool get isLoading => _isLoading;
  bool get hasMoreChats => _hasMoreChats;
  String? get error => _error;

  Future<void> loadChats({bool refresh = false}) async {
    if (_isLoading || (!_hasMoreChats && !refresh)) return;

    if (refresh) {
      _currentPage = 1;
      _hasMoreChats = true;
      _chats.clear();
      _activeChat = null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.fetchChats(page: _currentPage);

      if (result['success'] == true) {
        final newChats = result['chats'] as List<Chat>;

        _chats.addAll(newChats);
        _hasMoreChats = result['nextPage'] != null;

        if (_hasMoreChats) {
          _currentPage++; 
        }

        if (_activeChat == null && _chats.isNotEmpty) {
          _activeChat = _chats.first;
        }
      } else {
        _error = result['error'] ?? 'An unknown error occurred.';
      }
    } catch (e) {
      _error = 'Failed to load chats: $e';
    } finally {
      _isLoading = false;
      Future.microtask(() {
        notifyListeners();
      });
    }
  }



  Future<Chat?> createNewChat() async {
    _isLoading = true;
    notifyListeners();

    try {
      final newChat = await _service.createChat();

      _chats.insert(0, newChat);
      _activeChat = newChat;
      notifyListeners();
      return newChat;

    } catch (e) {
      print("Failed to create chat: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setActiveChat(Chat chat) {
    if (_chats.any((c) => c.id == chat.id)) {
      _activeChat = chat;
      notifyListeners();
    } else {
      print("Chat not found in list: ${chat.id}");
    }
  }

  Chat? getChatById(String? chatId) {
    if (chatId == null) return null;

    try {
      return _chats.firstWhere((chat) => chat.id == chatId);
    } catch (_) {
      return null;
    }
  }
}
