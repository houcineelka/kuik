// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get apiErrorGeneric => 'حدث خطأ ما.';

  @override
  String get apiErrorNoConnection =>
      'تعذر الاتصال بالخادم. تحقق من اتصالك بالإنترنت.';

  @override
  String get notificationChannelName => 'إشعارات Kuik';

  @override
  String get notificationChannelDescription => 'التطابقات والرسائل الجديدة';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get statusLost => 'مفقود';

  @override
  String get statusFound => 'موجود';

  @override
  String get statusLostLong => 'غرض مفقود';

  @override
  String get statusFoundLong => 'غرض موجود';

  @override
  String get fieldPhoneLabel => 'الهاتف';

  @override
  String get fieldPasswordLabel => 'كلمة المرور';

  @override
  String get fieldCityLabel => 'المدينة';

  @override
  String get fieldCategoryLabel => 'الفئة';

  @override
  String get actionLogin => 'تسجيل الدخول';

  @override
  String get actionRegister => 'إنشاء حساب';

  @override
  String get loginGreetingTitle => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول للعثور على إعلاناتك.';

  @override
  String get loginNoAccountPrompt => 'ليس لديك حساب بعد؟ ';

  @override
  String get loginRegisterLink => 'أنشئ حسابًا';

  @override
  String get registerStampLabel => 'مسجَّل';

  @override
  String get registerTitle => 'إنشاء\nحساب';

  @override
  String get registerSubtitle =>
      'انضم إلى السجل للإبلاغ عن غرض أو العثور عليه.';

  @override
  String get registerNameLabel => 'الاسم الكامل';

  @override
  String get registerHasAccountPrompt => 'لديك حساب بالفعل؟ ';

  @override
  String get splashTagline => 'أغراض مفقودة، تم العثور عليها.';

  @override
  String get stampVerifiedLabel => 'موثّق';

  @override
  String get chatAppBarTitle => 'المحادثة';

  @override
  String get chatLoadError => 'تعذر تحميل الرسائل.';

  @override
  String get chatEmptyState => 'لا توجد رسائل بعد.';

  @override
  String get chatComposerHint => 'اكتب رسالة...';

  @override
  String get conversationsAppBarTitle => 'المحادثات';

  @override
  String get conversationsLoadError => 'تعذر تحميل المحادثات.';

  @override
  String get conversationsEmptyState => 'ليس لديك أي محادثة بعد.';

  @override
  String get accueilProfileTooltip => 'الملف الشخصي';

  @override
  String get accueilLogoutMenuItem => 'تسجيل الخروج';

  @override
  String get accueilLanguageMenuItem => 'اللغة';

  @override
  String get accueilGreeting => 'مرحبًا';

  @override
  String get accueilSubtitle => 'استعد ما يهمك.';

  @override
  String get accueilStatObjectsLabel => 'أغراض';

  @override
  String get accueilStatLostLabel => 'مفقودة';

  @override
  String get accueilStatFoundLabel => 'موجودة';

  @override
  String get accueilNearbySectionTitle => 'بالقرب منك';

  @override
  String get accueilNearbyLoadError => 'تعذر تحميل الإعلانات القريبة.';

  @override
  String get accueilNearbyEmptyState => 'لا توجد إعلانات قريبة حاليًا.';

  @override
  String get accueilSearchBarTitle => 'عن ماذا تبحث؟';

  @override
  String get accueilSearchBarSubtitle => 'مفاتيح، هاتف، حقيبة، محفظة…';

  @override
  String get accueilDeclareCtaLabel => 'الإبلاغ عن غرض';

  @override
  String get languageDialogTitle => 'اختر اللغة';

  @override
  String get myListingsLoadError => 'تعذر تحميل إعلاناتك.';

  @override
  String get myListingsEmptyState => 'لم تُبلغ عن أي غرض بعد.';

  @override
  String get savedListingsLoadError => 'تعذر تحميل الإعلانات المحفوظة.';

  @override
  String get savedListingsEmptyState => 'لم تحفظ أي إعلان بعد.';

  @override
  String get navHomeLabel => 'الرئيسية';

  @override
  String get navMapLabel => 'الخريطة';

  @override
  String get navMyListingsLabel => 'أغراضي';

  @override
  String get navSavedLabel => 'المحفوظات';

  @override
  String get categoryPhone => 'هاتف';

  @override
  String get categoryKeys => 'مفاتيح';

  @override
  String get categoryWallet => 'محفظة';

  @override
  String get categoryIdPassport => 'بطاقة التعريف/جواز السفر';

  @override
  String get categoryBag => 'حقيبة';

  @override
  String get categoryLuggage => 'أمتعة';

  @override
  String get categoryAnimal => 'حيوان';

  @override
  String get categoryClothing => 'ملابس';

  @override
  String get categoryElectronics => 'إلكترونيات';

  @override
  String get categoryOther => 'أخرى';

  @override
  String get declareSuccessSnackbar => 'تم نشر الإعلان.';

  @override
  String get declareAppBarTitle => 'الإبلاغ عن غرض';

  @override
  String get declareDescriptionLabel => 'الوصف';

  @override
  String get declarePhotosLabel => 'صور (حتى 3)';

  @override
  String get declareNeighborhoodLabel => 'الحي (اختياري)';

  @override
  String get declareDateLabel => 'التاريخ التقريبي';

  @override
  String get declarePositionLabel => 'الموقع';

  @override
  String get declarePositionImpreciseWarning =>
      'الموقع الدقيق غير متوفر (تم رفض الإذن أو تعطيل GPS) — يتم عرض موقع افتراضي، يمكنك تعديله على الخريطة عند الحاجة.';

  @override
  String get declareSubmitButton => 'نشر الإعلان';

  @override
  String get listingsSearchAppBarTitle => 'بحث';

  @override
  String get listingsSearchHint => 'ابحث عن كلمة مفتاحية...';

  @override
  String get listingsFilterAll => 'الكل';

  @override
  String get listingsFilterCategoryAll => 'الكل';

  @override
  String get listingsOfflineBanner =>
      'غير متصل — آخر الإعلانات التي تم الاطلاع عليها.';

  @override
  String get listingsEmptyState => 'لم يتم العثور على أي إعلان.';

  @override
  String get listingDetailNotFound => 'الإعلان غير موجود.';

  @override
  String get listingDetailClaimFoundButton => 'أعتقد أنني وجدته';

  @override
  String get listingDetailClaimOwnerButton => 'هذا غرضي';

  @override
  String get listingDetailNotYoursPrompt => 'هذا ليس غرضك؟ ';

  @override
  String get listingDetailSeeOtherListingsLink => 'عرض إعلانات أخرى';

  @override
  String listingDetailShareMessage(
    String status,
    String category,
    String description,
    String location,
  ) {
    return '$status على Kuik: $category — $description ($location). افتح تطبيق Kuik لمعرفة المزيد.';
  }

  @override
  String get listingDetailStatusResolved => 'محلولة';

  @override
  String get listingDetailStatusExpired => 'منتهية';

  @override
  String get listingDetailInfoSectionTitle => 'معلومات';

  @override
  String get deleteConfirmTitle => 'هل تريد حذف هذا الإعلان؟';

  @override
  String get deleteConfirmMessage => 'هذا الإجراء نهائي ولا يمكن التراجع عنه.';

  @override
  String get deleteCancelButton => 'إلغاء';

  @override
  String get deleteConfirmButton => 'حذف';

  @override
  String get deleteSuccessSnackbar => 'تم حذف الإعلان.';

  @override
  String get mapLoadError => 'تعذر تحميل الخريطة.';

  @override
  String get mapImpreciseLocationBanner =>
      'الموقع الدقيق غير متوفر — يتم عرض الموقع الافتراضي (الدار البيضاء).';

  @override
  String get mapEmptyState => 'لا توجد إعلانات قريبة.';

  @override
  String get photoPickerTakePhoto => 'التقاط صورة';

  @override
  String get photoPickerChooseFromGallery => 'اختيار من المعرض';

  @override
  String get matchesAppBarTitle => 'اقتراحات التطابق';

  @override
  String get matchesLoadError => 'تعذر تحميل الاقتراحات.';

  @override
  String get matchesEmptyState => 'لا توجد اقتراحات حاليًا.';

  @override
  String get matchesRejectButton => 'رفض';

  @override
  String get matchesConfirmButton => 'تأكيد';

  @override
  String get sectionHeaderSeeAllLabel => 'عرض الكل';

  @override
  String get claimsAppBarTitle => 'المطالبات';

  @override
  String get claimsLoadError => 'تعذر تحميل المطالبات.';

  @override
  String get claimsEmptyState => 'لا توجد مطالبات معلقة.';

  @override
  String get claimsAcceptButton => 'قبول';

  @override
  String get claimsForLabel => 'بخصوص:';

  @override
  String get claimSubmitTitle => 'صف ما وجدته';

  @override
  String get claimSubmitInstructions =>
      'التقط صورة للغرض وصفه باختصار. سيراجع المالك مطالبتك قبل فتح المحادثة.';

  @override
  String get claimSubmitTitleOwner => 'أثبت أن هذا الغرض ملكك';

  @override
  String get claimSubmitInstructionsOwner =>
      'أرسل صورة ووصفًا يثبتان أن هذا الغرض ملكك. سيراجع الشخص الذي وجده مطالبتك قبل فتح المحادثة.';

  @override
  String get claimPhotoRequiredLabel => 'صورة (إلزامية)';

  @override
  String get claimTakePhotoButton => 'التقاط صورة';

  @override
  String get claimRetakePhotoButton => 'إعادة التقاط الصورة';

  @override
  String get claimDescriptionLabel => 'الوصف';

  @override
  String get claimDescriptionHint =>
      'مثال: وُجد بالقرب من الحديقة، غطاء أزرق...';

  @override
  String get claimDescriptionHintOwner =>
      'مثال: خدش في الزاوية اليسرى، صورة لخلفية الشاشة...';

  @override
  String get claimSubmitButton => 'إرسال المطالبة';

  @override
  String get claimSubmitSuccessSnackbar =>
      'تم إرسال المطالبة. سيقوم المالك بمراجعتها.';

  @override
  String get claimPhotoMissingError => 'أضف صورة قبل الإرسال.';
}
