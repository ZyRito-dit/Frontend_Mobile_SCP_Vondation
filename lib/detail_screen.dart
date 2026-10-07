import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:translator/translator.dart';
import 'api_service.dart';

import 'storage_service.dart';

class DetailScreen extends StatefulWidget {
  final String link;
  final String title;

  const DetailScreen({super.key, required this.link, required this.title});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<String, dynamic>? articleData;
  bool isLoading = true;
  String error = '';
  
  bool isBookmarked = false;
  bool isTranslating = false;
  bool isTranslated = false;
  String? translatedContent;
  String? translatedTitle;
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    _fetchDetail();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final bookmarked = await StorageService.isBookmarked(widget.link);
    if (mounted) {
      setState(() {
        isBookmarked = bookmarked;
      });
    }
  }

  Future<void> _fetchDetail() async {
    try {
      final data = await ApiService.fetchArticleDetail(widget.link);
      if (mounted) {
        setState(() {
          articleData = data;
          isLoading = false;
        });

        // Add to Reading History
        StorageService.addToHistory({
          'scp': data['scp'] ?? widget.title,
          'title': widget.title,
          'link': widget.link,
          'rating': data['rating'],
          'series': data['series'],
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    final item = {
      'scp': articleData?['scp'] ?? widget.title,
      'title': widget.title,
      'link': widget.link,
      'rating': articleData?['rating'],
      'series': articleData?['series'],
    };
    final added = await StorageService.toggleBookmark(item);
    if (mounted) {
      setState(() {
        isBookmarked = added;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(added ? 'Disimpan ke Bookmark' : 'Dihapus dari Bookmark'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _translateContent() async {
    if (articleData == null || articleData!['raw_content'] == null) return;
    
    setState(() {
      isTranslating = true;
    });

    try {
      final tTitle = await translator.translate(widget.title, from: 'en', to: 'id');
      
      String rawHtml = articleData!['raw_content'];
      // Chunking by paragraphs or blocks to avoid 5000 character limit
      List<String> chunks = rawHtml.split(RegExp(r'(?=<(p|div|blockquote)>)'));
      String translatedHtml = '';

      for (String chunk in chunks) {
        if (chunk.trim().isEmpty) continue;
        if (chunk.length > 5) {
            try {
                // translate API preserves very basic HTML
                var t = await translator.translate(chunk, from: 'en', to: 'id');
                translatedHtml += t.text;
            } catch(e) {
                translatedHtml += chunk; 
            }
        } else {
            translatedHtml += chunk;
        }
      }

      if (mounted) {
        setState(() {
          translatedTitle = tTitle.text;
          translatedContent = translatedHtml;
          isTranslated = true;
          isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isTranslating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan translasi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isTranslated ? (translatedTitle ?? widget.title) : widget.title, style: const TextStyle(fontSize: 14)),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.redAccent : null,
            ),
            tooltip: isBookmarked ? 'Hapus Bookmark' : 'Simpan Bookmark',
            onPressed: _toggleBookmark,
          ),
          if (!isLoading && error.isEmpty)
            IconButton(
              icon: isTranslating 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent))
                : Icon(isTranslated ? Icons.g_translate : Icons.translate, color: isTranslated ? Colors.redAccent : null),
              tooltip: 'Terjemahkan',
              onPressed: () {
                if (isTranslating) return;
                if (isTranslated) {
                  setState(() => isTranslated = false);
                } else {
                  if (translatedContent != null) {
                    setState(() => isTranslated = true);
                  } else {
                    _translateContent();
                  }
                }
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : error.isNotEmpty
              ? Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.redAccent, width: 2),
                          color: isDark ? Colors.black : Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WARNING: CLASSIFIED DATA',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Item #: ${articleData!['scp'] ?? 'N/A'}'),
                            Text('Rating: ${articleData!['rating'] ?? 0}'),
                            if (articleData!['series'] != null)
                              Text('Series: ${articleData!['series']}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Content Section
                      if (articleData!['raw_content'] != null)
                        Builder(
                          builder: (context) {
                            String contentToDisplay = isTranslated 
                              ? (translatedContent ?? articleData!['raw_content']) 
                              : articleData!['raw_content'];

                            // Fix Google Translate's literal translation of [REDACTED]
                            contentToDisplay = contentToDisplay.replaceAll(RegExp(r'\[DISUNTING\]', caseSensitive: false), '[DATA DIHAPUS]');
                            contentToDisplay = contentToDisplay.replaceAll(RegExp(r'\[DIHAPUS\]', caseSensitive: false), '[DATA DIHAPUS]');
                            
                            // Force remove inline display:none from Wikidot collapsibles
                            contentToDisplay = contentToDisplay.replaceAll(RegExp(r'style\s*=\s*"display:\s*none;?"', caseSensitive: false), '');
                            contentToDisplay = contentToDisplay.replaceAll(RegExp(r"style\s*=\s*'display:\s*none;?'", caseSensitive: false), '');

                            // Wrap Unicode block characters to force them to be black/dark grey even in dark mode text
                            contentToDisplay = contentToDisplay.replaceAllMapped(
                              RegExp(r'█+'), 
                              (match) => '<span style="color: #111111; background-color: #111111; letter-spacing: -1px;">${match.group(0)}</span>'
                            );

                            return HtmlWidget(
                              contentToDisplay,
                          textStyle: TextStyle(
                            fontFamily: 'Fira Code',
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14.0,
                          ),
                          customStylesBuilder: (element) {
                            // Force show Wikidot collapsible blocks that are hidden by default
                            if (element.classes.contains('collapsible-block-unfolded')) {
                              return {'display': 'block'};
                            }
                            // Hide the "+ Show Block" buttons
                            if (element.classes.contains('collapsible-block-folded')) {
                              return {'display': 'none'};
                            }

                            if (element.localName == 'blockquote') {
                              return {
                                'background-color': isDark ? '#1a1a1a' : '#f0f0f0',
                                'padding': '12px',
                                'border-left': '4px solid #D32F2F',
                              };
                            }
                            if (element.localName == 'a') {
                              return {'color': '#D32F2F', 'text-decoration': 'none'};
                            }
                            return null;
                          },
                        );
                          }
                        )
                      else
                        const Text('No content available for this record.'),
                    ],
                  ),
                ),
    );
  }
}
