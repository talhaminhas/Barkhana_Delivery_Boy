import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_config.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_constants.dart';
import 'package:flutterrtdeliveryboyapp/db/common/ps_shared_preferences.dart';
import 'package:flutterrtdeliveryboyapp/repository/Common/ps_repository.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/common/language.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/common/language_value_holder.dart';

class LanguageRepository extends PsRepository {
  LanguageRepository({required PsSharedPreferences psSharedPreferences}) {
    _psSharedPreferences = psSharedPreferences;
  }

  final StreamController<PsLanguageValueHolder> _valueController =
      StreamController<PsLanguageValueHolder>();
  Stream<PsLanguageValueHolder> get psValueHolder => _valueController.stream;

 late PsSharedPreferences _psSharedPreferences;

  void loadLanguageValueHolder() {
    final String? _languageCodeKey = _psSharedPreferences.shared
        .getString(PsConst.LANGUAGE__LANGUAGE_CODE_KEY);
    final String? _countryCodeKey = _psSharedPreferences.shared
        .getString(PsConst.LANGUAGE__COUNTRY_CODE_KEY);
    final String? _languageNameKey = _psSharedPreferences.shared
        .getString(PsConst.LANGUAGE__LANGUAGE_NAME_KEY);

    _valueController.add(PsLanguageValueHolder(
      languageCode: _languageCodeKey,
      countryCode: _countryCodeKey,
      name: _languageNameKey,
    ));
  }

  Future<void> addLanguage(Language language) async {
    await _psSharedPreferences.shared
        .setString(PsConst.LANGUAGE__LANGUAGE_CODE_KEY, language.languageCode!);
    await _psSharedPreferences.shared
        .setString(PsConst.LANGUAGE__COUNTRY_CODE_KEY, language.countryCode!);
    await _psSharedPreferences.shared
        .setString(PsConst.LANGUAGE__LANGUAGE_NAME_KEY, language.name!);
    await _psSharedPreferences.shared.setString('locale',
        Locale(language.languageCode!, language.countryCode).toString());
    loadLanguageValueHolder();
  }

  Language getLanguage() {
    final String? languageCode = _psSharedPreferences.shared
            .getString(PsConst.LANGUAGE__LANGUAGE_CODE_KEY) ??
        PsConfig.defaultLanguage.languageCode;
    final String? countryCode = _psSharedPreferences.shared
            .getString(PsConst.LANGUAGE__COUNTRY_CODE_KEY) ??
        PsConfig.defaultLanguage.countryCode;
    final String? languageName = _psSharedPreferences.shared
            .getString(PsConst.LANGUAGE__LANGUAGE_NAME_KEY) ??
        PsConfig.defaultLanguage.name;

    return Language(
        languageCode: languageCode,
        countryCode: countryCode,
        name: languageName);
  }
}