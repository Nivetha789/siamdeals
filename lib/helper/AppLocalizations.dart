import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late Map<String, String>? _localizedStrings;

  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString =
        await rootBundle.loadString('i18n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String? translate(String key) {
    return _localizedStrings![key];
  }

  String? get appName => translate('appName');

  String? get description => translate('description');

  String? get category => translate('category');

  String? get categories => translate('categories');

  String? get select_city => translate('select_city');

  String? get mainSearch => translate('mainSearch');

  String? get select_category => translate('select_category');

  String? get category_search => translate('category_search');

  String? get search => translate('search');

  String? get city_spotLight => translate('city_spotLight');

  String? get view_all => translate('view_all');

  String? get place_type => translate('place_type');

  String? get photos => translate('photos');

  String? get coupons => translate('coupons');

  String? get info => translate('info');

  String? get contacts => translate('contacts');

  String? get ph_no => translate('ph_no');

  String? get email_id => translate('email_id');

  String? get address => translate('address');

  String? get search_city => translate('search_city');

  String? get select => translate('select');

  String? get search_category => translate('search_category');

  String? get network_connection_error => translate('network_connection_error');

  String? get download => translate('download');

  String? get call_to_confirm => translate('call_to_confirm');

  String? get discount => translate('discount');
}

// LocalizationsDelegate is a factory for a set of localized resources
// In this case, the localized strings will be gotten in an AppLocalizations object
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'th'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
