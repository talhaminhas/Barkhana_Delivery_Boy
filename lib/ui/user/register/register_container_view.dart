import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_config.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';

import 'register_view.dart';

class RegisterContainerView extends StatefulWidget {
  @override
  _CityRegisterContainerViewState createState() =>
      _CityRegisterContainerViewState();
}

class _CityRegisterContainerViewState extends State<RegisterContainerView>
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
   // userRepo = Provider.of<UserRepository>(context);
    return WillPopScope(
        onWillPop: _requestPop,
        child: Scaffold(
          appBar: _Appbar(
            title: Utils.getString(context, 'register__title'),
            scaffoldKey: scaffoldKey,
          ),
          body: RegisterView(
            animationController: animationController,
          ),
        ));
  }
}

class _Appbar extends StatefulWidget implements PreferredSizeWidget {
  const _Appbar(
      {Key? key, required this.title, this.scaffoldKey})
      : super(key: key);
  final String title;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  _SliverAppbarState createState() => _SliverAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}

class _SliverAppbarState extends State<_Appbar> {
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
