import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_theme_data.dart';
import 'package:flutterrtdeliveryboyapp/config/router.dart' as router;
import 'package:flutterrtdeliveryboyapp/provider/common/ps_theme_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/ps_provider_dependencies.dart';
import 'package:flutterrtdeliveryboyapp/repository/ps_theme_repository.dart';
import 'package:flutterrtdeliveryboyapp/ui/map/polyline_view.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/common/language.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_manager/theme_manager.dart';
import 'api/api_token_refresher.dart';
import 'api/ps_api_service.dart';
import 'config/ps_config.dart';
import 'constant/ps_constants.dart';
import 'db/common/ps_shared_preferences.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // add this, and it should be the first line in main method
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.getString('codeC') == null) {
    await prefs.setString('codeC', '');
    await prefs.setString('codeL', '');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
 // MobileAds.instance.initialize();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  if (Platform.isIOS) {
    FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true);
  }

  await EasyLocalization.ensureInitialized();

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  /*if(!kIsWeb) {
    final String? fcmToken = await FirebaseMessaging.instance.getToken();
    print('fcmToken: $fcmToken');
  }*/
  //check is apple signin is available
  await Utils.checkAppleSignInAvailable();

  Utils.psPrint('Apple Sign Flag is : ${Utils.isAppleSignInAvailable}');

  runApp(EasyLocalization(
      path: 'assets/langs',
      saveLocale: true,
      startLocale: PsConfig.defaultLanguage.toLocale(),
      supportedLocales: getSupportedLanguages(),
      child: PSApp()));
}

List<Locale> getSupportedLanguages() {
  final List<Locale> localeList = <Locale>[];
  for (final Language lang in PsConfig.psSupportedLanguageList) {
    localeList.add(Locale(lang.languageCode!, lang.countryCode));
  }
  print('Loaded Languages');
  return localeList;
}

Future<dynamic> initAds() async {
  if (PsConst.SHOW_ADMOB && await Utils.checkInternetConnectivity()) {
    // FirebaseAdMob.instance.initialize(appId: utilsGetAdAppId());
  }
}

class PSApp extends StatefulWidget {
  static final ApiTokenRefresher apiTokenRefresher = ApiTokenRefresher(psApiService: PsApiService());
  @override
  _PSAppState createState() => _PSAppState();
}

class _PSAppState extends State<PSApp> {
  Completer<ThemeData>? themeDataCompleter;
  PsSharedPreferences? psSharedPreferences;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(PSApp.apiTokenRefresher);
    super.initState();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(PSApp.apiTokenRefresher);
    print('psapp disposed called');
    super.dispose();
  }
  Future<ThemeData> getSharePerference(
      EasyLocalization provider, dynamic data) {
    Utils.psPrint('>> get share perference');
    if (themeDataCompleter == null) {
      Utils.psPrint('init completer');
      themeDataCompleter = Completer<ThemeData>();
    }

    if (psSharedPreferences == null) {
      Utils.psPrint('init ps shareperferences');
      psSharedPreferences = PsSharedPreferences.instance;
      Utils.psPrint('get shared');

      psSharedPreferences!.futureShared.then((SharedPreferences sh) {
        psSharedPreferences!.shared = sh;

        Utils.psPrint('init theme provider');
        final PsThemeProvider psThemeProvider = PsThemeProvider(
            repo: PsThemeRepository(psSharedPreferences: psSharedPreferences!));

        Utils.psPrint('get theme');
        final ThemeData themeData = psThemeProvider.getTheme();

        themeDataCompleter!.complete(themeData);
        Utils.psPrint('themedata loading completed');
      });
    }

    return themeDataCompleter!.future;
  }

  List<Locale> getSupportedLanguages() {
    final List<Locale> localeList = <Locale>[];
    for (final Language lang in PsConfig.psSupportedLanguageList) {
      localeList.add(Locale(lang.languageCode!, lang.countryCode));
    }
    print('Loaded Languages');
    return localeList;
  }

  @override
  Widget build(BuildContext context) {
    // init Color
    PsColors.loadColor(context);
    return MultiProvider(
        providers: <SingleChildWidget>[
          ...providers,
          // ChangeNotifierProvider<MainDashboardProvider>(
          //     lazy: false,
          //     create: (BuildContext context) {
          //       return MainDashboardProvider(
          //           PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT,
          //           Utils.getString(context, 'app_name'));
          //     }),
        ],
        child: ThemeManager(
            defaultBrightnessPreference: BrightnessPreference.light,
            data: (Brightness brightness) {
              if (brightness == Brightness.light) {
                return themeData(ThemeData.light());
              } else {
                return themeData(ThemeData.dark());
              }
            },
            themedWidgetBuilder:
                (BuildContext context, ThemeData theme) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Panacea-Soft',
                theme: theme,
                initialRoute: '/',
                onGenerateRoute: router.generateRoute,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
              );
            }));
  }
}
