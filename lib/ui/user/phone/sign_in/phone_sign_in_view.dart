import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_config.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_dimens.dart';
import 'package:flutterrtdeliveryboyapp/constant/route_paths.dart';
import 'package:flutterrtdeliveryboyapp/provider/user/user_provider.dart';
import 'package:flutterrtdeliveryboyapp/repository/user_repository.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/dialog/error_dialog.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/ps_button_widget.dart';
import 'package:flutterrtdeliveryboyapp/utils/ps_progress_dialog.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/common/ps_value_holder.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/holder/intent_holder/verify_phone_internt_holder.dart';
import 'package:provider/provider.dart';

class PhoneSignInView extends StatefulWidget {
  const PhoneSignInView({
    Key? key,
    this.animationController,
  }) : super(key: key);
  final AnimationController? animationController;

  @override
  _PhoneSignInViewState createState() => _PhoneSignInViewState();
}

class _PhoneSignInViewState extends State<PhoneSignInView>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  UserRepository? repo1;
  PsValueHolder? psValueHolder;
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

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: animationController!,
            curve: const Interval(0.5 * 1, 1.0, curve: Curves.fastOutSlowIn)));

    animationController!.forward();
    repo1 = Provider.of<UserRepository>(context);
    psValueHolder = Provider.of<PsValueHolder?>(context);

    return Stack(children: <Widget>[
      Container(
        color: PsColors.mainLightColor,
        width: double.infinity,
        height: double.maxFinite,
      ),
      CustomScrollView(scrollDirection: Axis.vertical, slivers: <Widget>[
        SliverToBoxAdapter(
          child: ChangeNotifierProvider<UserProvider>(
            lazy: false,
            create: (BuildContext context) {
              final UserProvider provider =
                  UserProvider(repo: repo1!, psValueHolder: psValueHolder);
              return provider;
            },
            child: Consumer<UserProvider>(builder:
                (BuildContext context, UserProvider provider, Widget? child) {
              return Stack(
                children: <Widget>[
                  SingleChildScrollView(
                      child: AnimatedBuilder(
                          animation: animationController!,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              _HeaderIconAndTextWidget(),
                              _CardWidget(
                                nameController: nameController,
                                phoneController: phoneController,
                              ),
                              const SizedBox(
                                height: PsDimens.space8,
                              ),
                              _SendButtonWidget(
                                provider: provider,
                                nameController: nameController,
                                phoneController: phoneController,
                              ),
                              const SizedBox(
                                height: PsDimens.space16,
                              ),
                              const _TextWidget(),
                            ],
                          ),
                          builder: (BuildContext context, Widget? child) {
                            return FadeTransition(
                              opacity: animation,
                              child: Transform(
                                transform: Matrix4.translationValues(
                                    0.0, 100 * (1.0 - animation.value), 0.0),
                          child: child
                          ),
                        );
                    }))
                ],
              );
            }),
          ),
        )
      ])
    ]);
  }
}

class _TextWidget extends StatefulWidget {
  const _TextWidget();

  @override
  __TextWidgetState createState() => __TextWidgetState();
}

class __TextWidgetState extends State<_TextWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text(
        Utils.getString(context, 'phone_signin__back_login'),
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: PsColors.mainColor),
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          RoutePaths.login_container,
        );
      },
    );
  }
}

class _HeaderIconAndTextWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Widget _textWidget = Text(
      Utils.getString(context, 'app_name'),
      style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: PsColors.mainColor,
          ),
    );

    final Widget _imageWidget = Container(
      width: 90,
      height: 90,
      child: Image.asset(
        'assets/images/app_icon.png',
      ),
    );
    return Column(
      children: <Widget>[
        const SizedBox(
          height: PsDimens.space32,
        ),
        _imageWidget,
        const SizedBox(
          height: PsDimens.space8,
        ),
        _textWidget,
        const SizedBox(
          height: PsDimens.space52,
        ),
      ],
    );
  }
}

class _CardWidget extends StatelessWidget {
  const _CardWidget(
      {required this.nameController, required this.phoneController});

