import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocale {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocale(this.locale);

  static AppLocale? of(BuildContext context) {
    return Localizations.of<AppLocale>(context, AppLocale);
  }

  static const LocalizationsDelegate<AppLocale> delegate =
  _AppLocalizationsDelegate();

  Future<bool> load() async {
    // logger.e(locale.languageCode.toString());
    String jsonString =
    await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    return true;
  }

  String? translate(String key) {
    return _localizedStrings[key];
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocale> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ms'].contains(locale.languageCode);
  }

  @override
  Future<AppLocale> load(Locale locale) async {
    AppLocale localizations = new AppLocale(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}