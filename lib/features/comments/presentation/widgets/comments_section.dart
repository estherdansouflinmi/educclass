// lib/features/comments/presentation/widgets/comments_section.dart
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/utils/date_utils.dart';
import 'package:educclass/features/auth/presentation/providers/auth_provider.dart';
import 'package:educclass/features/comments/domain/models/comment_model.dart';
import 'package:educclass/features/comments/presentation/providers/comment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentsSection extends ConsumerStatefulWidget {
  const CommentsSection({
    super.key,
    required this.classroomId,
    required this.parentId,
    required this.context_,
  });

  final String classroomId;
  final String parentId;
  final CommentContext context_;

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isSending = true);
    _controller.clear();

    await ref.read(addCommentProvider.notifier).addComment(
          classroomId: widget.classroomId,
          parentId: widget.parentId,
          context: widget.context_,
          authorId: user.uid,
          authorName: user.displayName,
          authorPhotoUrl: user.photoUrl,
          content: text,
        );

    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider((
      classroomId: widget.classroomId,
      parentId: widget.parentId,
      context: widget.context_,
    )));
    final user = ref.watch(authNotifierProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.comments,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        commentsAsync.when(
          loading: () => const Center(
              child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(strokeWidth: 2),
          )),
          error: (_, __) => const Text(
            'Impossible de charger les commentaires',
            style: TextStyle(color: AppColors.grey500, fontSize: 13),
          ),
          data: (comments) {
            if (comments.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  AppStrings.noComments,
                  style: const TextStyle(
                      color: AppColors.grey400, fontSize: 13),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (_, i) => _CommentTile(
                comment: comments[i],
                currentUserId: user?.uid,
                onDelete: user?.uid == comments[i].authorId
                    ? () => ref
                        .read(commentRepositoryProvider)
                        .deleteComment(
                          classroomId: widget.classroomId,
                          parentId: widget.parentId,
                          context: widget.context_,
                          commentId: comments[i].id,
                        )
                    : null,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: AppStrings.writeComment,
                  filled: true,
                  fillColor: AppColors.grey50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                        const BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide:
                        const BorderSide(color: AppColors.grey300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 8),
            _isSending
                ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                    color: AppColors.primary,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.currentUserId,
    this.onDelete,
  });

  final CommentModel comment;
  final String? currentUserId;
  final Future<void> Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    final isMe = comment.authorId == currentUserId;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              comment.authorName.isNotEmpty
                  ? comment.authorName[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppDateUtils.relativeTime(comment.createdAt),
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.grey400),
                    ),
                    const Spacer(),
                    if (onDelete != null)
                      GestureDetector(
                        onTap: onDelete,
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: AppColors.grey400,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.content,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.grey700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
