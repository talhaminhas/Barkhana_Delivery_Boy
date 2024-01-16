import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_config.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_dimens.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/transaction_header.dart';

class OrderListItem extends StatelessWidget {
  const OrderListItem({
    Key? key,
    required this.transaction,
    this.animationController,
    this.animation,
    this.onTap,
    required this.scaffoldKey,
  }) : super(key: key);

  final TransactionHeader transaction;
  final Function ?onTap;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    animationController!.forward();
    if ( transaction.transCode != null) {
      return AnimatedBuilder(
          animation: animationController!,
          child: GestureDetector(
            onTap: onTap as void Function()?,
            child: Container(
              color: PsColors.backgroundColor,
              margin: const EdgeInsets.only(top: PsDimens.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _NoOrderWidget(
                    transaction: transaction,
                    scaffoldKey: scaffoldKey,
                  ),
                  const Divider(
                    height: PsDimens.space1,
                  ),
                  _OrderTextWidget(
                    transaction: transaction,
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
                child: child,
              ),
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
      Utils.getString(context, 'order_list__order_no') +
              ' : ${transaction.transCode}' ,
      textAlign: TextAlign.left,
      style: Theme.of(context).textTheme.titleSmall,
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
              const Icon(
                Icons.offline_pin,
                size: 24,
              ),
              const SizedBox(
                width: PsDimens.space8,
              ),
              _textWidget,
            ],
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
    );
  }
}

class _OrderTextWidget extends StatelessWidget {
  const _OrderTextWidget({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  final TransactionHeader transaction;

  @override
  Widget build(BuildContext context) {
    const EdgeInsets _paddingEdgeInsetWidget = EdgeInsets.only(
      left: PsDimens.space16,
      right: PsDimens.space16,
      top: PsDimens.space8,
    );

    final Widget _totalAmountTextWidget = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          Utils.getString(context, 'transaction_list__total_amount') + '  :',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.normal),
        ),
        Text(
          '${transaction.currencySymbol} ${Utils.getPriceFormat(transaction.balanceAmount!)}',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.normal, color: PsColors.mainColor),
        )
      ],
    );

    final Widget _shopNameTextWidget = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          Utils.getString(context, 'order_list__shop_name'),
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.normal),
        ),
        if (PsConfig.isMultiRestaurant)
          Text(
            '${transaction.shop!.name}',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.normal, color: PsColors.mainColor),
          )
        else
          Container()
      ],
    );

    final Widget _statusTextWidget = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          Utils.getString(context, 'transaction_detail__status'),
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.normal),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(
              top: PsDimens.space4,
              bottom: PsDimens.space4,
              right: PsDimens.space12,
              left: PsDimens.space12),
          decoration: BoxDecoration(
              color: Utils.hexToColor(transaction.transactionStatus!.colorValue!),
              border: Border.all(color: PsColors.mainLightShadowColor),
              borderRadius:
                  const BorderRadius.all(Radius.circular(PsDimens.space8))),
          child: Text(
            transaction.transactionStatus!.title ?? '-',
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: PsColors.black),
          ),
        )
      ],
    );

    final Widget _viewDetailTextWidget = Text(
      Utils.getString(context, 'transaction_detail__view_details'),
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.underline,
          ),
    );

    if ( transaction.transCode != null) {
      return Column(
        children: <Widget>[
          Padding(
            padding: _paddingEdgeInsetWidget,
            child: _totalAmountTextWidget,
          ),
          if (PsConfig.isMultiRestaurant)
            Padding(
              padding: _paddingEdgeInsetWidget,
              child: _shopNameTextWidget,
            )
          else
            Container(),
          Padding(
            padding: _paddingEdgeInsetWidget,
            child: _statusTextWidget,
          ),
          Padding(
            padding: _paddingEdgeInsetWidget,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _viewDetailTextWidget,
              ],
            ),
          ),
          const SizedBox(
            height: PsDimens.space8,
          )
        ],
      );
    } else {
      return Container();
    }
  }
}