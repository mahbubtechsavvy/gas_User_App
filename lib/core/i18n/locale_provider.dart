import 'package:flutter/material.dart';
import '../storage/storage_service.dart';
import 'app_strings.dart';

class LocaleProvider extends ChangeNotifier {
  final StorageService _storageService;
  String _locale = 'bn';

  LocaleProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService() {
    _loadLocale();
  }

  String get locale => _locale;
  bool get isBangla => _locale == 'bn';

  Future<void> _loadLocale() async {
    final savedLocale = await _storageService.getLocale();
    if (savedLocale != null && (savedLocale == 'bn' || savedLocale == 'en')) {
      _locale = savedLocale;
      notifyListeners();
    }
  }

  Future<void> setLocale(String newLocale) async {
    if (newLocale != _locale && (newLocale == 'bn' || newLocale == 'en')) {
      _locale = newLocale;
      await _storageService.saveLocale(newLocale);
      notifyListeners();
    }
  }

  String tr(String key) {
    return AppStrings.get(key, locale: _locale);
  }
}
