import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('fr'),
  ];

  /// No description provided for @apiErrorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue.'**
  String get apiErrorGeneric;

  /// No description provided for @apiErrorNoConnection.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de contacter le serveur. Vérifiez votre connexion.'**
  String get apiErrorNoConnection;

  /// No description provided for @notificationChannelName.
  ///
  /// In fr, this message translates to:
  /// **'Notifications Kuik'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In fr, this message translates to:
  /// **'Correspondances et nouveaux messages'**
  String get notificationChannelDescription;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// No description provided for @statusLost.
  ///
  /// In fr, this message translates to:
  /// **'Perdu'**
  String get statusLost;

  /// No description provided for @statusFound.
  ///
  /// In fr, this message translates to:
  /// **'Trouvé'**
  String get statusFound;

  /// No description provided for @statusLostLong.
  ///
  /// In fr, this message translates to:
  /// **'Objet perdu'**
  String get statusLostLong;

  /// No description provided for @statusFoundLong.
  ///
  /// In fr, this message translates to:
  /// **'Objet trouvé'**
  String get statusFoundLong;

  /// No description provided for @fieldPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get fieldPhoneLabel;

  /// No description provided for @fieldPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get fieldPasswordLabel;

  /// No description provided for @fieldCityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get fieldCityLabel;

  /// No description provided for @fieldCategoryLabel.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get fieldCategoryLabel;

  /// No description provided for @actionLogin.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get actionLogin;

  /// No description provided for @actionRegister.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get actionRegister;

  /// No description provided for @loginGreetingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour'**
  String get loginGreetingTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour retrouver vos annonces.'**
  String get loginSubtitle;

  /// No description provided for @loginNoAccountPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ? '**
  String get loginNoAccountPrompt;

  /// No description provided for @loginRegisterLink.
  ///
  /// In fr, this message translates to:
  /// **'Inscrivez-vous'**
  String get loginRegisterLink;

  /// No description provided for @registerStampLabel.
  ///
  /// In fr, this message translates to:
  /// **'INSCRIT'**
  String get registerStampLabel;

  /// No description provided for @registerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un\ncompte'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez le registre pour déclarer ou retrouver un objet.'**
  String get registerSubtitle;

  /// No description provided for @registerNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get registerNameLabel;

  /// No description provided for @registerHasAccountPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà un compte ? '**
  String get registerHasAccountPrompt;

  /// No description provided for @splashTagline.
  ///
  /// In fr, this message translates to:
  /// **'Objets perdus, retrouvés.'**
  String get splashTagline;

  /// No description provided for @stampVerifiedLabel.
  ///
  /// In fr, this message translates to:
  /// **'VÉRIFIÉ'**
  String get stampVerifiedLabel;

  /// No description provided for @chatAppBarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conversation'**
  String get chatAppBarTitle;

  /// No description provided for @chatLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les messages.'**
  String get chatLoadError;

  /// No description provided for @chatEmptyState.
  ///
  /// In fr, this message translates to:
  /// **'Aucun message pour le moment.'**
  String get chatEmptyState;

  /// No description provided for @chatComposerHint.
  ///
  /// In fr, this message translates to:
  /// **'Écrire un message...'**
  String get chatComposerHint;

  /// No description provided for @conversationsAppBarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conversations'**
  String get conversationsAppBarTitle;

  /// No description provided for @conversationsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les conversations.'**
  String get conversationsLoadError;

  /// No description provided for @conversationsEmptyState.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez encore aucune conversation.'**
  String get conversationsEmptyState;

  /// No description provided for @accueilProfileTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get accueilProfileTooltip;

  /// No description provided for @accueilLogoutMenuItem.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get accueilLogoutMenuItem;

  /// No description provided for @accueilLanguageMenuItem.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get accueilLanguageMenuItem;

  /// No description provided for @accueilGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get accueilGreeting;

  /// No description provided for @accueilSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Retrouvez ce qui compte.'**
  String get accueilSubtitle;

  /// No description provided for @accueilStatObjectsLabel.
  ///
  /// In fr, this message translates to:
  /// **'objets'**
  String get accueilStatObjectsLabel;

  /// No description provided for @accueilStatLostLabel.
  ///
  /// In fr, this message translates to:
  /// **'perdus'**
  String get accueilStatLostLabel;

  /// No description provided for @accueilStatFoundLabel.
  ///
  /// In fr, this message translates to:
  /// **'trouvés'**
  String get accueilStatFoundLabel;

  /// No description provided for @accueilNearbySectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'À proximité'**
  String get accueilNearbySectionTitle;

  /// No description provided for @accueilNearbyLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les annonces à proximité.'**
  String get accueilNearbyLoadError;

  /// No description provided for @accueilNearbyEmptyState.
  ///
  /// In fr, this message translates to:
  /// **'Aucune annonce à proximité pour le moment.'**
  String get accueilNearbyEmptyState;

  /// No description provided for @accueilSearchBarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Que recherchez-vous ?'**
  String get accueilSearchBarTitle;

  /// No description provided for @accueilSearchBarSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Clés, téléphone, sac, portefeuille…'**
  String get accueilSearchBarSubtitle;

  /// No description provided for @accueilDeclareCtaLabel.
  ///
  /// In fr, this message translates to:
  /// **'Déclarer un objet'**
  String get accueilDeclareCtaLabel;

  /// No description provided for @languageDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir la langue'**
  String get languageDialogTitle;

  /// No description provided for @myListingsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger vos annonces.'**
  String get myListingsLoadError;

  /// No description provided for @myListingsEmptyState.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez encore déclaré aucun objet.'**
  String get myListingsEmptyState;

  /// No description provided for @savedListingsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger vos annonces enregistrées.'**
  String get savedListingsLoadError;

  /// No description provided for @savedListingsEmptyState.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez encore enregistré aucune annonce.'**
  String get savedListingsEmptyState;

  /// No description provided for @navHomeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHomeLabel;

  /// No description provided for @navMapLabel.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get navMapLabel;

  /// No description provided for @navMyListingsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mes objets'**
  String get navMyListingsLabel;

  /// No description provided for @navSavedLabel.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrés'**
  String get navSavedLabel;

  /// No description provided for @categoryPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get categoryPhone;

  /// No description provided for @categoryKeys.
  ///
  /// In fr, this message translates to:
  /// **'Clés'**
  String get categoryKeys;

  /// No description provided for @categoryWallet.
  ///
  /// In fr, this message translates to:
  /// **'Portefeuille'**
  String get categoryWallet;

  /// No description provided for @categoryIdPassport.
  ///
  /// In fr, this message translates to:
  /// **'CIN/Passeport'**
  String get categoryIdPassport;

  /// No description provided for @categoryBag.
  ///
  /// In fr, this message translates to:
  /// **'Sac'**
  String get categoryBag;

  /// No description provided for @categoryLuggage.
  ///
  /// In fr, this message translates to:
  /// **'Bagage'**
  String get categoryLuggage;

  /// No description provided for @categoryAnimal.
  ///
  /// In fr, this message translates to:
  /// **'Animal'**
  String get categoryAnimal;

  /// No description provided for @categoryClothing.
  ///
  /// In fr, this message translates to:
  /// **'Vêtement'**
  String get categoryClothing;

  /// No description provided for @categoryElectronics.
  ///
  /// In fr, this message translates to:
  /// **'Électronique'**
  String get categoryElectronics;

  /// No description provided for @categoryOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get categoryOther;

  /// No description provided for @declareSuccessSnackbar.
  ///
  /// In fr, this message translates to:
  /// **'Annonce publiée.'**
  String get declareSuccessSnackbar;

  /// No description provided for @declareAppBarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déclarer un objet'**
  String get declareAppBarTitle;

  /// No description provided for @declareDescriptionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get declareDescriptionLabel;

  /// No description provided for @declarePhotosLabel.
  ///
  /// In fr, this message translates to:
  /// **'Photos (jusqu\'à 3)'**
  String get declarePhotosLabel;

  /// No description provided for @declareNeighborhoodLabel.
  ///
  /// In fr, this message translates to:
  /// **'Quartier (optionnel)'**
  String get declareNeighborhoodLabel;

  /// No description provided for @declareDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date approximative'**
  String get declareDateLabel;

  /// No description provided for @declarePositionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Position'**
  String get declarePositionLabel;

  /// No description provided for @declarePositionImpreciseWarning.
  ///
  /// In fr, this message translates to:
  /// **'Position exacte indisponible (permission refusée ou GPS désactivé) — position par défaut affichée, ajustez-la sur la carte si besoin.'**
  String get declarePositionImpreciseWarning;

  /// No description provided for @declareSubmitButton.
  ///
  /// In fr, this message translates to:
  /// **'Publier l\'annonce'**
  String get declareSubmitButton;

  /// No description provided for @listingsSearchAppBarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get listingsSearchAppBarTitle;

  /// No description provided for @listingsSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un mot-clé...'**
  String get listingsSearchHint;

  /// No description provided for @listingsFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get listingsFilterAll;

  /// No description provided for @listingsFilterCategoryAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get listingsFilterCategoryAll;

  /// No description provided for @listingsOfflineBanner.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne — dernières annonces consultées.'**
  String get listingsOfflineBanner;

  /// No description provided for @listingsEmptyState.
  ///
  /// In fr, this message translates to:
  /// **'Aucune annonce trouvée.'**
  String get listingsEmptyState;

  /// No description provided for @listingDetailNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Annonce introuvable.'**
  String get listingDetailNotFound;

  /// No description provided for @listingDetailClaimFoundButton.
  ///
  /// In fr, this message translates to:
  /// **'Je pense l\'avoir trouvé'**
  String get listingDetailClaimFoundButton;

  /// No description provided for @listingDetailClaimOwnerButton.
  ///
  /// In fr, this message translates to:
  /// **'C\'est mon objet'**
  String get listingDetailClaimOwnerButton;

  /// No description provided for @listingDetailNotYoursPrompt.
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est pas votre objet ? '**
  String get listingDetailNotYoursPrompt;

  /// No description provided for @listingDetailSeeOtherListingsLink.
  ///
  /// In fr, this message translates to:
  /// **'Voir d\'autres annonces'**
  String get listingDetailSeeOtherListingsLink;

  /// No description provided for @listingDetailShareMessage.
  ///
  /// In fr, this message translates to:
  /// **'{status} sur Kuik : {category} — {description} ({location}). Ouvrez l\'app Kuik pour en savoir plus.'**
  String listingDetailShareMessage(
    String status,
    String category,
    String description,
    String location,
  );

  /// No description provided for @listingDetailStatusResolved.
  ///
  /// In fr, this message translates to:
  /// **'Résolue'**
  String get listingDetailStatusResolved;

  /// No description provided for @listingDetailStatusExpired.
  ///
  /// In fr, this message translates to:
  /// **'Expirée'**
  String get listingDetailStatusExpired;

  /// No description provided for @listingDetailInfoSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get listingDetailInfoSectionTitle;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette annonce ?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est définitive et ne peut pas être annulée.'**
  String get deleteConfirmMessage;

  /// No description provided for @deleteCancelButton.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get deleteCancelButton;

  /// No description provided for @deleteConfirmButton.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get deleteConfirmButton;

  /// No description provided for @deleteSuccessSnackbar.
  ///
  /// In fr, this message translates to:
  /// **'Annonce supprimée.'**
  String get deleteSuccessSnackbar;

  /// No description provided for @mapLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger la carte.'**
  String get mapLoadError;

  /// No description provided for @mapImpreciseLocationBanner.
  ///
  /// In fr, this message translates to:
  /// **'Position exacte indisponible — position par défaut (Casablanca) affichée.'**
  String get mapImpreciseLocationBanner;

  /// No description provided for @mapEmptyState.
  ///
  /// In fr, this message translates to:
  /// **'Aucune annonce à proximité.'**
  String get mapEmptyState;

  /// No description provided for @photoPickerTakePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get photoPickerTakePhoto;

  /// No description provided for @photoPickerChooseFromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la galerie'**
  String get photoPickerChooseFromGallery;

  /// No description provided for @matchesAppBarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Suggestions de correspondance'**
  String get matchesAppBarTitle;

  /// No description provided for @matchesLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les suggestions.'**
  String get matchesLoadError;

  /// No description provided for @matchesEmptyState.
  ///
  /// In fr, this message translates to:
  /// **'Aucune suggestion pour le moment.'**
  String get matchesEmptyState;

  /// No description provided for @matchesRejectButton.
  ///
  /// In fr, this message translates to:
  /// **'Rejeter'**
  String get matchesRejectButton;

  /// No description provided for @matchesConfirmButton.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get matchesConfirmButton;

  /// No description provided for @sectionHeaderSeeAllLabel.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get sectionHeaderSeeAllLabel;

  /// No description provided for @claimsAppBarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réclamations'**
  String get claimsAppBarTitle;

  /// No description provided for @claimsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les réclamations.'**
  String get claimsLoadError;

  /// No description provided for @claimsEmptyState.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réclamation en attente.'**
  String get claimsEmptyState;

  /// No description provided for @claimsAcceptButton.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get claimsAcceptButton;

  /// No description provided for @claimsForLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pour :'**
  String get claimsForLabel;

  /// No description provided for @claimSubmitTitle.
  ///
  /// In fr, this message translates to:
  /// **'Décrire ce que vous avez trouvé'**
  String get claimSubmitTitle;

  /// No description provided for @claimSubmitInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Prenez une photo de l\'objet et décrivez-le brièvement. Le propriétaire examinera votre réclamation avant que la conversation ne s\'ouvre.'**
  String get claimSubmitInstructions;

  /// No description provided for @claimSubmitTitleOwner.
  ///
  /// In fr, this message translates to:
  /// **'Prouvez que c\'est votre objet'**
  String get claimSubmitTitleOwner;

  /// No description provided for @claimSubmitInstructionsOwner.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez une photo et une description qui prouvent que cet objet vous appartient. La personne qui l\'a trouvé examinera votre réclamation avant que la conversation ne s\'ouvre.'**
  String get claimSubmitInstructionsOwner;

  /// No description provided for @claimPhotoRequiredLabel.
  ///
  /// In fr, this message translates to:
  /// **'Photo (obligatoire)'**
  String get claimPhotoRequiredLabel;

  /// No description provided for @claimTakePhotoButton.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get claimTakePhotoButton;

  /// No description provided for @claimRetakePhotoButton.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre la photo'**
  String get claimRetakePhotoButton;

  /// No description provided for @claimDescriptionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get claimDescriptionLabel;

  /// No description provided for @claimDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex. trouvé près du parc, coque bleue...'**
  String get claimDescriptionHint;

  /// No description provided for @claimDescriptionHintOwner.
  ///
  /// In fr, this message translates to:
  /// **'Ex. rayure sur le coin gauche, photo du fond d\'écran...'**
  String get claimDescriptionHintOwner;

  /// No description provided for @claimSubmitButton.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la réclamation'**
  String get claimSubmitButton;

  /// No description provided for @claimSubmitSuccessSnackbar.
  ///
  /// In fr, this message translates to:
  /// **'Réclamation envoyée. Le propriétaire va l\'examiner.'**
  String get claimSubmitSuccessSnackbar;

  /// No description provided for @claimPhotoMissingError.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez une photo avant d\'envoyer.'**
  String get claimPhotoMissingError;
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
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
