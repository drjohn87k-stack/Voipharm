// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق الطلبات الطبية الصوتي';

  @override
  String get dashboard => 'الرئيسية';

  @override
  String get newRequest => 'طلب جديد';

  @override
  String get browseItems => 'تصفح الأصناف';

  @override
  String get importItems => 'استيراد الأصناف';

  @override
  String get history => 'السجل';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get search => 'بحث';

  @override
  String get searchItems => 'ابحث عن صنف...';

  @override
  String get voiceSearch => 'بحث صوتي';

  @override
  String get listening => 'يستمع...';

  @override
  String get tapToSpeak => 'اضغط للتحدث';

  @override
  String get stopListening => 'إيقاف';

  @override
  String get add => 'إضافة';

  @override
  String get addItem => 'إضافة صنف';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get clear => 'مسح';

  @override
  String get clearAllItemsConfirm => 'إزالة جميع الأصناف من الطلب الحالي؟';

  @override
  String get quantity => 'الكمية';

  @override
  String get notes => 'ملاحظات';

  @override
  String get itemName => 'اسم الصنف';

  @override
  String get category => 'الفئة';

  @override
  String get department => 'القسم';

  @override
  String get requester => 'مقدم الطلب';

  @override
  String get title => 'العنوان';

  @override
  String get signature => 'التوقيع';

  @override
  String get date => 'التاريخ';

  @override
  String get status => 'الحالة';

  @override
  String get statusDraft => 'مسودة';

  @override
  String get statusExported => 'تم التصدير';

  @override
  String get statusSubmitted => 'تم الإرسال';

  @override
  String get requestBuilder => 'منشئ الطلب';

  @override
  String get requestDetails => 'تفاصيل الطلب';

  @override
  String get itemsBrowser => 'تصفح الأصناف';

  @override
  String get items => 'صنف';

  @override
  String get units => 'وحدة';

  @override
  String get export => 'تصدير';

  @override
  String get exportRequest => 'تصدير الطلب';

  @override
  String get exportToWord => 'تصدير إلى وورد (.docx)';

  @override
  String get exportToPdf => 'تصدير إلى PDF';

  @override
  String get typeItemNameOrSpeak => 'اكتب اسم الصنف أو تحدث';

  @override
  String get added => 'تمت الإضافة';

  @override
  String get noItemsAddedYet =>
      'لم تتم إضافة أصناف بعد. استخدم الصوت أو اضغط الميكروفون للإضافة.';

  @override
  String get addByVoice => 'إضافة بالصوت';

  @override
  String get addByVoiceHint => 'اضغط الميكروفون وتحدث باسم الصنف لإضافته.';

  @override
  String get request => 'طلب';

  @override
  String get requestSaved => 'تم حفظ الطلب';

  @override
  String get noItemsFound => 'لم يتم العثور على أصناف';

  @override
  String get noRequestsYet => 'لا توجد طلبات بعد';

  @override
  String get noSavedRequests =>
      'لا توجد طلبات محفوظة بعد. أنشئ طلبًا من المنشئ.';

  @override
  String get emptyItemsMessage =>
      'استورد الأصناف للبدء، أو استخدم القائمة الرئيسية المحملة مسبقًا.';

  @override
  String get emptyRequestsMessage => 'أنشئ طلبك الأول لرؤيته هنا.';

  @override
  String get importTitle => 'استيراد قائمة الأصناف الرئيسية';

  @override
  String get importInstructions =>
      'اختر ملف وورد (.docx) أو إكسل (.xls/.xlsx) أو نص (.txt) يحتوي على أصناف التوريد الطبية. يقوم التطبيق بتحليل أسماء الأصناف وإضافتها إلى قاعدة البيانات.';

  @override
  String get importDescription =>
      'اختر ملف وورد أو إكسل أو نص يحتوي على أصناف التوريد الطبية. يمكنك دمجها مع القائمة الحالية أو استبدالها بالكامل.';

  @override
  String get mergeImport => 'دمج مع القائمة الحالية';

  @override
  String get replaceImport => 'استبدال القائمة بالكامل';

  @override
  String get supportedFormats => 'الصيغ المدعومة';

  @override
  String get formatsList =>
      'وورد (.docx) · نص (.txt) · CSV (.csv) · إكسل (.xls)';

  @override
  String get noFileSelected => 'لم يتم اختيار ملف';

  @override
  String get noItemsFoundInFile => 'لم يتم العثور على أصناف في الملف المحدد.';

  @override
  String get replaced => 'تم الاستبدال';

  @override
  String get merged => 'تم الدمج';

  @override
  String get error => 'خطأ';

  @override
  String get selectFile => 'اختر ملف';

  @override
  String get replaceExisting => 'استبدال جميع الأصناف الموجودة';

  @override
  String get addToExisting => 'إضافة إلى الأصناف الموجودة';

  @override
  String importSuccess(int count) {
    return 'تم استيراد $count صنف بنجاح';
  }

  @override
  String get importError => 'فشل استيراد الملف';

  @override
  String get loadMasterList => 'تحميل القائمة الرئيسية المحملة مسبقًا';

  @override
  String masterListLoaded(int count) {
    return 'تم تحميل $count صنف مسبقًا';
  }

  @override
  String get exportWord => 'تصدير إلى وورد';

  @override
  String get exportPdf => 'تصدير إلى PDF';

  @override
  String get exportSuccess => 'تم التصدير بنجاح. اضغط مشاركة للإرسال.';

  @override
  String get share => 'مشاركة';

  @override
  String get reorderHint => 'استخدم الأسهم لإعادة الترتيب';

  @override
  String get editItem => 'تعديل الصنف';

  @override
  String get deleteItemConfirm => 'إزالة هذا الصنف من الطلب؟';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get voiceQuantity => 'قل رقمًا (مثل \'خمسة\' أو \'five\')';

  @override
  String get voiceNotes => 'اضغط لتسجيل ملاحظات بالصوت';

  @override
  String get resumeEditing => 'استئناف';

  @override
  String get openRequest => 'فتح';

  @override
  String get duplicateRequest => 'نسخ';

  @override
  String get deleteRequestConfirm => 'حذف هذا الطلب نهائيًا؟';

  @override
  String get undated => 'غير مؤرخ';

  @override
  String get refresh => 'تحديث';

  @override
  String get totalItems => 'إجمالي الأصناف';

  @override
  String itemsCount(int count) {
    return '$count صنف';
  }

  @override
  String get appInformation => 'معلومات التطبيق';

  @override
  String get license => 'الترخيص';

  @override
  String get activateLicense => 'تفعيل الترخيص';

  @override
  String get registrationCode => 'رمز التسجيل';

  @override
  String get enterRegistrationCode => 'أدخل رمز التسجيل';

  @override
  String get activate => 'تفعيل';

  @override
  String get licenseInvalid => 'رمز تسجيل غير صالح';

  @override
  String get licenseValid => 'تم تفعيل الترخيص. شكرًا لك!';

  @override
  String get licenseActivated => 'الترخيص مفعّل';

  @override
  String get licenseRequired => 'يتطلب هذا التطبيق رمز تسجيل صالح للعمل.';

  @override
  String get contactSupport => 'الدعم: عبدالله الشويرف - 0917156449';

  @override
  String get copyright => '© 2025 عبدالله الشويرف. جميع الحقوق محفوظة.';

  @override
  String get proprietaryNotice =>
      'برنامج احتكاري. يُمنع النسخ أو التوزيع أو الاستخدام غير المصرح به.';

  @override
  String get about => 'حول';

  @override
  String get version => 'الإصدار';

  @override
  String get ok => 'حسنًا';

  @override
  String get close => 'إغلاق';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get speechNotAvailable => 'التعرف على الصوت غير متوفر على هذا الجهاز';

  @override
  String get speechPermissionDenied => 'تم رفض إذن الميكروفون';

  @override
  String get permissionRequired => 'إذن الميكروفون مطلوب للإدخال الصوتي';

  @override
  String get requestPermission => 'طلب الإذن';

  @override
  String get searchResults => 'نتائج البحث';

  @override
  String get allItems => 'جميع الأصناف';

  @override
  String get recentlyAdded => 'الأصناف المضافة حديثًا';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get scrollForMore => 'مرر للمزيد';

  @override
  String get itemsInDatabase => 'الأصناف في قاعدة البيانات';

  @override
  String get savedRequests => 'الطلبات المحفوظة';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get exportOptions => 'خيارات التصدير';

  @override
  String get previewDocument => 'معاينة';

  @override
  String get enterItemName => 'أدخل اسم الصنف';

  @override
  String get enterQuantity => 'أدخل الكمية';

  @override
  String get enterNotes => 'أدخل الملاحظات';

  @override
  String get manualEntry => 'إدخال يدوي';

  @override
  String get voiceEntry => 'إدخال صوتي';

  @override
  String get switchToArabic => 'تبديل إلى العربية';

  @override
  String get switchToEnglish => 'Switch to English';

  @override
  String get noResults => 'لا نتائج';

  @override
  String get tryDifferentSearch => 'جرّب كلمة بحث مختلفة';

  @override
  String get loadedItems => 'الأصناف المحملة';

  @override
  String get databaseEmpty => 'قاعدة البيانات فارغة';

  @override
  String get tapToLoad => 'اضغط لتحميل القائمة الرئيسية';

  @override
  String get clearSearch => 'مسح';

  @override
  String get addNotes => 'إضافة ملاحظات';

  @override
  String get editNotes => 'تعديل الملاحظات';

  @override
  String get addQuantity => 'تحديد الكمية';

  @override
  String get increase => 'زيادة';

  @override
  String get decrease => 'إنقاص';

  @override
  String get welcome => 'مرحبًا';

  @override
  String get welcomeSubtitle =>
      'أنشئ طلبات التوريد الطبية بالصوت أو الإدخال اليدوي.';

  @override
  String get startNewRequest => 'بدء طلب جديد';

  @override
  String get openHistory => 'فتح السجل';

  @override
  String get openBrowser => 'تصفح الأصناف';

  @override
  String get openImport => 'استيراد الأصناف';

  @override
  String get masterItemsLoaded => 'تم تحميل الأصناف الرئيسية';

  @override
  String get copyrightFooter => '© 2025 عبدالله الشويرف (0917156449)';
}
