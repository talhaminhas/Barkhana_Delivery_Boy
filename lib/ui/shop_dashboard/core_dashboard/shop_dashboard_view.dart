import 'dart:async';
//import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_config.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_constants.dart';
import 'package:flutterrtdeliveryboyapp/provider/common/main_dashboard_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/common/notification_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/delete_task/delete_task_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/user/user_provider.dart';
import 'package:flutterrtdeliveryboyapp/repository/Common/notification_repository.dart';
import 'package:flutterrtdeliveryboyapp/repository/app_info_repository.dart';
import 'package:flutterrtdeliveryboyapp/repository/delete_task_repository.dart';
import 'package:flutterrtdeliveryboyapp/repository/user_repository.dart';
import 'package:flutterrtdeliveryboyapp/ui/active_order/active_order_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/dialog/confirm_dialog_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/contact/contact_us_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/language/setting/language_setting_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/order/history/order_history_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/setting/setting_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/shop_dashboard/shop_home/shop_home_dashboard_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/terms_and_conditions/terms_and_conditions_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/user/forgot_password/forgot_password_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/user/login/login_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/user/pending_user/pending_user_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/user/phone/sign_in/phone_sign_in_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/user/profile/profile_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/user/register/register_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/user/reject_user/reject_user_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/user/verify/verify_email_view.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/common/ps_value_holder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../../api/common/ps_resource.dart';
import '../../../api/ps_api_service.dart';
import '../../../viewobject/api_status.dart';
import '../../../viewobject/user.dart';
import '../../common/ps_toast.dart';
import 'core_appbar_dashboard_view.dart';
import 'core_drawer_dashboard_view.dart';

class ShopDashboardView extends StatefulWidget {
  @override
  _ShopDashboardViewState createState() => _ShopDashboardViewState();
}

