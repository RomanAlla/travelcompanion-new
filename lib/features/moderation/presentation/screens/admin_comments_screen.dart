import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travelcompanion/core/presentation/widgets/app_bar.dart';
import 'package:travelcompanion/core/domain/entities/comment_model.dart';
import 'package:travelcompanion/features/details_route/presentation/providers/comment_rep_provider.dart';
import 'package:travelcompanion/core/domain/theme/app_theme.dart';
import 'package:travelcompanion/features/moderation/presentation/providers/admin_comments_provider.dart';

class AdminCommentsScreen extends ConsumerWidget {
  const AdminCommentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(adminCommentsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBarWidget(title: 'Все комментарии'),
      ),
      body: commentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Произошла ошибка... Попробуйте позже')),
        data: (comments) {
          if (comments.isEmpty) return const Center(child: Text('Пусто'));
          final repo = ref.watch(commentRepositoryProvider);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return Dismissible(
                key: ValueKey(comment.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red.shade50,
                  child: const Icon(Icons.delete_forever, color: Colors.red),
                ),
                onDismissed: (_) async {
                  await repo.deleteComment(comment.id);
                  ref.invalidate(adminCommentsProvider);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.white,
                      content: Center(
                        child: Text(
                          style: AppTheme.bodyMediumBold.copyWith(
                            color: AppTheme.primaryLightColor,
                          ),
                          'Комментарий удален',
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.white : AppTheme.lightBlue,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _CommentTile(
                    comment: comment,
                    onDelete: () async {
                      await repo.deleteComment(comment.id);
                      ref.invalidate(adminCommentsProvider);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.white,
                          content: Center(
                            child: Text(
                              style: AppTheme.bodyMediumBold.copyWith(
                                color: AppTheme.primaryLightColor,
                              ),
                              'Комментарий удален',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback onDelete;
  const _CommentTile({required this.comment, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateFormat('dd.MM.yyyy HH:mm').format(comment.createdAt);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chat_bubble_outline, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.creator?.name ?? comment.creator?.email ?? '—',
                        style: AppTheme.bodySmallBold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('${comment.rating}', style: AppTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.text, style: AppTheme.bodySmall),
                const SizedBox(height: 6),
                Text(
                  createdAt,
                  style: AppTheme.bodyMini.copyWith(color: AppTheme.grey600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            tooltip: 'Удалить',
          ),
        ],
      ),
    );
  }
}
