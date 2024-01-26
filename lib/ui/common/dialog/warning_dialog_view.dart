import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_dimens.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';

class WarningDialog extends StatefulWidget {
  const WarningDialog({this.message, this.onPressed});
  final String? message;
  final Function? onPressed;
  @override
  _WarningDialogState createState() => _WarningDialogState();
}

class _WarningDialogState extends State<WarningDialog> {
  @override
  Widget build(BuildContext context) {
    return _NewDialog(widget: widget);
  }
}

class _NewDialog extends StatelessWidget {
  const _NewDialog({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final WarningDialog widget;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        shadowColor: PsColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PsDimens.space20),
          side: BorderSide(
            color: PsColors.mainColor,
            width: 2.0,
          ),
        ),
        child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: <Color>[
                  PsColors.mainColor.withOpacity(0.9),
                  PsColors.backgroundColor.withOpacity(0.6),
                ],
              ),
              borderRadius: const BorderRadius.all(Radius.circular(PsDimens.space20)),
            ),
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(PsDimens.space20)),
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                    child:Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                            height: 60,
                            width: double.infinity,
                            padding: const EdgeInsets.all(PsDimens.space8),
                            /*decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5)),
                    ),*/
                            child: Row(
                              children: <Widget>[
                                const SizedBox(
                                  width: PsDimens.space4,
                                ),
                                Icon(
                                  Icons.warning,
                                  color: PsColors.white,
                                ),
                                const SizedBox(
                                  width: PsDimens.space4,
                                ),
                                Text(Utils.getString(context, 'warning_dialog__warning'),
                                    textAlign: TextAlign.start,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(color: PsColors.white)),
                              ],
                            )),
                        const SizedBox(
                          height: PsDimens.space20,
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              left: PsDimens.space16,
                              right: PsDimens.space16,
                              top: PsDimens.space8,
                              bottom: PsDimens.space8),
                          child: Text(
                            widget.message!,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(
                          height: PsDimens.space20,
                        ),
                        Divider(
                          thickness: 2,
                          height: 2,
                          color: PsColors.mainColor,
                        ),
                        MaterialButton(
                          height: 50,
                          minWidth: double.infinity,
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onPressed!();
                          },
                          child: Text(
                            Utils.getString(context, 'dialog__ok'),
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(color: PsColors.mainColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )))));
  }
}
