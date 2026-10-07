import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scp_item_model.dart';

abstract class ScpLocalDataSource {
  Future<List<ScpItemModel>> getBookmarks();
  Future<bool> isBookmarked(String scpId);
  Future<bool> toggleBookmark(ScpItemModel item);
  Future<List<ScpItemModel>> getHistory();
  Future<void> addToHistory(ScpItemModel item);
  Future<void> clearHistory();
}

@LazySingleton(as: ScpLocalDataSource)
class ScpLocalDataSourceImpl implements ScpLocalDataSource {
  static const String _bookmarkKey = 'scp_bookmarks';
  static const String _historyKey = 'scp_history';

  final SharedPreferences sharedPreferences;

  ScpLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<ScpItemModel>> getBookmarks() async {
    final String? data = sharedPreferences.getString(_bookmarkKey);
    if (data == null || data.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => ScpItemModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> isBookmarked(String scpId) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((item) => item.scp == scpId || item.link == scpId);
  }

  @override
  Future<bool> toggleBookmark(ScpItemModel item) async {
    final bookmarks = await getBookmarks();
    final scpId = item.scp.isNotEmpty ? item.scp : item.link;

    final index = bookmarks.indexWhere((element) => (element.scp.isNotEmpty ? element.scp : element.link) == scpId);

    if (index >= 0) {
      bookmarks.removeAt(index);
      await sharedPreferences.setString(
          _bookmarkKey, jsonEncode(bookmarks.map((e) => e.toJson()).toList()));
      return false;
    } else {
      bookmarks.insert(0, item);
      await sharedPreferences.setString(
          _bookmarkKey, jsonEncode(bookmarks.map((e) => e.toJson()).toList()));
      return true;
    }
  }

  @override
  Future<List<ScpItemModel>> getHistory() async {
    final String? data = sharedPreferences.getString(_historyKey);
    if (data == null || data.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => ScpItemModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addToHistory(ScpItemModel item) async {
    final history = await getHistory();
    final scpId = item.scp.isNotEmpty ? item.scp : item.link;

    history.removeWhere((element) => (element.scp.isNotEmpty ? element.scp : element.link) == scpId);

    history.insert(0, item);

    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    await sharedPreferences.setString(
        _historyKey, jsonEncode(history.map((e) => e.toJson()).toList()));
  }

  @override
  Future<void> clearHistory() async {
    await sharedPreferences.remove(_historyKey);
  }
}
