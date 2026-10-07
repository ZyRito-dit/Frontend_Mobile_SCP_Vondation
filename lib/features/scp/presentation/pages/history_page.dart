import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/history/history_bloc.dart';
import '../bloc/history/history_event.dart';
import '../bloc/history/history_state.dart';
import 'detail_page.dart';

class HistoryPage extends StatelessWidget {
  final bool isDarkMode;

  const HistoryPage({super.key, required this.isDarkMode});

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

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userClearance = authState.user?.clearanceLevel ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('READING LOGS / RIWAYAT'),
        actions: [
          BlocBuilder<HistoryBloc, HistoryState>(
            builder: (context, state) {
              if (state.history.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus Riwayat'),
                      content: const Text('Apakah Anda yakin ingin menghapus semua riwayat bacaan?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    context.read<HistoryBloc>().add(ClearHistoryLogsEvent());
                  }
                },
                tooltip: 'Hapus Semua Riwayat',
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state.status == HistoryStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          }

          if (state.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[500]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat bacaan.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SCP yang Anda baca akan otomatis tercatat di sini.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: state.history.length,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemBuilder: (context, index) {
              final article = state.history[index];
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
                    context.read<HistoryBloc>().add(LoadHistoryEvent());
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    border: Border.all(
                      color: isUnlocked
                          ? (isDarkMode ? Colors.redAccent.withValues(alpha: 0.3) : Colors.black45)
                          : Colors.redAccent.withValues(alpha: 0.8),
                      width: 1.0,
                    ),
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
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(article.timestamp),
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
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
