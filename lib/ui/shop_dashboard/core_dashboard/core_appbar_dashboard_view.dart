import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';

class CoreAppBarDashboardView extends StatelessWidget
    implements PreferredSizeWidget {
  const CoreAppBarDashboardView({
    Key? key,
    required this.appBarTitle,
  }) : super(key: key);

  final String appBarTitle;

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      backgroundColor: PsColors.baseColor,
      title: Text(appBarTitle,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold, color: PsColors.mainColorWithWhite)),
      // Consumer<MainDashboardProvider>(
      //   builder: (BuildContext context, MainDashboardProvider provider,
      //       Widget child) {
      //     return Text(appBarTitle,
      //         style: Theme.of(context).textTheme.titleLarge.copyWith(
      //             fontWeight: FontWeight.bold,
      //             color: PsColors.mainColorWithWhite));
      // },
      // ),
      titleSpacing: 0,
      elevation: 0,
      iconTheme: IconThemeData(color: PsColors.mainColorWithWhite),
      toolbarTextStyle: TextStyle(color: PsColors.textPrimaryColor),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Utils.getBrightnessForAppBar(context),
      ), 
    );
  }
}
