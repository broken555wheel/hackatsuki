import 'package:flutter/material.dart';
import 'package:mobile/data/models/comment.dart';
import 'package:mobile/data/models/post.dart';
import 'package:mobile/theme.dart';
import 'package:mobile/views/widgets/comment_section_widget.dart';
import 'package:mobile/views/widgets/custom_container_widget.dart';

class PostCardWidget extends StatefulWidget {
  final Post post;
  final List<Comment> comments;
  final VoidCallback? onSeeMoreComments;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final Function(String, int?) onAddComment;
  final Function(int) onLoadReplies;
  final bool showComments;
  final VoidCallback? onDelete;
  final int? currentUserId;

  static const int maxLinesCollapsed = 4;

  const PostCardWidget({
    super.key,
    required this.post,
    required this.comments,
    this.onSeeMoreComments,
    this.onLike,
    this.onComment,
    required this.onAddComment,
    required this.onLoadReplies,
    required this.onDelete,
    this.showComments = false,
    this.currentUserId,
  });

  factory PostCardWidget.fromPost({
    required Post post,
    required List<Comment> comments,
    VoidCallback? onSeeMoreComments,
    VoidCallback? onLike,
    VoidCallback? onComment,
    required Function(String, int?) onAddComment,
    required Function(int) onLoadReplies,
    bool showComments = false,
    VoidCallback? onDelete,
    int? currentuserId,
  }) {
    return PostCardWidget(
      post: post,
      comments: comments,
      onSeeMoreComments: onSeeMoreComments,
      onLike: onLike,
      onComment: onComment,
      onAddComment: onAddComment,
      onLoadReplies: onLoadReplies,
      showComments: showComments,
      onDelete: onDelete,
    );
  }

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  bool _isExplanded = false;
  void _toggleExpanded() {
    setState(() {
      _isExplanded = !_isExplanded;
    });
  }
  @override
  Widget build(BuildContext context) {
    final bool isContentOverFlowing =
        widget.post.description.length > (PostCardWidget.maxLinesCollapsed * 50);
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
                        '${widget.post.user?.firstName ?? 'Unknown'} ${widget.post.user?.lastName ?? 'User'}',
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.buttonTextColor,
                        ),
                      ),
                      Text(
                        '2 hours ago',
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.gray2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (widget.post.crop != null && widget.post.crop!.isNotEmpty)
                CustomContainerWidget(
                  color: AppTheme.green1,
                  horizontalPadding: 8,
                  verticalPadding: 4,
                  child: Text(
                    widget.post.crop!,
                    style: AppTheme.labelSmall.copyWith(color: AppTheme.white),
                  ),
                ),
              if (widget.currentUserId != null &&
                  widget.currentUserId == widget.post.user?.id)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: widget.onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            widget.post.question,
            style: AppTheme.labelLarge.copyWith(color: AppTheme.black),
          ),
          SizedBox(height: 8.0),
          if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                widget.post.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    color: AppTheme.gray1,
                    child: Icon(Icons.broken_image, color: AppTheme.gray3),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 150,
                    width: double.infinity,
                    color: AppTheme.gray1,
                    child: Center(
                      child: CircularProgressIndicator(color: AppTheme.green3),
                    ),
                  );
                },
              ),
            ),
          SizedBox(height: 8.0),
          if (widget.post.description.isNotEmpty)
            Text(
              widget.post.description,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.gray3),
              maxLines: _isExplanded ? null : PostCardWidget.maxLinesCollapsed,
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
                accompanyingText: '${widget.post.commentsCount ?? 0}',
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
    //TODO: Add user image
    return _buildDefaultAvatar();
  }

  Widget _buildLikeButton() {
    final bool isLiked = widget.post.isLikedByCurrentUser == true;

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
            '${widget.post.likesCount ?? 0}',
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

  Widget _buildDefaultAvatar() {
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
}
