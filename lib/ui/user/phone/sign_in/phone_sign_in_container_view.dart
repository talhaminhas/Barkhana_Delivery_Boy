import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_config.dart';
import 'package:flutterrtdeliveryboyapp/provider/user/user_provider.dart';
import 'package:flutterrtdeliveryboyapp/repository/user_repository.dart';
import 'package:flutterrtdeliveryboyapp/ui/user/phone/sign_in/phone_sign_in_view.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:provider/provider.dart';

class PhoneSignInContainerView extends StatefulWidget {
  @override
  _CityPhoneSignInContainerViewState createState() =>
      _CityPhoneSignInContainerViewState();
}

class _CityPhoneSignInContainerViewState extends State<PhoneSignInContainerView>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  @override
  void initState() {
    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  UserProvider? userProvider;
  UserRepository? userRepo;

  @override
  Widget build(BuildContext context) {
    Future<bool> _requestPop() {
      animationController!.reverse().then<dynamic>(
        (void data) {
          if (!mounted) {
            return Future<bool>.value(false);
          }
          Navigator.pop(context, true);
          return Future<bool>.value(true);
        },
      );
      return Future<bool>.value(false);
    }

    print(
        '............................Build UI Again ............................');
    userRepo = Provider.of<UserRepository>(context);
    return WillPopScope(
        onWillPop: _requestPop,
        child: Scaffold(
          appBar: _Appbar(
            title: Utils.getString(context, 'home_phone_signin'),
            scaffoldKey: scaffoldKey,
          ),
          body: PhoneSignInView(
            animationController: animationController,
          ),
        ));
  }
}

class _Appbar extends StatefulWidget implements PreferredSizeWidget {
  const _Appbar(
      {Key? key, 
      required this.title, this.scaffoldKey})
      : super(key: key);
  final String title;
  final GlobalKey<ScaffoldState> ?scaffoldKey;
  
  @override
  _AppbarState createState() => _AppbarState();

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}

class _AppbarState extends State<_Appbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Utils.getBrightnessForAppBar(context),
      ), 
      iconTheme: Theme.of(context)
          .iconTheme
          .copyWith(color: PsColors.mainColorWithWhite),
      title: Text(
        widget.title,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(fontWeight: FontWeight.bold)
            .copyWith(color: PsColors.mainColorWithWhite),
      ),
      elevation: 0,
    );
  }
}
