import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/bookmark/bookmark_bloc.dart';
import '../bloc/bookmark/bookmark_event.dart';
import '../bloc/bookmark/bookmark_state.dart';
import 'detail_page.dart';

class BookmarkPage extends StatelessWidget {
  final bool isDarkMode;

  const BookmarkPage({super.key, required this.isDarkMode});

  Color _getBadgeColor(int level) {
    switch (level) {
      case 1:
        return Colors.greenAccent;
      case 2:
        return Colors.amberAccent;
      case 3:
        return Colors.orangeAccent;
      case 4:
        return Colors.purpleAccent;
      default:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userClearance = authState.user?.clearanceLevel ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SAVED SCP ARCHIVES'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<BookmarkBloc>().add(LoadBookmarksEvent()),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<BookmarkBloc, BookmarkState>(
        builder: (context, state) {
          if (state.status == BookmarkStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          }

          if (state.bookmarks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_outline, size: 64, color: Colors.grey[500]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada SCP tersimpan.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buka SCP dan tekan ikon bookmark untuk menyimpan.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: state.bookmarks.length,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemBuilder: (context, index) {
              final article = state.bookmarks[index];
              final isUnlocked = userClearance >= article.requiredClearance;
              final badgeColor = _getBadgeColor(article.requiredClearance);

              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        link: article.link,
                        title: article.title,
                      ),
                    ),
                  );
                  if (context.mounted) {
                    context.read<BookmarkBloc>().add(LoadBookmarksEvent());
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    border: Border.all(
                      color: isUnlocked
                          ? (isDarkMode ? Colors.redAccent.withValues(alpha: 0.5) : Colors.black87)
                          : Colors.redAccent.withValues(alpha: 0.8),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              article.scp.isNotEmpty ? article.scp : article.title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () {
                              context.read<BookmarkBloc>().add(RemoveBookmarkEvent(article));
                            },
                            tooltip: 'Hapus dari Bookmark',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${article.rating}'),
                          const SizedBox(width: 12),
                          // Required Clearance Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.15),
                              border: Border.all(color: badgeColor, width: 1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'LVL ${article.requiredClearance}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Access Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? Colors.greenAccent.withValues(alpha: 0.15)
                                  : Colors.redAccent.withValues(alpha: 0.15),
                              border: Border.all(
                                color: isUnlocked ? Colors.greenAccent : Colors.redAccent,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isUnlocked ? Icons.verified_user : Icons.lock,
                                  size: 12,
                                  color: isUnlocked ? Colors.greenAccent : Colors.redAccent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isUnlocked ? 'TERBUKA' : 'TERKUNCI',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: isUnlocked ? Colors.greenAccent : Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
