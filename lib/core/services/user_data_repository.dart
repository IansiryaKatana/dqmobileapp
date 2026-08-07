import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';

class DonationRecord {
  const DonationRecord({
    required this.receiptId,
    required this.amountPence,
    required this.frequency,
    required this.status,
    required this.createdAt,
  });

  final String? receiptId;
  final int amountPence;
  final String frequency;
  final String status;
  final DateTime createdAt;
}

class OrderRecord {
  const OrderRecord({
    required this.reference,
    required this.quantity,
    required this.language,
    required this.status,
    required this.createdAt,
    this.address,
    this.postagePence = 399,
  });

  final String reference;
  final int quantity;
  final String language;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic>? address;
  final int postagePence;
}

class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.line1,
    required this.city,
    required this.postcode,
    required this.isDefault,
  });

  final String id;
  final String label;
  final String line1;
  final String city;
  final String postcode;
  final bool isDefault;

  String get formatted => '$line1, $city, $postcode';
}

class RemoteBookmark {
  const RemoteBookmark({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.savedAt,
  });

  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final DateTime savedAt;
}

class UserDataRepository {
  UserDataRepository(this._client);

  final SupabaseClient? _client;

  Future<List<DonationRecord>> fetchDonations(String userId) async {
    if (_client == null) return [];
    final rows = await _client
        .from('donations')
        .select('receipt_id, amount_pence, frequency, status, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (rows as List).map((row) {
      return DonationRecord(
        receiptId: row['receipt_id'] as String?,
        amountPence: row['amount_pence'] as int,
        frequency: row['frequency'] as String,
        status: row['status'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
      );
    }).toList();
  }

  Future<List<OrderRecord>> fetchOrders(String userId) async {
    if (_client == null) return [];
    final rows = await _client
        .from('orders')
        .select('reference, quantity, language, status, created_at, address, postage_pence')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (rows as List).map((row) => _orderFromRow(row)).toList();
  }

  Future<OrderRecord?> fetchOrderByReference(String userId, String reference) async {
    if (_client == null) return null;
    final row = await _client
        .from('orders')
        .select('reference, quantity, language, status, created_at, address, postage_pence')
        .eq('user_id', userId)
        .eq('reference', reference)
        .maybeSingle();
    if (row == null) return null;
    return _orderFromRow(row);
  }

  OrderRecord _orderFromRow(Map<String, dynamic> row) {
    return OrderRecord(
      reference: row['reference'] as String,
      quantity: row['quantity'] as int,
      language: row['language'] as String,
      status: row['status'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      address: row['address'] as Map<String, dynamic>?,
      postagePence: row['postage_pence'] as int? ?? 399,
    );
  }

  Future<List<SavedAddress>> fetchAddresses(String userId) async {
    if (_client == null) return [];
    final rows = await _client
        .from('saved_addresses')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (rows as List).map((row) {
      return SavedAddress(
        id: row['id'] as String,
        label: row['label'] as String,
        line1: row['line1'] as String,
        city: row['city'] as String,
        postcode: row['postcode'] as String,
        isDefault: row['is_default'] as bool? ?? false,
      );
    }).toList();
  }

  Future<void> saveAddress({
    required String userId,
    required String label,
    required String line1,
    required String city,
    required String postcode,
  }) async {
    if (_client == null) return;
    await _client.from('saved_addresses').insert({
      'user_id': userId,
      'label': label,
      'line1': line1,
      'city': city,
      'postcode': postcode,
    });
  }

  Future<void> syncBookmark({
    required String userId,
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
  }) async {
    if (_client == null) return;
    try {
      await _client.from('quran_bookmarks').upsert({
        'user_id': userId,
        'surah_number': surahNumber,
        'surah_name': surahName,
        'ayah_number': ayahNumber,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Bookmark sync failed: $e');
    }
  }

  Future<void> deleteBookmark({
    required String userId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    if (_client == null) return;
    try {
      await _client
          .from('quran_bookmarks')
          .delete()
          .eq('user_id', userId)
          .eq('surah_number', surahNumber)
          .eq('ayah_number', ayahNumber);
    } catch (e) {
      if (kDebugMode) debugPrint('Bookmark delete sync failed: $e');
    }
  }

  Future<List<RemoteBookmark>> fetchRemoteBookmarks(String userId) async {
    if (_client == null) return [];
    final rows = await _client
        .from('quran_bookmarks')
        .select('surah_number, surah_name, ayah_number, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (rows as List).map((row) {
      return RemoteBookmark(
        surahNumber: row['surah_number'] as int,
        surahName: row['surah_name'] as String,
        ayahNumber: row['ayah_number'] as int,
        savedAt: DateTime.parse(row['created_at'] as String),
      );
    }).toList();
  }

  Future<void> syncSavedArticle({
    required String userId,
    required String articleId,
    required String title,
  }) async {
    if (_client == null) return;
    await _client.from('saved_articles').upsert({
      'user_id': userId,
      'article_id': articleId,
      'title': title,
    });
  }

  Future<void> syncSavedBook({
    required String userId,
    required String bookId,
    required String title,
  }) async {
    if (_client == null) return;
    try {
      await _client.from('saved_books').upsert({
        'user_id': userId,
        'book_id': bookId,
        'title': title,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Saved book sync failed: $e');
    }
  }
}

final userDataRepositoryProvider = Provider<UserDataRepository>((ref) {
  return UserDataRepository(EnvConfig.supabase);
});
