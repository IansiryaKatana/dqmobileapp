import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/env_config.dart';

/// RevenueCat / store product identifiers.
///
/// Create matching products in App Store Connect and Google Play, then attach
/// them to a RevenueCat offering. Expected IDs (document in `.env.example`):
///
/// One-time donations: `dq_donate_5_once`, `dq_donate_10_once`, `dq_donate_25_once`,
/// `dq_donate_50_once`, `dq_donate_100_once`
/// Monthly: `dq_donate_5_monthly`, `dq_donate_10_monthly`, … `dq_donate_100_monthly`
/// Postage: `dq_postage_399` (£3.99)
///
/// Custom amounts outside this catalogue fail closed in release (no wrong package).
abstract final class PurchaseService {
  static bool _initialized = false;

  /// Preset donation amounts (pounds) that map 1:1 to store products.
  static const supportedDonationPounds = {5, 10, 25, 50, 100};

  static const postageProductId = 'dq_postage_399';
  static const postagePence = 399;

  static Future<void> init({String? userId}) async {
    if (_initialized) return;
    final androidKey = EnvConfig.revenueCatAndroidKey;
    final iosKey = EnvConfig.revenueCatIosKey;
    if (androidKey.isEmpty && iosKey.isEmpty) {
      if (kDebugMode) debugPrint('RevenueCat keys not configured');
      return;
    }
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
    final config = PurchasesConfiguration(
      defaultTargetPlatform == TargetPlatform.iOS ? iosKey : androidKey,
    );
    if (userId != null) config.appUserID = userId;
    await Purchases.configure(config);
    _initialized = true;
  }

  static bool get isConfigured => _initialized;

  /// Product ID for a donation amount + frequency.
  static String donationProductId({required int amountPounds, required bool monthly}) {
    final freq = monthly ? 'monthly' : 'once';
    return 'dq_donate_${amountPounds}_$freq';
  }

  static Future<bool> hasPremium() async {
    if (!_initialized) return false;
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.isNotEmpty;
  }

  /// Purchases the exact donation product for [amountPence] + frequency.
  /// Returns `true` on success. In debug without RC, returns `false` (caller may stub).
  /// In release without RC / missing product / failed purchase: throws.
  static Future<bool> processDonation({
    required int amountPence,
    required bool monthly,
  }) async {
    final amountPounds = amountPence ~/ 100;
    final productId = donationProductId(amountPounds: amountPounds, monthly: monthly);

    if (!_initialized) {
      if (kReleaseMode) {
        throw Exception('Payments are not available yet. Please try again later.');
      }
      return false;
    }

    if (!supportedDonationPounds.contains(amountPounds)) {
      throw Exception(
        '£$amountPounds is not available as an in-app product yet. '
        'Please choose £5, £10, £25, £50, or £100.',
      );
    }

    try {
      final package = await _findPackage(productId);
      if (package == null) {
        throw Exception(
          'Donation product "$productId" is not in the current RevenueCat offering. '
          'Add it in App Store / Play Console and RevenueCat, then try again.',
        );
      }
      await Purchases.purchasePackage(package);
      return true;
    } on PlatformException catch (e) {
      _rethrowPurchaseError(e, cancelledMessage: 'Payment was cancelled.');
    } catch (e) {
      if (_isUserFacing(e)) rethrow;
      if (kDebugMode) debugPrint('RevenueCat donation failed: $e');
      throw Exception('Payment was not completed. Please try again.');
    }
  }

  /// Charges postage (£3.99) before an order is inserted.
  static Future<bool> processPostagePayment() async {
    if (!_initialized) {
      if (kReleaseMode) {
        throw Exception('Postage payment is not available yet. Please try again later.');
      }
      return false;
    }

    try {
      final package = await _findPackage(postageProductId);
      if (package == null) {
        throw Exception(
          'Postage product "$postageProductId" is not in the current RevenueCat offering. '
          'Configure £3.99 postage in the stores and RevenueCat, then try again.',
        );
      }
      await Purchases.purchasePackage(package);
      return true;
    } on PlatformException catch (e) {
      _rethrowPurchaseError(e, cancelledMessage: 'Postage payment was cancelled.');
    } catch (e) {
      if (_isUserFacing(e)) rethrow;
      if (kDebugMode) debugPrint('RevenueCat postage failed: $e');
      throw Exception('Postage payment was not completed. Please try again.');
    }
  }

  static Never _rethrowPurchaseError(PlatformException e, {required String cancelledMessage}) {
    final code = PurchasesErrorHelper.getErrorCode(e);
    if (code == PurchasesErrorCode.purchaseCancelledError) {
      throw Exception(cancelledMessage);
    }
    if (kDebugMode) debugPrint('RevenueCat error: $code ${e.message}');
    throw Exception('Payment was not completed. Please try again.');
  }

  static bool _isUserFacing(Object e) {
    final msg = e.toString();
    return msg.contains('Donation product') ||
        msg.contains('Postage product') ||
        msg.contains('not available as an in-app') ||
        msg.contains('Payment was cancelled') ||
        msg.contains('Postage payment was cancelled') ||
        msg.contains('Payments are not available') ||
        msg.contains('Postage payment is not available');
  }

  static Future<Package?> _findPackage(String productId) async {
    final offerings = await Purchases.getOfferings();
    final offering = offerings.current;
    if (offering == null) return null;
    for (final package in offering.availablePackages) {
      if (package.storeProduct.identifier == productId) return package;
    }
    return null;
  }
}