class _ShopDashboardViewState extends State<ShopDashboardView>
    with SingleTickerProviderStateMixin {
 late AnimationController animationController;
  Animation<double>? animation;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    /// Init Animation
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);

    /// FCM Configure
    Utils.fcmConfigure(context, _fcm);

    super.initState();

  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
 bool isTimerRunning = false;
 late Timer timer;
  UserRepository? userRepository;
  AppInfoRepository? appInfoRepository;
  PsValueHolder? valueHolder;
  DeleteTaskRepository ?deleteTaskRepository;
  NotificationRepository? notificationRepository;
  UserProvider? userProvider;
  DeleteTaskProvider? deleteTaskProvider;
  MainDashboardProvider? mainDashboardProvider;
  String? _appBarTitle;
  User? user;


 Future<void> requestLocationPermission() async {
   PermissionStatus permission = await Permission.location.status;
   if (permission != PermissionStatus.granted) {
     permission = await Permission.location.request();
     if (permission != PermissionStatus.granted) {
       if (await Permission.location.isPermanentlyDenied) {

         openAppSettings();
       }
       // Handle denied permission
       return;
     }
   }
   // Permission has been granted
 }
 void startTimer() {
   if(!isTimerRunning) {
     isTimerRunning = true;
     timer = Timer.periodic(const Duration(seconds: 15), (Timer timer) async {
       final Position position = await Geolocator.getCurrentPosition(
         desiredAccuracy: LocationAccuracy.high,
       );
       final double latitude = position.latitude;
       final double longitude = position.longitude;
       if (await Utils.checkInternetConnectivity()) {
         final Map<String, dynamic> jsonMap = <String, dynamic>{};
         jsonMap['user_id'] = valueHolder!.loginUserId!;
         jsonMap['lat'] = latitude.toString();
         jsonMap['lng'] = longitude.toString();
         final PsResource<ApiStatus> apiStatus = await PsApiService()
             .postDeliveryBoyLocation(jsonMap);
         //print(apiStatus.data!.message!);
       }
       else {
         PsToast().showToast(
             Utils.getString(context!, 'error_dialog__no_internet'));
       }
     });
   }
 }

 Future<void> getLocation() async {
   LocationPermission permission = await Geolocator.checkPermission();
   if (permission == LocationPermission.denied) {
     permission = await Geolocator.requestPermission();
     if (permission == LocationPermission.denied) {
       requestLocationPermission();
       return;
     }
   }
   startTimer();
 }

  @override
  Widget build(BuildContext context) {
    print('** Build Shop Dashboard **');

    userRepository = Provider.of<UserRepository>(context);
    appInfoRepository = Provider.of<AppInfoRepository>(context);
    deleteTaskRepository = Provider.of<DeleteTaskRepository>(context);
    notificationRepository = Provider.of<NotificationRepository>(context);
    valueHolder = Provider.of<PsValueHolder?>(context);
    Utils.psPrint(valueHolder!.isDeliveryBoy ?? '');
    Utils.subscribeToTopic(valueHolder!.notiSetting ?? true);

    final Animation<double> animation =
        Utils.getTweenAnimation(animationController, 1);
    getLocation();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        drawer: CoreDrawerDashboardView(
            userRepository: userRepository!,
            deleteTaskRepository: deleteTaskRepository!,
            updateSelectedIndexWithAnimation: updateSelectedIndexWithAnimation,
            mainDashboardProvider: mainDashboardProvider),
        appBar: CoreAppBarDashboardView(
            appBarTitle: _appBarTitle ?? Utils.getString(context, 'app_name')),
        body: MultiProvider(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<MainDashboardProvider>(
                lazy: false,
                create: (BuildContext context) {
                  mainDashboardProvider = MainDashboardProvider(
                      PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT,
                      Utils.getString(context, 'app_name'));
                  mainDashboardProvider!.updateIndex(
                      PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT,
                      Utils.getString(context, 'app_name'),
                      mounted);
                  return mainDashboardProvider!;
                }),
            ChangeNotifierProvider<UserProvider>(
                lazy: false,
                create: (BuildContext context) {
                  userProvider = UserProvider(
                      repo: userRepository!, psValueHolder: valueHolder);
                  userProvider!.getUser(valueHolder!.loginUserId ?? '');
                  return userProvider!;
                }),
            ChangeNotifierProvider<DeleteTaskProvider>(
                lazy: false,
                create: (BuildContext context) {
                  deleteTaskProvider = DeleteTaskProvider(
                      repo: deleteTaskRepository!, psValueHolder: valueHolder);
                  return deleteTaskProvider!;
                }),
            ChangeNotifierProvider<NotificationProvider>(
              lazy: false,
              create: (BuildContext context) {
                final NotificationProvider provider = NotificationProvider(
                    repo: notificationRepository!, psValueHolder: valueHolder);

                Utils.saveDeviceToken(_fcm, provider);

                return provider;
              },
            ),
          ],
          child: Consumer<MainDashboardProvider>(builder: (BuildContext context,
              MainDashboardProvider provider, Widget? child) {
            // print('current index : ${provider.currentIndex}');
            switch (mainDashboardProvider!.currentIndex) {

              /// HOME
              case PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT:
                return ShopHomeDashboardViewWidget(
                  animationController: animationController,
                );
             //   break;

              /// Related With User Profile
              case PsConst.REQUEST_CODE__MENU_USER_PROFILE_FRAGMENT:
                return ProfileView(
                  animationController: animationController,
                  callLogoutCallBack: (String userId) {
                    callLogout(userProvider!, deleteTaskProvider!,
                        PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT);
                  },
                );
              //  break;
              case PsConst.REQUEST_CODE__MENU_PENDING_USER_FRAGMENT:
                return const PendingUserView();
             //   break;
              case PsConst.REQUEST_CODE__MENU_REJECTED_USER_FRAGMENT:
                return const RejectUserView();
             //   break;
              case PsConst.REQUEST_CODE__MENU_REGISTER_FRAGMENT:
                return RegisterView(
                  animationController: animationController,
                );
              //  break;
              case PsConst.REQUEST_CODE__MENU_FORGOT_PASSWORD_FRAGMENT:
                return ForgotPasswordView(
                  animationController: animationController,
                );
             //   break;
              case PsConst.REQUEST_CODE__MENU_LOGIN_FRAGMENT:
                return LoginView(
                  animationController: animationController,
                  animation: animation,
                  callback: () {
                    updateSelectedIndexWithAnimation(
                        Utils.getString(context, 'app_name'),
                        PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT);
                  },
                );
              //  break;
              case PsConst.REQUEST_CODE__MENU_VERIFY_EMAIL_FRAGMENT:
                return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: VerifyEmailView(
                      animationController: animationController,
                      callback: () {
                        updateSelectedIndexWithAnimation(
                            Utils.getString(context, 'app_name'),
                            PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT);
                      },
                    ));
            //    break;
              case PsConst.REQUEST_CODE__MENU_PHONE_SIGNIN_FRAGMENT:
                return PhoneSignInView(
                  animationController: animationController,
                );
             //   break;

              /// Active Orders
              case PsConst.REQUEST_CODE__MENU_ACTIVE_ORDER_FRAGMENT:
                return ActiveOrderListView(
                    scaffoldKey: scaffoldKey,
                    animationController: animationController);
             //   break;

              /// Order History
              case PsConst.REQUEST_CODE__MENU_ORDER_HISTORY_FRAGMENT:
                return OrderHistoryListView(
                    scaffoldKey: scaffoldKey,
                    animationController: animationController);
             //   break;

              /// Language
              case PsConst.REQUEST_CODE__MENU_LANGUAGE_FRAGMENT:
                return LanguageSettingView(
                    animationController: animationController,
                    languageIsChanged: () {});
               // break;

              /// Contact Us
              case PsConst.REQUEST_CODE__MENU_CONTACT_US_FRAGMENT:
                return ContactUsView(animationController: animationController,
                  userProvider: userProvider);
               // break;

              /// Setting
              case PsConst.REQUEST_CODE__MENU_SETTING_FRAGMENT:
                return Container(
                  color: PsColors.coreBackgroundColor,
                  height: double.infinity,
                  child: SettingView(
                    animationController: animationController,
                  ),
                );
              //  break;

              /// Terms and Conditions
              case PsConst.REQUEST_CODE__MENU_TERMS_AND_CONDITION_FRAGMENT:
                return TermsAndConditionsView(
                  animationController: animationController,
                );
               // break;

              default:
                return Container();
            }
          }),
        ),
      ),
    );
  }

  Future<void> updateSelectedIndexWithAnimation(String title, int index) async {
    await animationController.reverse().then<dynamic>((void data) {
      if (!mounted) {
        return;
      }
      setState(() {
        _appBarTitle = title;
      });
      mainDashboardProvider!.updateIndex(index, title, mounted);
    });
  }

  Future<void> updateSelectedIndex(
      String title, int index, String? userId, String userFlag) async {
    if (userId != null) {
      userProvider!.userId = userId;
    }
    setState(() {
      _appBarTitle = title;
    });
    mainDashboardProvider!.updateIndex(index, title, mounted);
  }

  dynamic callLogout(UserProvider provider,
        DeleteTaskProvider deleteTaskProvider, int index) async {
      updateSelectedIndexWithAnimation(
        Utils.getString(context, 'app_name'),
        index);
      await provider.replaceLoginUserId('');
      await provider.replaceLoginUserName('');
      await deleteTaskProvider.deleteTask();
      //await FacebookAuth.instance.logOut();
      await GoogleSignIn().signOut();
      await fb_auth.FirebaseAuth.instance.signOut();
    }

  Future<bool> _onWillPop() {
    return showDialog<dynamic>(
            context: context,
            builder: (BuildContext context) {
              return ConfirmDialogView(
                  description:
                      Utils.getString(context, 'home__quit_dialog_description'),
                  leftButtonText:
                      Utils.getString(context, 'app_info__cancel_button_name'),
                  rightButtonText: Utils.getString(context, 'dialog__ok'),
                  onAgreeTap: () {
                    SystemNavigator.pop();
                  });
            }) .then((dynamic value) => value as bool);
       // false;
  }
}