  final TextEditingController nameController;
  final TextEditingController phoneController;
  @override
  Widget build(BuildContext context) {
    const EdgeInsets _marginEdgeInsetsforCard = EdgeInsets.only(
        left: PsDimens.space16,
        right: PsDimens.space16,
        top: PsDimens.space4,
        bottom: PsDimens.space4);
    return Card(
      elevation: 0.3,
      margin: const EdgeInsets.only(
          left: PsDimens.space32, right: PsDimens.space32),
      child: Column(
        children: <Widget>[
          Container(
            margin: _marginEdgeInsetsforCard,
            child: TextField(
              controller: nameController,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: Utils.getString(context, 'register__user_name'),
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: PsColors.textPrimaryLightColor),
                  icon: Icon(Icons.people,
                      color: Theme.of(context).iconTheme.color)),
            ),
          ),
          const Divider(
            height: PsDimens.space1,
          ),
          Container(
            margin: _marginEdgeInsetsforCard,
            child: Directionality(
              textDirection: Directionality.of(context) == TextDirection.ltr
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: TextField(
                controller: phoneController,
                textDirection: TextDirection.ltr,
                textAlign: Directionality.of(context) == TextDirection.ltr
                    ? TextAlign.left
                    : TextAlign.right,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '+959123456789',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: PsColors.textPrimaryLightColor),
                    icon: Icon(Icons.phone,
                        color: Theme.of(context).iconTheme.color)),
                // keyboardType: TextInputType.number,
            )),
          ),
        ],
      ),
    );
  }
}

class _SendButtonWidget extends StatefulWidget {
  const _SendButtonWidget({
    required this.provider,
    required this.nameController,
    required this.phoneController,
  });
  final UserProvider provider;
  final TextEditingController nameController;
  final TextEditingController phoneController;

  @override
  __SendButtonWidgetState createState() => __SendButtonWidgetState();
}

dynamic callWarningDialog(BuildContext context, String text) {
  showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return WarningDialog(
          message: Utils.getString(context, text),
          onPressed: () {},
        );
      });
}

class __SendButtonWidgetState extends State<_SendButtonWidget> {
  Future<String> verifyPhone() async {
    String? verificationId;
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      verificationId = verId;
      PsProgressDialog.dismissDialog();
    };
    final PhoneCodeSent smsCodeSent =
        (String verId, [int? forceCodeResend]) async {
      verificationId = verId;
      PsProgressDialog.dismissDialog();
      print('code has been send');

      await Navigator.pushNamed(context, RoutePaths.user_phone_verify_container,
          arguments: VerifyPhoneIntentHolder(
              userName: widget.nameController.text,
              phoneNumber: widget.phoneController.text,
              phoneId: verificationId!));

      // if (returnData != null && returnData is User) {
      //   Navigator.pop(context);
      // }
    };
    final PhoneVerificationCompleted verifySuccess = (AuthCredential user) {
      print('verify');
      PsProgressDialog.dismissDialog();
    };
    final PhoneVerificationFailed verifyFail = (FirebaseAuthException exception) {
      print('${exception.message}');
      PsProgressDialog.dismissDialog();
      showDialog<dynamic>(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              message: '${exception.message}',
            );
          });
    };
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneController.text,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifySuccess,
        verificationFailed: verifyFail);
    return verificationId!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(
            left: PsDimens.space32, right: PsDimens.space32),
        child: PSButtonWidget(
          hasShadow: true,
          width: double.infinity,
          titleText: Utils.getString(context, 'login__phone_signin'),
          onPressed: () async {
            if (widget.nameController.text.isEmpty) {
              callWarningDialog(context,
                  Utils.getString(context, 'warning_dialog__input_name'));
            } else if (widget.phoneController.text.isEmpty) {
              callWarningDialog(context,
                  Utils.getString(context, 'warning_dialog__input_phone'));
            } else {
              await PsProgressDialog.showDialog(context);
              await verifyPhone();
            }
          },
        ));
  }
}