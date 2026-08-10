import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locale_storage.dart';

const supportedAppLocales = [Locale('fr'), Locale('ar')];
const defaultAppLocale = Locale('fr');

final localeStorageProvider = Provider<LocaleStorage>((ref) => LocaleStorage());

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    ref.read(localeStorageProvider).readLanguageCode().then((code) {
      if (code != null && supportedAppLocales.any((locale) => locale.languageCode == code)) {
        state = Locale(code);
      }
    });
    return defaultAppLocale;
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref.read(localeStorageProvider).saveLanguageCode(locale.languageCode);
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);
