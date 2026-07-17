import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Request Voice App'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get newRequest;

  /// No description provided for @browseItems.
  ///
  /// In en, this message translates to:
  /// **'Browse Items'**
  String get browseItems;

  /// No description provided for @importItems.
  ///
  /// In en, this message translates to:
  /// **'Import Items'**
  String get importItems;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchItems.
  ///
  /// In en, this message translates to:
  /// **'Search items...'**
  String get searchItems;

  /// No description provided for @voiceSearch.
  ///
  /// In en, this message translates to:
  /// **'Voice Search'**
  String get voiceSearch;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @tapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get tapToSpeak;

  /// No description provided for @stopListening.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopListening;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearAllItemsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove all items from the current request?'**
  String get clearAllItemsConfirm;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @requester.
  ///
  /// In en, this message translates to:
  /// **'Requester'**
  String get requester;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @signature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signature;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusExported.
  ///
  /// In en, this message translates to:
  /// **'Exported'**
  String get statusExported;

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// No description provided for @requestBuilder.
  ///
  /// In en, this message translates to:
  /// **'Request Builder'**
  String get requestBuilder;

  /// No description provided for @requestDetails.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get requestDetails;

  /// No description provided for @itemsBrowser.
  ///
  /// In en, this message translates to:
  /// **'Items Browser'**
  String get itemsBrowser;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get units;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportRequest.
  ///
  /// In en, this message translates to:
  /// **'Export Request'**
  String get exportRequest;

  /// No description provided for @exportToWord.
  ///
  /// In en, this message translates to:
  /// **'Export to Word (.docx)'**
  String get exportToWord;

  /// No description provided for @exportToPdf.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get exportToPdf;

  /// No description provided for @typeItemNameOrSpeak.
  ///
  /// In en, this message translates to:
  /// **'Type item name or speak'**
  String get typeItemNameOrSpeak;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @noItemsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No items added yet. Use voice or tap the mic to add.'**
  String get noItemsAddedYet;

  /// No description provided for @addByVoice.
  ///
  /// In en, this message translates to:
  /// **'Add by Voice'**
  String get addByVoice;

  /// No description provided for @addByVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the mic and speak an item name to add it.'**
  String get addByVoiceHint;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @requestSaved.
  ///
  /// In en, this message translates to:
  /// **'Request saved'**
  String get requestSaved;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @noRequestsYet.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get noRequestsYet;

  /// No description provided for @noSavedRequests.
  ///
  /// In en, this message translates to:
  /// **'No saved requests yet. Create one from the builder.'**
  String get noSavedRequests;

  /// No description provided for @emptyItemsMessage.
  ///
  /// In en, this message translates to:
  /// **'Import items to get started, or use the pre-loaded master list.'**
  String get emptyItemsMessage;

  /// No description provided for @emptyRequestsMessage.
  ///
  /// In en, this message translates to:
  /// **'Create your first request to see it here.'**
  String get emptyRequestsMessage;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Master Item List'**
  String get importTitle;

  /// No description provided for @importInstructions.
  ///
  /// In en, this message translates to:
  /// **'Select a Word (.docx), Excel (.xls/.xlsx) or text (.txt) file containing medical supply items. The app parses item names and adds them to the database.'**
  String get importInstructions;

  /// No description provided for @importDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick a Word, Excel, or text file containing medical supply items. You can merge them into the existing list or replace it entirely.'**
  String get importDescription;

  /// No description provided for @mergeImport.
  ///
  /// In en, this message translates to:
  /// **'Merge into existing list'**
  String get mergeImport;

  /// No description provided for @replaceImport.
  ///
  /// In en, this message translates to:
  /// **'Replace entire list'**
  String get replaceImport;

  /// No description provided for @supportedFormats.
  ///
  /// In en, this message translates to:
  /// **'Supported formats'**
  String get supportedFormats;

  /// No description provided for @formatsList.
  ///
  /// In en, this message translates to:
  /// **'Word (.docx) · Text (.txt) · CSV (.csv) · Excel (.xls)'**
  String get formatsList;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// No description provided for @noItemsFoundInFile.
  ///
  /// In en, this message translates to:
  /// **'No items found in the selected file.'**
  String get noItemsFoundInFile;

  /// No description provided for @replaced.
  ///
  /// In en, this message translates to:
  /// **'Replaced'**
  String get replaced;

  /// No description provided for @merged.
  ///
  /// In en, this message translates to:
  /// **'Merged'**
  String get merged;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No description provided for @replaceExisting.
  ///
  /// In en, this message translates to:
  /// **'Replace all existing items'**
  String get replaceExisting;

  /// No description provided for @addToExisting.
  ///
  /// In en, this message translates to:
  /// **'Add to existing items'**
  String get addToExisting;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} items successfully'**
  String importSuccess(int count);

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Failed to import file'**
  String get importError;

  /// No description provided for @loadMasterList.
  ///
  /// In en, this message translates to:
  /// **'Load Pre-loaded Master List'**
  String get loadMasterList;

  /// No description provided for @masterListLoaded.
  ///
  /// In en, this message translates to:
  /// **'Loaded {count} pre-loaded items'**
  String masterListLoaded(int count);

  /// No description provided for @exportWord.
  ///
  /// In en, this message translates to:
  /// **'Export to Word'**
  String get exportWord;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get exportPdf;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Exported successfully. Tap share to send.'**
  String get exportSuccess;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @reorderHint.
  ///
  /// In en, this message translates to:
  /// **'Use the arrows to reorder'**
  String get reorderHint;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @deleteItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this item from the request?'**
  String get deleteItemConfirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @voiceQuantity.
  ///
  /// In en, this message translates to:
  /// **'Say a number (e.g. \'five\' or \'خمسة\')'**
  String get voiceQuantity;

  /// No description provided for @voiceNotes.
  ///
  /// In en, this message translates to:
  /// **'Tap to record notes by voice'**
  String get voiceNotes;

  /// No description provided for @resumeEditing.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeEditing;

  /// No description provided for @openRequest.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openRequest;

  /// No description provided for @duplicateRequest.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicateRequest;

  /// No description provided for @deleteRequestConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this request permanently?'**
  String get deleteRequestConfirm;

  /// No description provided for @undated.
  ///
  /// In en, this message translates to:
  /// **'Undated'**
  String get undated;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total items'**
  String get totalItems;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(int count);

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInformation;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @activateLicense.
  ///
  /// In en, this message translates to:
  /// **'Activate License'**
  String get activateLicense;

  /// No description provided for @registrationCode.
  ///
  /// In en, this message translates to:
  /// **'Registration Code'**
  String get registrationCode;

  /// No description provided for @enterRegistrationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter registration code'**
  String get enterRegistrationCode;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @licenseInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid registration code'**
  String get licenseInvalid;

  /// No description provided for @licenseValid.
  ///
  /// In en, this message translates to:
  /// **'License activated. Thank you!'**
  String get licenseValid;

  /// No description provided for @licenseActivated.
  ///
  /// In en, this message translates to:
  /// **'License Activated'**
  String get licenseActivated;

  /// No description provided for @licenseRequired.
  ///
  /// In en, this message translates to:
  /// **'This app requires a valid registration code to function.'**
  String get licenseRequired;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support: Abdullah Alshwerif - 0917156449'**
  String get contactSupport;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2025 Abdullah Alshwerif. All rights reserved.'**
  String get copyright;

  /// No description provided for @proprietaryNotice.
  ///
  /// In en, this message translates to:
  /// **'Proprietary software. Unauthorized copying, distribution, or use is prohibited.'**
  String get proprietaryNotice;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @speechNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition not available on this device'**
  String get speechNotAvailable;

  /// No description provided for @speechPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get speechPermissionDenied;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required for voice input'**
  String get permissionRequired;

  /// No description provided for @requestPermission.
  ///
  /// In en, this message translates to:
  /// **'Request Permission'**
  String get requestPermission;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResults;

  /// No description provided for @allItems.
  ///
  /// In en, this message translates to:
  /// **'All items'**
  String get allItems;

  /// No description provided for @recentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added items'**
  String get recentlyAdded;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @scrollForMore.
  ///
  /// In en, this message translates to:
  /// **'Scroll for more'**
  String get scrollForMore;

  /// No description provided for @itemsInDatabase.
  ///
  /// In en, this message translates to:
  /// **'Items in database'**
  String get itemsInDatabase;

  /// No description provided for @savedRequests.
  ///
  /// In en, this message translates to:
  /// **'Saved requests'**
  String get savedRequests;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @exportOptions.
  ///
  /// In en, this message translates to:
  /// **'Export Options'**
  String get exportOptions;

  /// No description provided for @previewDocument.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewDocument;

  /// No description provided for @enterItemName.
  ///
  /// In en, this message translates to:
  /// **'Enter item name'**
  String get enterItemName;

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get enterQuantity;

  /// No description provided for @enterNotes.
  ///
  /// In en, this message translates to:
  /// **'Enter notes'**
  String get enterNotes;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual entry'**
  String get manualEntry;

  /// No description provided for @voiceEntry.
  ///
  /// In en, this message translates to:
  /// **'Voice entry'**
  String get voiceEntry;

  /// No description provided for @switchToArabic.
  ///
  /// In en, this message translates to:
  /// **'تبديل إلى العربية'**
  String get switchToArabic;

  /// No description provided for @switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Switch to English'**
  String get switchToEnglish;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @loadedItems.
  ///
  /// In en, this message translates to:
  /// **'Loaded items'**
  String get loadedItems;

  /// No description provided for @databaseEmpty.
  ///
  /// In en, this message translates to:
  /// **'Database is empty'**
  String get databaseEmpty;

  /// No description provided for @tapToLoad.
  ///
  /// In en, this message translates to:
  /// **'Tap to load the master list'**
  String get tapToLoad;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearSearch;

  /// No description provided for @addNotes.
  ///
  /// In en, this message translates to:
  /// **'Add notes'**
  String get addNotes;

  /// No description provided for @editNotes.
  ///
  /// In en, this message translates to:
  /// **'Edit notes'**
  String get editNotes;

  /// No description provided for @addQuantity.
  ///
  /// In en, this message translates to:
  /// **'Set quantity'**
  String get addQuantity;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create medical supply requests by voice or manual entry.'**
  String get welcomeSubtitle;

  /// No description provided for @startNewRequest.
  ///
  /// In en, this message translates to:
  /// **'Start New Request'**
  String get startNewRequest;

  /// No description provided for @openHistory.
  ///
  /// In en, this message translates to:
  /// **'Open History'**
  String get openHistory;

  /// No description provided for @openBrowser.
  ///
  /// In en, this message translates to:
  /// **'Browse Items'**
  String get openBrowser;

  /// No description provided for @openImport.
  ///
  /// In en, this message translates to:
  /// **'Import Items'**
  String get openImport;

  /// No description provided for @masterItemsLoaded.
  ///
  /// In en, this message translates to:
  /// **'Master items loaded'**
  String get masterItemsLoaded;

  /// No description provided for @copyrightFooter.
  ///
  /// In en, this message translates to:
  /// **'© 2025 Abdullah Alshwerif (0917156449)'**
  String get copyrightFooter;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
