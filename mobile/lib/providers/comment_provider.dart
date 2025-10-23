import 'package:flutter/foundation.dart';
import 'package:mobile/data/models/comment.dart';
import 'package:mobile/data/services/blog_service.dart';
import 'package:mobile/data/services/post_service.dart';

enum EntityType { post, blog }

class CommentProvider with ChangeNotifier {
  final PostService _postService;
  final BlogService _blogService;

  final Map<String, List<Comment>> _comments = {};
  String? _error;
  bool _isLoading = false;

  CommentProvider(this._postService, this._blogService);

  String? get error => _error;
  bool get isLoading => _isLoading;

  String _getCommentkey(EntityType type, String entityId) =>
      '${type.name}-$entityId';

  List<Comment> getEntityComments(EntityType type, String entityId) =>
      _comments[_getCommentkey(type, entityId)] ?? [];

  Future<void> loadPostComments(
    String postId, {
    int page = 1,
    bool refresh = false,
  }) =>
      loadComments(
        EntityType.post,
        postId,
        page: page,
        refresh: refresh,
      );

      List<Comment> getPostComments(String postId) =>
      getEntityComments(EntityType.post, postId);

  List<Comment> getBlogComments(String blogId) =>
      getEntityComments(EntityType.blog, blogId);

  Future<void> loadBlogComments(
    String blogId, {
    int page = 1,
    bool refresh = false,
  }) =>
      loadComments(
        EntityType.blog,
        blogId,
        page: page,
        refresh: refresh,
      );

  Future<void> loadComments(
    EntityType type,
    String entityId, {
    int page = 1,
    bool refresh = false,
  }) async {
    final key = _getCommentkey(type, entityId);
    if (page == 1 &&
        !refresh &&
        _comments.containsKey(key) &&
        _comments[key]!.isNotEmpty) {
      return;
    }
    _isLoading = true;
    _error = null;
    if (page == 1) notifyListeners();

    try {
      final Map<String, dynamic> result;

      if (type == EntityType.post) {
        result = await _postService.getCommentsForPost(entityId);
      } else {
        result = await _blogService.getCommentsForBlog(entityId);
      }

      if (result['success'] == true) {
        final newComments = (result['comments'] as List)
            .map((json) => Comment.fromJson(json))
            .toList();
        if (page == 1) {
          _comments[key] = newComments;
        } else {
          _comments[key]?.addAll(newComments);
        }
        _error = null;
      } else {
        _error = result['error'] as String?;
      }
    } catch (e) {
      _error = 'Failed to load comments for ${type.name} $entityId: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCommentReplies(
    EntityType type,
    String entityId,
    int parentCommentId, {
    int page = 1,
  }) async {
    _error = null;
    _isLoading = true;
    if (page == 1) notifyListeners();

    try {
      final result = type == EntityType.post
          ? await _postService.getCommentRepliesById(
              parentCommentId.toString(),
              page: page,
            )
          : await _blogService.getCommentRepliesById(
              parentCommentId.toString(),
              page: page,
            );

      if (result['success'] == true) {
        final replies = (result['replies'] as List)
            .map((r) => Comment.fromJson(r))
            .toList();
        final key = _getCommentkey(type, entityId);

        _addRepliesToComment(
          key,
          parentCommentId,
          replies,
        );
        _error = null;
        notifyListeners();
      } else {
        _error = result['error'];
      }
    } catch (e) {
      _error = 'Failed to load replies: $e';
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addComment({
    required EntityType type,
    required String entityId,
    required String content,
    int? parentCommentId,
  }) async {
    try {
      final Map<String, dynamic> result;
      if (type == EntityType.post) {
        result = await _postService.addCommentToPost(
          postId: entityId,
          content: content,
          parentCommentId: parentCommentId,
        );
      } else {
        result = await _blogService.addBlogComment(
          blogId: entityId,
          content: content,
          parentCommentId: parentCommentId,
        );
      }

      if (result['success'] == true) {
        final newCommentJson = result['comment'] as Map<String, dynamic>;
        final newComment = Comment.fromJson(newCommentJson);
        final key = _getCommentkey(type, entityId);

        if (parentCommentId != null) {
          _addReplyToComment(key, parentCommentId, newComment);
        } else {
          _comments.putIfAbsent(key, () => []).insert(0, newComment);
        }
        _error = null;
        notifyListeners();
        return {'success': true, 'comment': newComment};
      } else {
        _error = result['error'];
        notifyListeners();
        return {'success': false, 'error': _error};
      }
    } catch (e) {
      _error = 'Failed to add comment: $e';
      notifyListeners();
      return {'success': false, 'error': _error};
    }
  }

  void _addReplyToComment(String key, int parentId, Comment newReply) {
    if (_comments.containsKey(key)) {
      _comments[key] = _findAndReplaceComment(
        _comments[key]!,
        parentId,
        (comment) => comment.copyWith(replies: [newReply, ...comment.replies]),
      );
    }
  }

  void _addRepliesToComment(
    String key,
    int parentId,
    List<Comment> newReplies,
  ) {
    if (_comments.containsKey(key)) {
      _comments[key] = _findAndReplaceComment(_comments[key]!, parentId, (
        parent,
      ) {
        final existingReplies = parent.replies;
        final updatedReplies = [...existingReplies, ...newReplies];
        return parent.copyWith(replies: updatedReplies);
      });
    }
  }

  List<Comment> _findAndReplaceComment(
    List<Comment> comments,
    int targetId,
    Comment Function(Comment) update,
  ) {
    return comments.map((comment) {
      if (comment.id == targetId) {
        return update(comment);
      }

      if (comment.replies.isNotEmpty) {
        final newReplies = _findAndReplaceComment(
          comment.replies,
          targetId,
          update,
        );
        if (newReplies != comment.replies) {
          return comment.copyWith(replies: newReplies);
        }
      }
      return comment;
    }).toList();
  }
}
