import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_dimens.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/transaction_detail.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/transaction_header.dart';

class NotiOrderDetailItemView extends StatelessWidget {
  const NotiOrderDetailItemView({
    Key? key,
    required this.transaction,
    required this.transactionDetail,
  
  }) : super(key: key);

  final TransactionHeader transaction;
  final TransactionDetail transactionDetail;

  @override
  Widget build(BuildContext context) {
    if ( transaction.transCode != null) {
      return GestureDetector(
            child: Container(
              color: PsColors.backgroundColor,
              margin: const EdgeInsets.only(top: PsDimens.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _NoOrderWidget(
                    transaction: transaction,
                  ),
                  const Divider(
                    height: PsDimens.space1,
                  ),
                  _TransactionTextWidget(
                    transaction: transaction,
                    transactionDetail: transactionDetail,
                  ),
                ],
              ),
            ),
          );
    } else {
      return Container();
    }
  }
}

class _NoOrderWidget extends StatelessWidget {
  const _NoOrderWidget({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  final TransactionHeader transaction;

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

class _TransactionTextWidget extends StatelessWidget {
  const _TransactionTextWidget({
    Key? key,
    required this.transaction,
    required this.transactionDetail,
  }) : super(key: key);

  final TransactionHeader transaction;
  final TransactionDetail transactionDetail;

  @override
  Widget build(BuildContext context) {
    const EdgeInsets _paddingEdgeInsetWidget = EdgeInsets.only(
      left: PsDimens.space16,
      right: PsDimens.space16,
      top: PsDimens.space16,
    );

     final Widget _itemNameWidget = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          Utils.getString(context, 'order_list__items'),
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.normal),
        ),
        Text(
          transactionDetail.productName ?? '-',
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.bodyLarge,
        ),          
      ],
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
          '${transaction.currencySymbol} ${Utils.getPriceFormat(transaction.balanceAmount!)}' ,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.normal),
        )
      ],
    );

    final Widget _paymentTextWidget = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          Utils.getString(context, 'order_list__payment'),
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.normal),
        ),
        Text(
          '${transaction.paymentMethod}',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.normal),
        )
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

    if (transaction.transCode != null) {
      return Column(
        children: <Widget>[
          Padding(
            padding: _paddingEdgeInsetWidget,
            child: _itemNameWidget,
          ),
          Padding(
            padding: _paddingEdgeInsetWidget,
            child: _totalAmountTextWidget,
          ),
          Padding(
            padding: _paddingEdgeInsetWidget,
            child: _paymentTextWidget,
          ),
          Padding(
            padding: _paddingEdgeInsetWidget,
            child: _statusTextWidget,
          ),
          const SizedBox(height: PsDimens.space32),
        ],
      );
    } else {
      return Container();
    }
  }
}
