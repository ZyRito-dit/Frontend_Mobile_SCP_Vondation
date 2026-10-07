import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  final bool isDarkMode;
  const BookmarksScreen({super.key, required this.isDarkMode});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Map<String, dynamic>> bookmarks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final list = await StorageService.getBookmarks();
    if (mounted) {
      setState(() {
        bookmarks = list;
        isLoading = false;
      });
    }
  }

  Future<void> _removeBookmark(Map<String, dynamic> item) async {
    await StorageService.toggleBookmark(item);
    _loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAVED SCP ARCHIVES'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookmarks,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : bookmarks.isEmpty
              ? Center(
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
                )
              : ListView.builder(
                  itemCount: bookmarks.length,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemBuilder: (context, index) {
                    final article = bookmarks[index];
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              link: article['link'] ?? '',
                              title: article['title'] ?? 'SCP Article',
                            ),
                          ),
                        );
                        _loadBookmarks();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          border: Border.all(
                            color: widget.isDarkMode ? Colors.redAccent.withValues(alpha: 0.5) : Colors.black87,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.isDarkMode ? Colors.red.withValues(alpha: 0.1) : Colors.black12,
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
                                Text(
                                  article['scp'] ?? article['title'] ?? 'UNKNOWN',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () => _removeBookmark(article),
                                  tooltip: 'Hapus dari Bookmark',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              article['title'] ?? 'No Title',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (article['rating'] != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text('${article['rating']}'),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
