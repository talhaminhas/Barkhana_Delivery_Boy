import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterrtdeliveryboyapp/api/common/ps_resource.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_config.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_constants.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_dimens.dart';
import 'package:flutterrtdeliveryboyapp/constant/route_paths.dart';
import 'package:flutterrtdeliveryboyapp/provider/user/user_provider.dart';
import 'package:flutterrtdeliveryboyapp/repository/user_repository.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/base/ps_widget_with_appbar.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/dialog/error_dialog.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/dialog/success_dialog.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/ps_button_widget.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/ps_textfield_widget.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/ps_ui_widget.dart';
import 'package:flutterrtdeliveryboyapp/utils/ps_progress_dialog.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/common/ps_value_holder.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/holder/profile_update_view_holder.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class EditProfileView extends StatefulWidget {
  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView>
    with SingleTickerProviderStateMixin {
  UserRepository? userRepository;
  UserProvider? userProvider;
  PsValueHolder? psValueHolder;
  AnimationController? animationController;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController aboutMeController = TextEditingController();

  bool bindDataFirstTime = true;

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
    userRepository = Provider.of<UserRepository>(context);
    psValueHolder = Provider.of<PsValueHolder?>(context);

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

    return WillPopScope(
        onWillPop: _requestPop,
        child: PsWidgetWithAppBar<UserProvider>(
            appBarTitle: Utils.getString(context, 'edit_profile__title') ,
            initProvider: () {
              return UserProvider(
                  repo: userRepository!, psValueHolder: psValueHolder);
            },
            onProviderReady: (UserProvider provider) async {
              await provider.getUser(psValueHolder!.loginUserId!);
              userProvider = provider;
            },
            builder:
                (BuildContext context, UserProvider provider, Widget? child) {
              if (userProvider != null &&
               
                  userProvider!.user.data != null) {
                if (bindDataFirstTime) {
                  userNameController.text = userProvider!.user.data!.userName!;
                  emailController.text = userProvider!.user.data!.userEmail!;
                  phoneController.text = userProvider!.user.data!.userPhone!;
                  aboutMeController.text = userProvider!.user.data!.userAboutMe!;
                  bindDataFirstTime = false;
                }

                return SingleChildScrollView(
                  child: Container(
                    color: PsColors.backgroundColor,
                    padding: const EdgeInsets.only(
                        left: PsDimens.space8, right: PsDimens.space8),
                    child: Column(
                      children: <Widget>[
                        _ImageWidget(userProvider: userProvider!),
                        _UserFirstCardWidget(
                          userNameController: userNameController,
                          emailController: emailController,
                          phoneController: phoneController,
                          aboutMeController: aboutMeController,
                        ),
                        const SizedBox(
                          height: PsDimens.space8,
                        ),
                        _TwoButtonWidget(
                            userProvider: userProvider!,
                            userNameController: userNameController,
                            emailController: emailController,
                            phoneController: phoneController,
                            aboutMeController: aboutMeController),
                        const SizedBox(
                          height: PsDimens.space20,
                        )
                      ],
                    ),
                  ),
                );
              } else {
                return Stack(
                  children: <Widget>[
                    Container(),
                    PSProgressIndicator(provider.user.status)
                  ],
                );
              }
            }));
  }
}

class _TwoButtonWidget extends StatelessWidget {
  const _TwoButtonWidget({
    required this.userProvider,
    required this.userNameController,
    required this.emailController,
    required this.phoneController,
    required this.aboutMeController,
  });

