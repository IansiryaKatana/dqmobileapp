import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_config.dart';

class ScholarQuestionRecord {
  const ScholarQuestionRecord({
    required this.id,
    required this.topic,
    required this.question,
    required this.status,
    required this.createdAt,
    this.answer,
    this.answeredAt,
  });

  final String id;
  final String topic;
  final String question;
  final String status;
  final DateTime createdAt;
  final String? answer;
  final DateTime? answeredAt;

  bool get hasAnswer => answer != null && answer!.trim().isNotEmpty;
}

class ScholarRepository {
  ScholarRepository(this._client);

  final SupabaseClient? _client;

  /// Submits a scholar question. Returns the DB id (or debug SQ- stub).
  /// Release builds require Supabase — no fake SQ- success without a backend.
  Future<String> submitQuestion({
    required String name,
    required String email,
    required String topic,
    required String question,
    String? userId,
  }) async {
    if (_client == null) {
      if (kReleaseMode) {
        throw Exception('Scholar questions require Supabase configuration');
      }
      return 'SQ-DEBUG-${DateTime.now().millisecondsSinceEpoch}';
    }

    final row = await _client.from('scholar_questions').insert({
      'user_id': userId,
      'name': name,
      'email': email,
      'topic': topic,
      'question': question,
      'status': 'submitted',
    }).select('id').single();

    return row['id'] as String;
  }

  Future<List<ScholarQuestionRecord>> fetchQuestions(String userId) async {
    if (_client == null) return [];
    final rows = await _client
        .from('scholar_questions')
        .select('id, topic, question, status, created_at, answer, answered_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (rows as List).map((row) {
      final answeredAtRaw = row['answered_at'] as String?;
      return ScholarQuestionRecord(
        id: row['id'] as String,
        topic: row['topic'] as String,
        question: row['question'] as String,
        status: row['status'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
        answer: row['answer'] as String?,
        answeredAt: answeredAtRaw != null ? DateTime.parse(answeredAtRaw) : null,
      );
    }).toList();
  }
}

final scholarRepositoryProvider = Provider<ScholarRepository>((ref) {
  return ScholarRepository(EnvConfig.supabase);
});
