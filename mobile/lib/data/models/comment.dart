import 'package:mobile/data/utils/time_utils.dart';

class Comment {
  final int? id;
  final String content;
  final String authorName;
  final String timePosted;
  final int? parentCommentId;
  final List<Comment> replies;
  final int repliesCount;
  final int? postId;
  final int? blogId;
  final int? userId;

  Comment({
    this.id,
    required this.content,
    required this.authorName,
    required this.timePosted,
    this.parentCommentId,
    required this.replies,
    required this.repliesCount,
     this.postId,
     this.blogId,
     this.userId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;
    final firstName = userJson?['first_name'] as String? ?? 'Unknown';
    final lastName = userJson?['last_name'] as String? ?? 'User';
    final authorName = '$firstName $lastName';

    return Comment(
      id: json['id'],
      content: json['content'],
      authorName: authorName,
      timePosted: json['created_at'] ?? 'Recently',
      parentCommentId: json['parent_comment_id'],
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((reply) => Comment.fromJson(reply))
              .toList() ??
          [],
      repliesCount: json['replies_count'] ?? 0,
      postId: json['post_id'],
      blogId: json['blog_id'],
      userId: userJson?['id'],
    );
  }

  Comment copyWith({List<Comment>? replies}) {
    return Comment(
      id: id,
      content: content,
      authorName: authorName,
      timePosted: timePosted,
      parentCommentId: parentCommentId,
      replies: replies ?? this.replies,
      repliesCount: repliesCount,
      postId: postId,
      blogId: blogId,
      userId: userId,
    );
  }

  String get formattedTime {
    
    try {
      final dateTime = DateTime.parse(timePosted).toLocal();
      return formatRelativeTime(dateTime);
    } catch (e) {
      return 'Some time ago';
    }
  }
}
