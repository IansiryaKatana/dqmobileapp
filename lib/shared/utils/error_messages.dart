import 'package:flutter/foundation.dart';

abstract final class ErrorMessages {
  static String friendly(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('email not confirmed')) {
      return 'Please confirm your email before signing in.';
    }
    if (message.contains('invalid login') || message.contains('invalid credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (message.contains('user already registered') || message.contains('already exists')) {
      return 'An account with this email already exists.';
    }
    if (message.contains('cancelled')) {
      return 'Postage payment was cancelled.';
    }
    if (message.contains('network') || message.contains('socket') || message.contains('connection')) {
      return 'Network error. Check your connection and try again.';
    }
    if (message.contains('offline') || message.contains('not configured')) {
      return 'This feature requires an internet connection and server setup.';
    }
    if (kDebugMode) return error.toString();
    return 'Something went wrong. Please try again.';
  }
}
