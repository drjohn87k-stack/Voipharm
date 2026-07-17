// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Medical Request Voice App';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get newRequest => 'New Request';

  @override
  String get browseItems => 'Browse Items';

  @override
  String get importItems => 'Import Items';

  @override
  String get history => 'History';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get search => 'Search';

  @override
  String get searchItems => 'Search items...';

  @override
  String get voiceSearch => 'Voice Search';

  @override
  String get listening => 'Listening...';

  @override
  String get tapToSpeak => 'Tap to speak';

  @override
  String get stopListening => 'Stop';

  @override
  String get add => 'Add';

  @override
  String get addItem => 'Add Item';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get clear => 'Clear';

  @override
  String get clearAllItemsConfirm =>
      'Remove all items from the current request?';

  @override
  String get quantity => 'Quantity';

  @override
  String get notes => 'Notes';

  @override
  String get itemName => 'Item Name';

  @override
  String get category => 'Category';

  @override
  String get department => 'Department';

  @override
  String get requester => 'Requester';

  @override
  String get title => 'Title';

  @override
  String get signature => 'Signature';

  @override
  String get date => 'Date';

  @override
  String get status => 'Status';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusExported => 'Exported';

  @override
  String get statusSubmitted => 'Submitted';

  @override
  String get requestBuilder => 'Request Builder';

  @override
  String get requestDetails => 'Request Details';

  @override
  String get itemsBrowser => 'Items Browser';

  @override
  String get items => 'items';

  @override
  String get units => 'units';

  @override
  String get export => 'Export';

  @override
  String get exportRequest => 'Export Request';

  @override
  String get exportToWord => 'Export to Word (.docx)';

  @override
  String get exportToPdf => 'Export to PDF';

  @override
  String get typeItemNameOrSpeak => 'Type item name or speak';

  @override
  String get added => 'Added';

  @override
  String get noItemsAddedYet =>
      'No items added yet. Use voice or tap the mic to add.';

  @override
  String get addByVoice => 'Add by Voice';

  @override
  String get addByVoiceHint => 'Tap the mic and speak an item name to add it.';

  @override
  String get request => 'Request';

  @override
  String get requestSaved => 'Request saved';

  @override
  String get noItemsFound => 'No items found';

  @override
  String get noRequestsYet => 'No requests yet';

  @override
  String get noSavedRequests =>
      'No saved requests yet. Create one from the builder.';

  @override
  String get emptyItemsMessage =>
      'Import items to get started, or use the pre-loaded master list.';

  @override
  String get emptyRequestsMessage =>
      'Create your first request to see it here.';

  @override
  String get importTitle => 'Import Master Item List';

  @override
  String get importInstructions =>
      'Select a Word (.docx), Excel (.xls/.xlsx) or text (.txt) file containing medical supply items. The app parses item names and adds them to the database.';

  @override
  String get importDescription =>
      'Pick a Word, Excel, or text file containing medical supply items. You can merge them into the existing list or replace it entirely.';

  @override
  String get mergeImport => 'Merge into existing list';

  @override
  String get replaceImport => 'Replace entire list';

  @override
  String get supportedFormats => 'Supported formats';

  @override
  String get formatsList =>
      'Word (.docx) · Text (.txt) · CSV (.csv) · Excel (.xls)';

  @override
  String get noFileSelected => 'No file selected';

  @override
  String get noItemsFoundInFile => 'No items found in the selected file.';

  @override
  String get replaced => 'Replaced';

  @override
  String get merged => 'Merged';

  @override
  String get error => 'Error';

  @override
  String get selectFile => 'Select File';

  @override
  String get replaceExisting => 'Replace all existing items';

  @override
  String get addToExisting => 'Add to existing items';

  @override
  String importSuccess(int count) {
    return 'Imported $count items successfully';
  }

  @override
  String get importError => 'Failed to import file';

  @override
  String get loadMasterList => 'Load Pre-loaded Master List';

  @override
  String masterListLoaded(int count) {
    return 'Loaded $count pre-loaded items';
  }

  @override
  String get exportWord => 'Export to Word';

  @override
  String get exportPdf => 'Export to PDF';

  @override
  String get exportSuccess => 'Exported successfully. Tap share to send.';

  @override
  String get share => 'Share';

  @override
  String get reorderHint => 'Use the arrows to reorder';

  @override
  String get editItem => 'Edit Item';

  @override
  String get deleteItemConfirm => 'Remove this item from the request?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get voiceQuantity => 'Say a number (e.g. \'five\' or \'خمسة\')';

  @override
  String get voiceNotes => 'Tap to record notes by voice';

  @override
  String get resumeEditing => 'Resume';

  @override
  String get openRequest => 'Open';

  @override
  String get duplicateRequest => 'Duplicate';

  @override
  String get deleteRequestConfirm => 'Delete this request permanently?';

  @override
  String get undated => 'Undated';

  @override
  String get refresh => 'Refresh';

  @override
  String get totalItems => 'Total items';

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String get appInformation => 'App Information';

  @override
  String get license => 'License';

  @override
  String get activateLicense => 'Activate License';

  @override
  String get registrationCode => 'Registration Code';

  @override
  String get enterRegistrationCode => 'Enter registration code';

  @override
  String get activate => 'Activate';

  @override
  String get licenseInvalid => 'Invalid registration code';

  @override
  String get licenseValid => 'License activated. Thank you!';

  @override
  String get licenseActivated => 'License Activated';

  @override
  String get licenseRequired =>
      'This app requires a valid registration code to function.';

  @override
  String get contactSupport =>
      'Contact support: Abdullah Alshwerif - 0917156449';

  @override
  String get copyright => '© 2025 Abdullah Alshwerif. All rights reserved.';

  @override
  String get proprietaryNotice =>
      'Proprietary software. Unauthorized copying, distribution, or use is prohibited.';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get speechNotAvailable =>
      'Speech recognition not available on this device';

  @override
  String get speechPermissionDenied => 'Microphone permission denied';

  @override
  String get permissionRequired =>
      'Microphone permission is required for voice input';

  @override
  String get requestPermission => 'Request Permission';

  @override
  String get searchResults => 'Search results';

  @override
  String get allItems => 'All items';

  @override
  String get recentlyAdded => 'Recently added items';

  @override
  String get viewAll => 'View all';

  @override
  String get scrollForMore => 'Scroll for more';

  @override
  String get itemsInDatabase => 'Items in database';

  @override
  String get savedRequests => 'Saved requests';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get exportOptions => 'Export Options';

  @override
  String get previewDocument => 'Preview';

  @override
  String get enterItemName => 'Enter item name';

  @override
  String get enterQuantity => 'Enter quantity';

  @override
  String get enterNotes => 'Enter notes';

  @override
  String get manualEntry => 'Manual entry';

  @override
  String get voiceEntry => 'Voice entry';

  @override
  String get switchToArabic => 'تبديل إلى العربية';

  @override
  String get switchToEnglish => 'Switch to English';

  @override
  String get noResults => 'No results';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get loadedItems => 'Loaded items';

  @override
  String get databaseEmpty => 'Database is empty';

  @override
  String get tapToLoad => 'Tap to load the master list';

  @override
  String get clearSearch => 'Clear';

  @override
  String get addNotes => 'Add notes';

  @override
  String get editNotes => 'Edit notes';

  @override
  String get addQuantity => 'Set quantity';

  @override
  String get increase => 'Increase';

  @override
  String get decrease => 'Decrease';

  @override
  String get welcome => 'Welcome';

  @override
  String get welcomeSubtitle =>
      'Create medical supply requests by voice or manual entry.';

  @override
  String get startNewRequest => 'Start New Request';

  @override
  String get openHistory => 'Open History';

  @override
  String get openBrowser => 'Browse Items';

  @override
  String get openImport => 'Import Items';

  @override
  String get masterItemsLoaded => 'Master items loaded';

  @override
  String get copyrightFooter => '© 2025 Abdullah Alshwerif (0917156449)';
}
