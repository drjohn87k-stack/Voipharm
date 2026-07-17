/// App-wide constants for the Medical Request Voice App.
class AppConstants {
  AppConstants._();

  /// SQLite database file name.
  static const String databaseName = 'medical_request.db';

  /// Current database schema version.
  static const int databaseVersion = 1;

  /// Table: medical items (master list).
  static const String tableMedicalItems = 'medical_items';

  /// Table: requests (header + status).
  static const String tableRequests = 'requests';

  /// Table: request line items.
  static const String tableRequestItems = 'request_items';

  /// Shared-preferences keys.
  static const String prefLocale = 'app_locale';
  static const String prefLicenseKey = 'license_key';
  static const String prefLicenseActivated = 'license_activated';
  static const String prefDeviceId = 'device_id';

  /// Author / copyright info.
  static const String authorName = 'Abdullah Alshwerif';
  static const String authorPhone = '0917156449';
  static const String copyrightYear = '2025';
  static const String appVersion = '1.0.0';

  /// Speech recognition locales.
  static const String localeArabic = 'ar_SA';
  static const String localeEnglish = 'en_US';

  /// Pre-loaded master list asset.
  static const String assetMasterItems = 'assets/seed/master_items.json';
  static const String assetSpeechVocab = 'assets/seed/speech_vocabulary.json';
  static const String assetArabicMap = 'assets/seed/arabic_speech_map.json';
  static const String assetPharmaCompanies = 'assets/seed/pharma_companies.json';
}