  final TextEditingController userNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController aboutMeController;
  final UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(
              left: PsDimens.space12, right: PsDimens.space12),
          child: PSButtonWidget(
            hasShadow: true,
            width: double.infinity,
            titleText: Utils.getString(context, 'edit_profile__save'),
            onPressed: () async {
              if (userNameController.text == '') {
                showDialog<dynamic>(
                    context: context,
                    builder: (BuildContext context) {
                      return ErrorDialog(
                        message: Utils.getString(
                            context, 'edit_profile__name_error'),
                      );
                    });
              } else if (emailController.text == '') {
                showDialog<dynamic>(
                    context: context,
                    builder: (BuildContext context) {
                      return ErrorDialog(
                        message: Utils.getString(
                            context, 'edit_profile__email_error'),
                      );
                    });
              } else {
                if (await Utils.checkInternetConnectivity()) {
                  final ProfileUpdateParameterHolder
                      profileUpdateParameterHolder =
                      ProfileUpdateParameterHolder(
                    userId: userProvider.user.data!.userId,
                    userName: userNameController.text,
                    userEmail: emailController.text.trim(),
                    userPhone: phoneController.text,
                    userAboutMe: aboutMeController.text,
                  );
                  await PsProgressDialog.showDialog(context);
                  final PsResource<User> _apiStatus = await userProvider
                      .postProfileUpdate(profileUpdateParameterHolder.toMap());
                  if (_apiStatus.data != null) {
                    PsProgressDialog.dismissDialog();
                    showDialog<dynamic>(
                        context: context,
                        builder: (BuildContext contet) {
                          return SuccessDialog(
                            message: Utils.getString(
                                context, 'edit_profile__success'),
                          );
                        });
                  } else {
                    PsProgressDialog.dismissDialog();

                    showDialog<dynamic>(
                        context: context,
                        builder: (BuildContext context) {
                          return ErrorDialog(
                            message: _apiStatus.message,
                          );
                        });
                  }
                } else {
                  showDialog<dynamic>(
                      context: context,
                      builder: (BuildContext context) {
                        return ErrorDialog(
                          message: Utils.getString(
                              context, 'error_dialog__no_internet'),
                        );
                      });
                }
              }
            },
          ),
        ),
        const SizedBox(
          height: PsDimens.space12,
        ),
        Container(
          margin: const EdgeInsets.only(
              left: PsDimens.space12,
              right: PsDimens.space12,
              bottom: PsDimens.space20),
          child: PSButtonWidget(
            hasShadow: false,
            colorData: PsColors.grey,
            width: double.infinity,
            titleText:
                Utils.getString(context, 'edit_profile__password_change'),
            onPressed: () {
              Navigator.pushNamed(
                context,
                RoutePaths.user_update_password,
              );
            },
          ),
        )
      ],
    );
  }
}

class _ImageWidget extends StatefulWidget {
  const _ImageWidget({this.userProvider});
  final UserProvider? userProvider;

  @override
  __ImageWidgetState createState() => __ImageWidgetState();
}

XFile ?pickedImage;
List<XFile> images = <XFile>[];

class __ImageWidgetState extends State<_ImageWidget> {
  Future<bool> requestGalleryPermission() async {
    const Permission _photos = Permission.photos;
    final PermissionStatus ?permissionss = await _photos.request();

    if (permissionss != null && permissionss == PermissionStatus.granted) {
      return true;
    } else {
      return openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _pickImage() async {
     final ImagePicker _picker = ImagePicker();

      try {
        pickedImage = await _picker.pickImage(
          source: ImageSource.gallery,
        );
      } on Exception catch (e) {
        e.toString();
      }

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) {
        return;
      }
      //images = resultList;
      setState(() {});

     // if (images.isNotEmpty) {
        if (pickedImage!.name.contains('.webp')) {
          showDialog<dynamic>(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(
                  message: Utils.getString(context, 'error_dialog__webp_image'),
                );
              });
        } else {
          PsProgressDialog.dismissDialog();
          final PsResource<User> _apiStatus = await widget.userProvider!
              .postImageUpload(
                  widget.userProvider!.psValueHolder!.loginUserId!,
                  PsConst.PLATFORM,
                  await Utils.getImageFileFromAssets(
                      pickedImage!, PsConfig.profileImageAize));
          if (_apiStatus.data != null) {
            setState(() {
              widget.userProvider!.user.data = _apiStatus.data;
            });
          }
          PsProgressDialog.dismissDialog();
        }
     // }
    }

