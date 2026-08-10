// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get apiErrorGeneric => 'Une erreur est survenue.';

  @override
  String get apiErrorNoConnection =>
      'Impossible de contacter le serveur. Vérifiez votre connexion.';

  @override
  String get notificationChannelName => 'Notifications Kuik';

  @override
  String get notificationChannelDescription =>
      'Correspondances et nouveaux messages';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get statusLost => 'Perdu';

  @override
  String get statusFound => 'Trouvé';

  @override
  String get statusLostLong => 'Objet perdu';

  @override
  String get statusFoundLong => 'Objet trouvé';

  @override
  String get fieldPhoneLabel => 'Téléphone';

  @override
  String get fieldPasswordLabel => 'Mot de passe';

  @override
  String get fieldCityLabel => 'Ville';

  @override
  String get fieldCategoryLabel => 'Catégorie';

  @override
  String get actionLogin => 'Se connecter';

  @override
  String get actionRegister => 'S\'inscrire';

  @override
  String get loginGreetingTitle => 'Bon retour';

  @override
  String get loginSubtitle => 'Connectez-vous pour retrouver vos annonces.';

  @override
  String get loginNoAccountPrompt => 'Pas encore de compte ? ';

  @override
  String get loginRegisterLink => 'Inscrivez-vous';

  @override
  String get registerStampLabel => 'INSCRIT';

  @override
  String get registerTitle => 'Créer un\ncompte';

  @override
  String get registerSubtitle =>
      'Rejoignez le registre pour déclarer ou retrouver un objet.';

  @override
  String get registerNameLabel => 'Nom complet';

  @override
  String get registerHasAccountPrompt => 'Vous avez déjà un compte ? ';

  @override
  String get splashTagline => 'Objets perdus, retrouvés.';

  @override
  String get stampVerifiedLabel => 'VÉRIFIÉ';

  @override
  String get chatAppBarTitle => 'Conversation';

  @override
  String get chatLoadError => 'Impossible de charger les messages.';

  @override
  String get chatEmptyState => 'Aucun message pour le moment.';

  @override
  String get chatComposerHint => 'Écrire un message...';

  @override
  String get conversationsAppBarTitle => 'Conversations';

  @override
  String get conversationsLoadError =>
      'Impossible de charger les conversations.';

  @override
  String get conversationsEmptyState =>
      'Vous n\'avez encore aucune conversation.';

  @override
  String get accueilProfileTooltip => 'Profil';

  @override
  String get accueilLogoutMenuItem => 'Déconnexion';

  @override
  String get accueilLanguageMenuItem => 'Langue';

  @override
  String get accueilGreeting => 'Bonjour';

  @override
  String get accueilSubtitle => 'Retrouvez ce qui compte.';

  @override
  String get accueilStatObjectsLabel => 'objets';

  @override
  String get accueilStatLostLabel => 'perdus';

  @override
  String get accueilStatFoundLabel => 'trouvés';

  @override
  String get accueilNearbySectionTitle => 'À proximité';

  @override
  String get accueilNearbyLoadError =>
      'Impossible de charger les annonces à proximité.';

  @override
  String get accueilNearbyEmptyState =>
      'Aucune annonce à proximité pour le moment.';

  @override
  String get accueilSearchBarTitle => 'Que recherchez-vous ?';

  @override
  String get accueilSearchBarSubtitle => 'Clés, téléphone, sac, portefeuille…';

  @override
  String get accueilDeclareCtaLabel => 'Déclarer un objet';

  @override
  String get languageDialogTitle => 'Choisir la langue';

  @override
  String get myListingsLoadError => 'Impossible de charger vos annonces.';

  @override
  String get myListingsEmptyState => 'Vous n\'avez encore déclaré aucun objet.';

  @override
  String get savedListingsLoadError =>
      'Impossible de charger vos annonces enregistrées.';

  @override
  String get savedListingsEmptyState =>
      'Vous n\'avez encore enregistré aucune annonce.';

  @override
  String get navHomeLabel => 'Accueil';

  @override
  String get navMapLabel => 'Carte';

  @override
  String get navMyListingsLabel => 'Mes objets';

  @override
  String get navSavedLabel => 'Enregistrés';

  @override
  String get categoryPhone => 'Téléphone';

  @override
  String get categoryKeys => 'Clés';

  @override
  String get categoryWallet => 'Portefeuille';

  @override
  String get categoryIdPassport => 'CIN/Passeport';

  @override
  String get categoryBag => 'Sac';

  @override
  String get categoryLuggage => 'Bagage';

  @override
  String get categoryAnimal => 'Animal';

  @override
  String get categoryClothing => 'Vêtement';

  @override
  String get categoryElectronics => 'Électronique';

  @override
  String get categoryOther => 'Autre';

  @override
  String get declareSuccessSnackbar => 'Annonce publiée.';

  @override
  String get declareAppBarTitle => 'Déclarer un objet';

  @override
  String get declareDescriptionLabel => 'Description';

  @override
  String get declarePhotosLabel => 'Photos (jusqu\'à 3)';

  @override
  String get declareNeighborhoodLabel => 'Quartier (optionnel)';

  @override
  String get declareDateLabel => 'Date approximative';

  @override
  String get declarePositionLabel => 'Position';

  @override
  String get declarePositionImpreciseWarning =>
      'Position exacte indisponible (permission refusée ou GPS désactivé) — position par défaut affichée, ajustez-la sur la carte si besoin.';

  @override
  String get declareSubmitButton => 'Publier l\'annonce';

  @override
  String get listingsSearchAppBarTitle => 'Rechercher';

  @override
  String get listingsSearchHint => 'Rechercher un mot-clé...';

  @override
  String get listingsFilterAll => 'Tous';

  @override
  String get listingsFilterCategoryAll => 'Toutes';

  @override
  String get listingsOfflineBanner =>
      'Hors ligne — dernières annonces consultées.';

  @override
  String get listingsEmptyState => 'Aucune annonce trouvée.';

  @override
  String get listingDetailNotFound => 'Annonce introuvable.';

  @override
  String get listingDetailClaimFoundButton => 'Je pense l\'avoir trouvé';

  @override
  String get listingDetailClaimOwnerButton => 'C\'est mon objet';

  @override
  String get listingDetailNotYoursPrompt => 'Ce n\'est pas votre objet ? ';

  @override
  String get listingDetailSeeOtherListingsLink => 'Voir d\'autres annonces';

  @override
  String listingDetailShareMessage(
    String status,
    String category,
    String description,
    String location,
  ) {
    return '$status sur Kuik : $category — $description ($location). Ouvrez l\'app Kuik pour en savoir plus.';
  }

  @override
  String get listingDetailStatusResolved => 'Résolue';

  @override
  String get listingDetailStatusExpired => 'Expirée';

  @override
  String get listingDetailInfoSectionTitle => 'Informations';

  @override
  String get deleteConfirmTitle => 'Supprimer cette annonce ?';

  @override
  String get deleteConfirmMessage =>
      'Cette action est définitive et ne peut pas être annulée.';

  @override
  String get deleteCancelButton => 'Annuler';

  @override
  String get deleteConfirmButton => 'Supprimer';

  @override
  String get deleteSuccessSnackbar => 'Annonce supprimée.';

  @override
  String get mapLoadError => 'Impossible de charger la carte.';

  @override
  String get mapImpreciseLocationBanner =>
      'Position exacte indisponible — position par défaut (Casablanca) affichée.';

  @override
  String get mapEmptyState => 'Aucune annonce à proximité.';

  @override
  String get photoPickerTakePhoto => 'Prendre une photo';

  @override
  String get photoPickerChooseFromGallery => 'Choisir dans la galerie';

  @override
  String get matchesAppBarTitle => 'Suggestions de correspondance';

  @override
  String get matchesLoadError => 'Impossible de charger les suggestions.';

  @override
  String get matchesEmptyState => 'Aucune suggestion pour le moment.';

  @override
  String get matchesRejectButton => 'Rejeter';

  @override
  String get matchesConfirmButton => 'Confirmer';

  @override
  String get sectionHeaderSeeAllLabel => 'Voir tout';

  @override
  String get claimsAppBarTitle => 'Réclamations';

  @override
  String get claimsLoadError => 'Impossible de charger les réclamations.';

  @override
  String get claimsEmptyState => 'Aucune réclamation en attente.';

  @override
  String get claimsAcceptButton => 'Accepter';

  @override
  String get claimsForLabel => 'Pour :';

  @override
  String get claimSubmitTitle => 'Décrire ce que vous avez trouvé';

  @override
  String get claimSubmitInstructions =>
      'Prenez une photo de l\'objet et décrivez-le brièvement. Le propriétaire examinera votre réclamation avant que la conversation ne s\'ouvre.';

  @override
  String get claimSubmitTitleOwner => 'Prouvez que c\'est votre objet';

  @override
  String get claimSubmitInstructionsOwner =>
      'Envoyez une photo et une description qui prouvent que cet objet vous appartient. La personne qui l\'a trouvé examinera votre réclamation avant que la conversation ne s\'ouvre.';

  @override
  String get claimPhotoRequiredLabel => 'Photo (obligatoire)';

  @override
  String get claimTakePhotoButton => 'Prendre une photo';

  @override
  String get claimRetakePhotoButton => 'Reprendre la photo';

  @override
  String get claimDescriptionLabel => 'Description';

  @override
  String get claimDescriptionHint => 'Ex. trouvé près du parc, coque bleue...';

  @override
  String get claimDescriptionHintOwner =>
      'Ex. rayure sur le coin gauche, photo du fond d\'écran...';

  @override
  String get claimSubmitButton => 'Envoyer la réclamation';

  @override
  String get claimSubmitSuccessSnackbar =>
      'Réclamation envoyée. Le propriétaire va l\'examiner.';

  @override
  String get claimPhotoMissingError => 'Ajoutez une photo avant d\'envoyer.';
}
