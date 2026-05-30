import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/session_store.dart';

final localeProvider = StateNotifierProvider<LocaleController, Locale?>((ref) => LocaleController(ref.read(sessionStoreProvider)));

class LocaleController extends StateNotifier<Locale?> {
  LocaleController(this._sessionStore) : super(null) {
    _load();
  }

  final SessionStore _sessionStore;

  Future<void> _load() async {
    final code = await _sessionStore.language();
    if (code != null) state = Locale(code);
  }

  Future<void> setLocale(String languageCode) async {
    await _sessionStore.saveLanguage(languageCode);
    state = Locale(languageCode);
  }
}

class AppLocalizations {
  AppLocalizations(this.locale, this._values);

  final Locale locale;
  final Map<String, String> _values;

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  String t(String key) => _values[key] ?? key;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final languageCode = isSupported(locale) ? locale.languageCode : 'en';
    final raw = await rootBundle.loadString('assets/i18n/$languageCode.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return AppLocalizations(Locale(languageCode), decoded.map((key, value) => MapEntry(key, value.toString())));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