    final Widget _imageWidget =
        widget.userProvider!.user.data!.userProfilePhoto != null
            ? PsNetworkImageWithUrlForUser(
                photoKey: '',
                imagePath: widget.userProvider!.user.data!.userProfilePhoto!,
                width: double.infinity,
                height: PsDimens.space200,
                boxfit: BoxFit.cover,
                onTap: () {},
              )
            : InkWell(
                onTap: () {},
                child: Ink(
                    child:
                       Image.file(File(pickedImage!.path), width: 100, height: 160)),
              );

    final Widget _editWidget = Container(
      child: IconButton(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: PsDimens.space2),
        iconSize: PsDimens.space24,
        icon: Icon(
          Icons.edit,
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: () async {
          if (await Utils.checkInternetConnectivity()) {
            requestGalleryPermission().then((bool status) async {
              if (status) {
                await _pickImage();
              }
            });
          } else {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return ErrorDialog(
                    message:
                        Utils.getString(context, 'error_dialog__no_internet'),
                  );
                });
          }
        },
      ),
      width: PsDimens.space32,
      height: PsDimens.space32,
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: PsColors.mainColor),
        color: PsColors.backgroundColor,
        borderRadius: BorderRadius.circular(PsDimens.space28),
      ),
    );

    final Widget _imageInCenterWidget = Positioned(
        top: 110,
        child: Stack(
          children: <Widget>[
            Container(
                width: 90,
                height: 90,
                child: CircleAvatar(
                  child: PsNetworkCircleImageForUser(
                    photoKey: '',
                    imagePath: widget.userProvider!.user.data!.userProfilePhoto,
                    width: double.infinity,
                    height: PsDimens.space200,
                    boxfit: BoxFit.cover,
                    onTap: () async {
                      if (await Utils.checkInternetConnectivity()) {
                        requestGalleryPermission().then((bool status) async {
                          if (status) {
                            await _pickImage();
                          }
                        });
                      } else {
                        showDialog<dynamic>(
                            context: context,
                            builder: (BuildContext context) {
                              return ErrorDialog(
                                message: Utils.getString(
                                    context, 'error_dialog__no_internet'),
                              );
                            });
                      }
                    },
                  ),
                )),
            Positioned(
              top: 1,
              right: 1,
              child: _editWidget,
            ),
          ],
        ));
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: PsDimens.space160,
          child: _imageWidget,
        ),
        Container(
          color: PsColors.white.withAlpha(100),
          width: double.infinity,
          height: PsDimens.space160,
        ),
        Container(
          width: double.infinity,
          height: PsDimens.space220,
        ),
        _imageInCenterWidget,
      ],
    );
  }
}

class _UserFirstCardWidget extends StatelessWidget {
  const _UserFirstCardWidget(
      {required this.userNameController,
      required this.emailController,
      required this.phoneController,
      required this.aboutMeController});
  final TextEditingController userNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController aboutMeController;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: PsDimens.space16,
          ),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__user_name'),
              hintText: Utils.getString(context, 'edit_profile__user_name'),
              textAboutMe: false,
              phoneInputType: false,
              textEditingController: userNameController),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__email'),
              hintText: Utils.getString(context, 'edit_profile__email'),
              textAboutMe: false,
              phoneInputType: false,
              textEditingController: emailController),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__phone'),
              textAboutMe: false,
              phoneInputType: true,
              hintText: Utils.getString(context, 'edit_profile__phone'),
              textEditingController: phoneController),
          PsTextFieldWidget(
              titleText: Utils.getString(context, 'edit_profile__about_me'),
              height: PsDimens.space120,
              keyboardType: TextInputType.multiline,
              textAboutMe: true,
              phoneInputType: false,
              hintText: Utils.getString(context, 'edit_profile__about_me'),
              textEditingController: aboutMeController),
        ],
      ),
    );
  }
}

