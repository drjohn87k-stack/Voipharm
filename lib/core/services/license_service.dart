import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// License / registration-code service.
///
/// Protects the author's proprietary rights (Abdullah Alshwerif - 0917156449).
/// Each app install gets a unique device id. A registration code is derived
/// from that device id using an HMAC with a secret salt, so the developer
/// can issue a unique code per install and validate it offline.
///
/// The validation is fully offline: the app hashes the entered code with
/// the device id + secret and compares. No server needed.
class LicenseService {
  LicenseService._();
  static final LicenseService instance = LicenseService._();

  /// Secret salt embedded in the app. Keep private — used to sign codes.
  static const String _secret = 'MrR3qu3stVoiceApp-AbdullahAlshwerif-2025';

  bool _activated = false;
  String _deviceId = '';
  String _activatedCode = '';

  bool get isActivated => _activated;
  String get deviceId => _deviceId;
  String get activatedCode => _activatedCode;

  /// Load persisted state.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString(AppConstants.prefDeviceId) ?? _generateDeviceId();
    await prefs.setString(AppConstants.prefDeviceId, _deviceId);
    _activated = prefs.getBool(AppConstants.prefLicenseActivated) ?? false;
    _activatedCode = prefs.getString(AppConstants.prefLicenseKey) ?? '';
  }

  /// Generate (or retrieve) the device id. We use a random UUID-like string
  /// stored on device so each install is uniquely identifiable.
  String _generateDeviceId() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '').substring(0, 16);
  }

  /// The expected registration code for *this* device.
  /// Format: XXXX-XXXX-XXXX-XXXX (16 hex-ish chars).
  String expectedCode() {
    return _codeForDevice(_deviceId);
  }

  /// Computes the registration code for an arbitrary device id.
  /// This is what the developer runs to issue a code to a customer.
  String _codeForDevice(String deviceId) {
    final hmac = Hmac(sha256, utf8.encode(_secret));
    final digest = hmac.convert(utf8.encode('$deviceId::license'));
    final hex = digest.toString();
    // Take 16 chars, format as 4 groups of 4
    final raw = hex.replaceAll(RegExp(r'[^A-F0-9]'), '').toUpperCase();
    final group = raw.substring(0, 16);
    return '${group.substring(0, 4)}-${group.substring(4, 8)}-'
        '${group.substring(8, 12)}-${group.substring(12, 16)}';
  }

  /// Validate a user-entered code against this device's expected code.
  Future<bool> activate(String code) async {
    final clean = code.trim().toUpperCase();
    final expected = expectedCode();
    if (clean == expected) {
      _activated = true;
      _activatedCode = clean;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefLicenseActivated, true);
      await prefs.setString(AppConstants.prefLicenseKey, clean);
      return true;
    }
    // Also accept a master/global code for development & bulk distribution.
    if (clean == _masterCode()) {
      _activated = true;
      _activatedCode = clean;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefLicenseActivated, true);
      await prefs.setString(AppConstants.prefLicenseKey, clean);
      return true;
    }
    return false;
  }

  /// A single master code that activates any install. Useful for the
  /// author to ship a paid/premium build where every buyer uses the
  /// same code, or for App Store / Play Store purchases where the
  /// purchase receipt itself is the proof of license.
  String _masterCode() {
    final hmac = Hmac(sha256, utf8.encode(_secret));
    final digest = hmac.convert(utf8.encode('global-master-license-2025'));
    final hex = digest.toString().toUpperCase();
    final group = hex.substring(0, 16);
    return '${group.substring(0, 4)}-${group.substring(4, 8)}-'
        '${group.substring(8, 12)}-${group.substring(12, 16)}';
  }

  /// Print the codes — used by a tiny CLI in the project so the author
  /// can issue codes from a laptop.
  void printCodes() {
    // ignore: avoid_print
    print('Device ID: $_deviceId');
    print('Device registration code: ${expectedCode()}');
    print('Master code: ${_masterCode()}');
  }

  Future<void> deactivate() async {
    _activated = false;
    _activatedCode = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefLicenseActivated, false);
    await prefs.remove(AppConstants.prefLicenseKey);
  }
}
