import '../../../l10n/app_localizations.dart';

/// Suggested categories from the cahier des charges (section 2.2). The
/// backend stores `category` as a free string (no enum), so this list is a
/// client-side convenience for a consistent picker, not an API contract.
/// These canonical (French) values are what's actually sent to/from the API
/// and used as keys in [categoryIcons] — [categoryLabel] translates them for
/// display only, without touching the wire format or existing stored data.
const List<String> listingCategories = [
  'Téléphone',
  'Clés',
  'Portefeuille',
  'CIN/Passeport',
  'Sac',
  'Bagage',
  'Animal',
  'Vêtement',
  'Électronique',
  'Autre',
];

String categoryLabel(AppLocalizations l10n, String category) {
  switch (category) {
    case 'Téléphone':
      return l10n.categoryPhone;
    case 'Clés':
      return l10n.categoryKeys;
    case 'Portefeuille':
      return l10n.categoryWallet;
    case 'CIN/Passeport':
      return l10n.categoryIdPassport;
    case 'Sac':
      return l10n.categoryBag;
    case 'Bagage':
      return l10n.categoryLuggage;
    case 'Animal':
      return l10n.categoryAnimal;
    case 'Vêtement':
      return l10n.categoryClothing;
    case 'Électronique':
      return l10n.categoryElectronics;
    case 'Autre':
      return l10n.categoryOther;
    default:
      return category;
  }
}
