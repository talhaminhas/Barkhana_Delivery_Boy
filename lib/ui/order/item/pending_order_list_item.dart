import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_config.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_dimens.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/transaction_header.dart';
import 'package:sembast/sembast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardOrderListItem extends StatelessWidget {
  const DashboardOrderListItem({
    Key? key,
    required this.transaction,
    this.animationController,
    this.animation,
    this.onTap,
    required this.scaffoldKey,
  }) : super(key: key);

  final TransactionHeader transaction;
  final Function? onTap;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    animationController!.forward();
    if (transaction.transCode != null) {
      return AnimatedBuilder(
          animation: animationController!,
          child: GestureDetector(
            onTap: onTap as void Function()?,
            child: Container(
              color: PsColors.backgroundColor,
              margin: const EdgeInsets.only(bottom: PsDimens.space8, top: PsDimens.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  /*_NoOrderWidget(
                    transaction: transaction,
                    scaffoldKey: scaffoldKey,
                  ),
                  const Divider(
                    height: PsDimens.space1,
                  ),*/
                  _TransactionTextWidget(
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
          '',//'${transaction.currencySymbol} ${Utils.getPriceFormat(transaction.balanceAmount!, valueHolder)}',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.normal, color: PsColors.mainColor),
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

    final Widget _callPhoneWidget = Container(
      child: IconButton(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: PsDimens.space2),
        iconSize: PsDimens.space24,
        icon: Icon(
          Icons.phone_in_talk,
          color: PsColors.white,
        ),
        onPressed: () async {
          if (await canLaunchUrl(Uri.parse('tel://${transaction.contactPhone}'))) {
            await launchUrl(Uri.parse('tel://${transaction.contactPhone}'));
          } else {
            throw 'Could not Call Phone Number 1';
          }
        },
      ),
      width: PsDimens.space32,
      height: PsDimens.space32,
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: PsColors.callPhoneColor),
        color: PsColors.callPhoneColor,
        borderRadius: BorderRadius.circular(PsDimens.space28),
      ),
    );

    if ( transaction.transCode != null) {
      final DateTime addedDate = DateTime.parse(transaction.updatedDate!);
      return
        Container(

          padding: _paddingEdgeInsetWidget,
          decoration: BoxDecoration(
            border: Border.all(
              color: Utils.hexToColor(transaction.transactionStatus!.colorValue!),
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: transaction.transactionStatus!.ordering == '3' ?
                          Shimmer.fromColors(
                            baseColor: Utils.hexToColor(transaction.transactionStatus!.colorValue!),
                            highlightColor: Colors.transparent,
                            child: Text(
                                transaction.transactionStatus!.title!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                    fontSize: 20,
                                    color: Utils.hexToColor(transaction.transactionStatus!.colorValue!)
                                )
                            )
                          )
                          :
                          Text(
                            transaction.transactionStatus!.ordering == '5' ? 'Order No :'
                              : transaction.transactionStatus!.title!,
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(
                                fontSize: 20,
                                  color: Utils.hexToColor(transaction.transactionStatus!.colorValue!)
                              )
                          )
                        ),
                        if (transaction.transactionStatus!.ordering == '2')
                        Container(
                          //margin: const EdgeInsets.only(right: 10),
                          child:
                          SpinKitThreeBounce(
                            color:  Utils.hexToColor(transaction.transactionStatus!.colorValue!),
                            size: PsDimens.space16,
                          ),
                        ),
                        if (transaction.transactionStatus!.ordering == '4')
                          Container(
                            //margin: const EdgeInsets.only(right: 10),
                            child:
                            SpinKitFadingCube(
                              color:  Utils.hexToColor(transaction.transactionStatus!.colorValue!),
                              size: PsDimens.space16,
                            ),
                          ),
                        if (transaction.transactionStatus!.ordering == '5')
                          Text(
                              transaction.transCode!,
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(
                                  fontSize: 20,
                                  color: Utils.hexToColor(transaction.transactionStatus!.colorValue!)
                              )
                          )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Divider(
                height: 2,
                thickness: 2,
                color: Utils.hexToColor(transaction.transactionStatus!.colorValue!),
              ),
              if (transaction.transactionStatus!.ordering == '5')
                Column(
                  children: <Widget>[
                    _TransactionNoTextWidget(
                      title: 'Delivery Date :',
                      transationInfoText: DateFormat('dd-MM-yyyy').format(addedDate),
                    )
                  ],
                )
              else
                _TransactionNoTextWidget(
                title: 'Order No :',
                transationInfoText: transaction.transCode!,
              ),
              _TransactionNoTextWidget(
                title: transaction.transactionStatus!.ordering == '2' ? 'Preparation Started :'
                  : transaction.transactionStatus!.ordering == '3' ? 'Ready Since :'
                    : transaction.transactionStatus!.ordering == '4' ? 'Delivery Started :'
                : 'Delivery Time :',
                transationInfoText: DateFormat('hh:mm a').format(addedDate),
              ),
              _TransactionNoTextWidget(
                title:
                'Customer Name :',
                transationInfoText: transaction.contactName!,
              ),
              _TransactionNoTextWidget(
                title:
                'Address :',
                transationInfoText: transaction.contactAddress!,
              ),

              const SizedBox(
                height: 10,
              ),
              if (transaction.transactionStatus!.ordering == '4')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // You can also use MainAxisAlignment.spaceAround
                  children: <Widget> [
                  Expanded (
                      //padding: const EdgeInsets.only(bottom: 10),
                      child:Container(
                        height: 60,
                        margin: const EdgeInsets.only(bottom: 10),
                        //width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final String url = 'https://www.google.com/maps/dir/?api=1&destination=${transaction.transLat},${transaction.transLng}';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              print('Could not launch $url');
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            primary: Utils.hexToColor(transaction.transactionStatus!.colorValue!),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)), // Set your desired border radius
                            ),
                          ),
                          child: const Text(
                            'Get Directions',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                  ),
                    const SizedBox(
                      width: 10,
                    ),
                    Padding (
                        padding: const EdgeInsets.only(bottom: 10),
                        child:Container(
                          height: 60,
                          //width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {//
                                if (await canLaunch('tel://${transaction.contactPhone}')) {
                                  await launch('tel://${transaction.contactPhone}');
                                } else {
                                  throw 'Could not launch Phone Number';
                                }
                              } catch (e) {
                                print('Error: $e');
                                // Handle the error appropriately (e.g., show a message to the user)
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              primary: Utils.hexToColor(transaction.transactionStatus!.colorValue!),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8.0)), // Set your desired border radius
                              ),
                            ),
                            child: const Icon(Icons.phone_in_talk, size: 30,),
                            //),
                          ),
                        )
                    ),
                  ],
                ),

              /*_TransactionNoTextWidget(
                title:
                'Phone Number :',
                transationInfoText: transaction.contactPhone!,
              ),*/
              /*Padding (
                  padding: const EdgeInsets.only(top: 10,bottom: 8),
                  child:Container(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {//
                          if (await canLaunch('tel://${transaction.contactPhone}')) {
                            await launch('tel://${transaction.contactPhone}');
                          } else {
                            throw 'Could not launch Phone Number';
                          }
                        } catch (e) {
                          print('Error: $e');
                          // Handle the error appropriately (e.g., show a message to the user)
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        primary: PsColors.mainColor, // Set your desired button color
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)), // Set your desired border radius
                        ),
                      ),
                      child: const Text(
                        'Call Customer',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  )
              ),*/

            ],
          ),
        );
    } else {
      return Container();
    }
  }
}
class _TransactionNoTextWidget extends StatelessWidget {
  const _TransactionNoTextWidget({
    Key? key,
    required this.transationInfoText,
    this.title,
  }) : super(key: key);

  final String transationInfoText;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: PsDimens.space12,
          right: PsDimens.space12,
          top: PsDimens.space12),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title!,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.normal,

            ),

          ),
          Text(
            transationInfoText ,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.normal),
          )
        ],
      ),
    );
  }
}