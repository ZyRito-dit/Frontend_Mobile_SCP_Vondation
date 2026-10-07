import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _bookmarkKey = 'scp_bookmarks';
  static const String _historyKey = 'scp_history';

  // --- BOOKMARKS ---
  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_bookmarkKey);
    if (data == null || data.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> isBookmarked(String scpNumber) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((item) => item['scp']?.toString() == scpNumber || item['link'] == scpNumber);
  }

  static Future<bool> toggleBookmark(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();
    final scpId = item['scp']?.toString() ?? item['link'];

    final index = bookmarks.indexWhere((element) => (element['scp']?.toString() ?? element['link']) == scpId);

    if (index >= 0) {
      bookmarks.removeAt(index);
      await prefs.setString(_bookmarkKey, jsonEncode(bookmarks));
      return false; // Removed
    } else {
      bookmarks.insert(0, {
        'scp': item['scp'],
        'title': item['title'],
        'link': item['link'],
        'rating': item['rating'],
        'series': item['series'],
        'bookmarked_at': DateTime.now().toIso8601String(),
      });
      await prefs.setString(_bookmarkKey, jsonEncode(bookmarks));
      return true; // Added
    }
  }

  // --- HISTORY ---
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_historyKey);
    if (data == null || data.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addToHistory(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    final scpId = item['scp']?.toString() ?? item['link'];

    // Remove duplicates if already in history
    history.removeWhere((element) => (element['scp']?.toString() ?? element['link']) == scpId);

    // Insert at beginning
    history.insert(0, {
      'scp': item['scp'],
      'title': item['title'],
      'link': item['link'],
      'rating': item['rating'],
      'series': item['series'],
      'read_at': DateTime.now().toIso8601String(),
    });

    // Limit history to 50 items max
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    await prefs.setString(_historyKey, jsonEncode(history));
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
