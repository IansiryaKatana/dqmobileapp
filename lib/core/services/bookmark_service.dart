import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/app_state_provider.dart';
import 'user_data_repository.dart';

class Bookmark {
  const Bookmark({
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
    required this.savedAt,
  });

  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'surahName': surahName,
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'savedAt': savedAt.toIso8601String(),
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        surahName: json['surahName'] as String,
        surahNumber: json['surahNumber'] as int,
        ayahNumber: json['ayahNumber'] as int,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}

class DonationReceipt {
  const DonationReceipt({
    required this.receiptId,
    required this.amountPence,
    required this.createdAt,
  });

  final String receiptId;
  final int amountPence;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'receiptId': receiptId,
        'amountPence': amountPence,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DonationReceipt.fromJson(Map<String, dynamic> json) => DonationReceipt(
        receiptId: json['receiptId'] as String,
        amountPence: json['amountPence'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class SavedArticle {
  const SavedArticle({
    required this.articleId,
    required this.title,
    required this.savedAt,
  });

  final String articleId;
  final String title;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'articleId': articleId,
        'title': title,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedArticle.fromJson(Map<String, dynamic> json) => SavedArticle(
        articleId: json['articleId'] as String,
        title: json['title'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}

class SavedBook {
  const SavedBook({
    required this.bookId,
    required this.title,
    required this.savedAt,
  });

  final String bookId;
  final String title;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        'title': title,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedBook.fromJson(Map<String, dynamic> json) => SavedBook(
        bookId: json['bookId'] as String,
        title: json['title'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}

class ReadingProgress {
  const ReadingProgress({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
  });

  final int surahNumber;
  final String surahName;
  final int ayahNumber;

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'surahName': surahName,
        'ayahNumber': ayahNumber,
      };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) => ReadingProgress(
        surahNumber: json['surahNumber'] as int,
        surahName: json['surahName'] as String,
        ayahNumber: json['ayahNumber'] as int,
      );
}

class BookmarkService {
  BookmarkService(this._prefs, this._userData, this._userId);

  final SharedPreferences _prefs;
  final UserDataRepository _userData;
  final String? _userId;

  static const _bookmarksKey = 'quran_bookmarks';
  static const _receiptsKey = 'donation_receipts';
  static const _articlesKey = 'saved_articles';
  static const _booksKey = 'saved_books';

  List<Bookmark> get bookmarks {
    final raw = _prefs.getStringList(_bookmarksKey) ?? [];
    return raw.map((e) => Bookmark.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
  }

  List<DonationReceipt> get receipts {
    final raw = _prefs.getStringList(_receiptsKey) ?? [];
    return raw.map((e) => DonationReceipt.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
  }

  List<SavedArticle> get articles {
    final raw = _prefs.getStringList(_articlesKey) ?? [];
    return raw.map((e) => SavedArticle.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
  }

  List<SavedBook> get books {
    final raw = _prefs.getStringList(_booksKey) ?? [];
    return raw.map((e) => SavedBook.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    final list = bookmarks
      ..removeWhere((b) => b.surahNumber == bookmark.surahNumber && b.ayahNumber == bookmark.ayahNumber);
    list.insert(0, bookmark);
    await _saveBookmarks(list);
    if (_userId != null) {
      await _userData.syncBookmark(
        userId: _userId!,
        surahNumber: bookmark.surahNumber,
        surahName: bookmark.surahName,
        ayahNumber: bookmark.ayahNumber,
      );
    }
  }

  Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    final list = bookmarks..removeWhere((b) => b.surahNumber == surahNumber && b.ayahNumber == ayahNumber);
    await _saveBookmarks(list);
    if (_userId != null) {
      await _userData.deleteBookmark(
        userId: _userId!,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      );
    }
  }

  Future<void> addReceipt(DonationReceipt receipt) async {
    final list = receipts..insert(0, receipt);
    await _prefs.setStringList(_receiptsKey, list.map((e) => jsonEncode(e.toJson())).toList());
  }

  Future<void> addArticle(SavedArticle article) async {
    final list = articles..removeWhere((a) => a.articleId == article.articleId);
    list.insert(0, article);
    await _prefs.setStringList(_articlesKey, list.map((e) => jsonEncode(e.toJson())).toList());
    if (_userId != null) {
      await _userData.syncSavedArticle(userId: _userId!, articleId: article.articleId, title: article.title);
    }
  }

  Future<void> addBook(SavedBook book) async {
    final list = books..removeWhere((b) => b.bookId == book.bookId);
    list.insert(0, book);
    await _prefs.setStringList(_booksKey, list.map((e) => jsonEncode(e.toJson())).toList());
    if (_userId != null) {
      await _userData.syncSavedBook(userId: _userId!, bookId: book.bookId, title: book.title);
    }
  }

  static const _progressKey = 'quran_reading_progress';

  ReadingProgress? get readingProgress {
    final raw = _prefs.getString(_progressKey);
    if (raw == null) return null;
    try {
      return ReadingProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveReadingProgress(ReadingProgress progress) async {
    await _prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }

  Future<void> _saveBookmarks(List<Bookmark> list) async {
    await _prefs.setStringList(_bookmarksKey, list.map((e) => jsonEncode(e.toJson())).toList());
  }
}

final bookmarkServiceProvider = FutureProvider<BookmarkService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = ref.watch(appStateProvider.select((s) => s.user?.id));
  final userData = ref.read(userDataRepositoryProvider);
  final service = BookmarkService(prefs, userData, userId);
  if (userId != null) {
    final remote = await userData.fetchRemoteBookmarks(userId);
    for (final item in remote.reversed) {
      await service.addBookmark(Bookmark(
        surahName: item.surahName,
        surahNumber: item.surahNumber,
        ayahNumber: item.ayahNumber,
        savedAt: item.savedAt,
      ));
    }
  }
  return service;
});
