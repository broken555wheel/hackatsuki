import 'package:flutter/material.dart';
import 'package:mobile/data/models/blog.dart';
import 'package:mobile/data/models/comment.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/comment_section_widget.dart';
import 'package:mobile/views/widgets/custom_container_widget.dart';

class BlogCardWidget extends StatefulWidget {
  final Blog blog;
  final List<Comment> comments;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final Function(String, int?) onAddComment;
  final Function(int) onLoadReplies;
  final bool showComments;

  static const int maxLinesCollapsed = 4;

  const BlogCardWidget({
    super.key,
    required this.blog,
    required this.comments,
    this.onLike,
    this.onComment,
    required this.onAddComment,
    required this.onLoadReplies,
    this.showComments = false,
  });

  factory BlogCardWidget.fromBlog({
    required Blog blog,
    required List<Comment> comments,
    VoidCallback? onLike,
    VoidCallback? onComment,
    required Function(String, int?) onAddComment,
    required Function(int) onLoadReplies,
    bool showComments = false,
  }) {
    return BlogCardWidget(
      blog: blog,
      comments: comments,
      onLike: onLike,
      onComment: onComment,
      onAddComment: onAddComment,
      onLoadReplies: onLoadReplies,
      showComments: showComments,
    );
  }

  @override
  State<BlogCardWidget> createState() => _BlogCardWidgetState();
}

class _BlogCardWidgetState extends State<BlogCardWidget> {
  bool _isExplanded = false;
  void _toggleExpanded() {
    setState(() {
      _isExplanded = !_isExplanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isContentOverFlowing =
        widget.blog.content.length > (BlogCardWidget.maxLinesCollapsed * 50);

    return CustomContainerWidget(
      color: AppTheme.white,
      horizontalPadding: 8.0,
      verticalPadding: 8.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildUserAvatar(),
                  SizedBox(width: 4.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.blog.user?.firstName ?? 'Unknown'} ${widget.blog.user?.lastName ?? 'User'}',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.buttonTextColor,
                        ),
                      ),
                      Text(
                        widget.blog.formattedTime,
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.gray2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            widget.blog.title,
            style: AppTheme.headingSmall.copyWith(color: AppTheme.green1),
          ),
          SizedBox(height: 8.0),
          Text(
            widget.blog.content,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.black),
            maxLines: _isExplanded ? null : BlogCardWidget.maxLinesCollapsed,
            overflow: _isExplanded ? TextOverflow.clip : TextOverflow.ellipsis,
          ),
          if (isContentOverFlowing) 
          GestureDetector(
            onTap: _toggleExpanded,
            child: Padding(padding: const EdgeInsets.only(top: 4),child: Text(_isExplanded ? 'Show Less' : 'Read more', style: AppTheme.labelMedium.copyWith(color: AppTheme.green3),),),
          ),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLikeButton(),
              _postDetails(
                icon: Icons.message,
                accompanyingText: '${widget.blog.commentsCount ?? 0}',
                onTap: widget.onComment,
              ),
              _postDetails(icon: Icons.share, accompanyingText: "Share"),
            ],
          ),
          if (widget.showComments)
            CommentsSectionWidget(
              comments: widget.comments,
              onAddComment: widget.onAddComment,
              onLoadReplies: widget.onLoadReplies,
            ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: AppTheme.gray1,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Icon(Icons.person, size: 20, color: AppTheme.gray3),
    );
  }

  Widget _buildLikeButton() {
    final bool isLiked = widget.blog.isLikedByCurrentUser == true;

    return GestureDetector(
      onTap: widget.onLike,
      child: Row(
        children: [
          Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : AppTheme.gray2,
          ),
          SizedBox(width: 4.0),
          Text(
            '${widget.blog.likesCount ?? 0}',
            style: AppTheme.labelSmall.copyWith(
              color: isLiked ? Colors.red : AppTheme.gray2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _postDetails({
    required IconData icon,
    required String accompanyingText,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.gray2),
          SizedBox(width: 4.0),
          Text(
            accompanyingText,
            style: AppTheme.labelSmall.copyWith(color: AppTheme.gray2),
          ),
        ],
      ),
    );
  }
}
