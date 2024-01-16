import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_dimens.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/transaction_header.dart';

class NearestOrderListItem extends StatelessWidget {
  const NearestOrderListItem({
    Key? key,
    required this.transaction,
    this.animationController,
    this.animation,
    this.onTap,
    required this.scaffoldKey,
    required this.onAcceptTap
  }) : super(key: key);

  final TransactionHeader transaction;
  final Function? onTap;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function onAcceptTap;

  @override
  Widget build(BuildContext context) {
    animationController!.forward();
    if ( transaction.transCode != null) {
      return AnimatedBuilder(
          animation: animationController! ,
          child: GestureDetector(
            onTap: onTap as void Function()?,
            child: Container(
              color: PsColors.backgroundColor,
              margin: const EdgeInsets.all(PsDimens.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _NoOrderWidget(
                    transaction: transaction,
                    scaffoldKey: scaffoldKey,
                  ),
                  _TransactionTextWidget(
                    transaction: transaction,
                    onAcceptTap: onAcceptTap,
                  ),
                ],
              ),
            ),
          ),
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: animation!,
              child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 100 * (1.0 - animation!.value), 0.0),
                  child: child),
            );
          });
    } else {
      return Container();
    }
  }
}

class _NoOrderWidget extends StatelessWidget {
  const _NoOrderWidget({
    Key? key,
    required this.transaction,
    required this.scaffoldKey,
  }) : super(key: key);

  final TransactionHeader transaction;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final Widget _textWidget = Text(
      Utils.getString(context, 'order_list__order_no'),      
      textAlign: TextAlign.left,
      style: Theme.of(context).textTheme.bodyLarge,
    );

    return Padding(
      padding: const EdgeInsets.only(
          left: PsDimens.space12,
          right: PsDimens.space4,
          top: PsDimens.space4,
          bottom: PsDimens.space4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
               Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Utils.hexToColor(
                        transaction.transactionStatus!.colorValue!)),
                ),
              ],
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
              children: <Widget>[ 
              const SizedBox(
                height: PsDimens.space8,
              ),
              _textWidget,
              Row(
                children: <Widget>[
                Text(
                    transaction.transCode!,      
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                const SizedBox(
                  width: PsDimens.space8,
                ),
                IconButton(
                  icon: const Icon(Icons.content_copy),
                  iconSize: 24,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: transaction.transCode!));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Theme.of(context).iconTheme.color,
                      content: Tooltip(
                        message: Utils.getString(context, 'transaction_detail__copy'),
                        child: Text(
                          Utils.getString(context, 'transaction_detail__copied_data'),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: PsColors.mainColor),
                        ),
                        showDuration: const Duration(seconds: 5),
                      ),
                    ));
                  },
                ),
              ],
            ),
          ],
        ),
      ])
    );
  }
}

class _TransactionTextWidget extends StatelessWidget {
  const _TransactionTextWidget({
    Key? key,
    required this.transaction,
    required this.onAcceptTap
  }) : super(key: key);

  final TransactionHeader transaction;
  final Function? onAcceptTap;

  @override
  Widget build(BuildContext context) {
    
    const EdgeInsets _paddingEdgeInsetWidget = EdgeInsets.only(
      left: PsDimens.space16,
      right: PsDimens.space16,
    );

    final Widget _viewDetailTextWidget = Text(
      Utils.getString(context, 'nearest_order__order_details'),
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.underline,
        ),
    );

    if (
        transaction.transCode != null &&
        transaction.shop != null) {
      return Padding(
            padding: _paddingEdgeInsetWidget,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            transaction.shop!.name!,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: PsDimens.space4),
          Text(
            transaction.shop!.address1!,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
          ),
          const SizedBox(height: PsDimens.space16),
          Text(
           'to',
            style: Theme.of(context)
                .textTheme
                .bodyLarge,
          ),
          const SizedBox(height: PsDimens.space8),
          Text(
            transaction.contactName!,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: PsDimens.space4),
          Text(
            transaction.contactAddress!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: PsDimens.space8),
          const Divider(
            height: PsDimens.space1,
          ),
          const SizedBox(height: PsDimens.space8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                _viewDetailTextWidget,
                InkWell(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(
                      top: PsDimens.space4,
                      bottom: PsDimens.space4,
                      right: PsDimens.space12,
                      left: PsDimens.space12),
                  decoration: BoxDecoration(
                      color: PsColors.mainColor,
                      border: Border.all(color: PsColors.mainLightShadowColor),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(PsDimens.space4))),
                  child: Text(
                    'Accept',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: PsColors.white),
                  ),
                ),
                onTap: onAcceptTap as void Function()?,
              ),
            ],
          ),
          const SizedBox(
            height: PsDimens.space16,
          )
        ],
      ));
    } else {
      return Container();
    }
  }
}
