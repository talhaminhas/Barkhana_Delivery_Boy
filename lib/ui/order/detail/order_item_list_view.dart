import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:flutterrtdeliveryboyapp/api/common/ps_resource.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_config.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_dimens.dart';
import 'package:flutterrtdeliveryboyapp/constant/route_paths.dart';
import 'package:flutterrtdeliveryboyapp/provider/point/point_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/shop/shop_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/shop_info/shop_info_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/transaction/transaction_detail_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/transaction/transaction_header_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/transaction_status/transaction_status_provider.dart';
import 'package:flutterrtdeliveryboyapp/repository/point_repository.dart';
import 'package:flutterrtdeliveryboyapp/repository/shop_info_repository.dart';
import 'package:flutterrtdeliveryboyapp/repository/tansaction_detail_repository.dart';
import 'package:flutterrtdeliveryboyapp/repository/transaction_header_repository.dart';
import 'package:flutterrtdeliveryboyapp/repository/transaction_status_repository.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/dialog/warning_dialog_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/ps_message_page.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/ps_ui_widget.dart';
import 'package:flutterrtdeliveryboyapp/ui/map/polyline_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/noti/detail/noti_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/order/status/order_status_list_item.dart';
import 'package:flutterrtdeliveryboyapp/utils/ps_progress_dialog.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/common/ps_value_holder.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/holder/intent_holder/shop_data_intent_holer.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/holder/trans_status_update_holder.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/shop.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/shop_info.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/transaction_header.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:slider_button/slider_button.dart';
import 'package:page_transition/page_transition.dart';
import '../../../viewobject/transaction_status.dart';
import 'order_item_view.dart';

class OrderItemListView extends StatefulWidget {
  const OrderItemListView({
    Key? key,
    required this.intentTransaction,
  }) : super(key: key);

  final TransactionHeader intentTransaction;

  @override
  _OrderItemListViewState createState() => _OrderItemListViewState();
}

class _OrderItemListViewState extends State<OrderItemListView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  TransactionDetailRepository? repo1;
  TransactionDetailProvider? _transactionDetailProvider;
  AnimationController? animationController;
  Animation<double> ?animation;
  PsValueHolder ?valueHolder;
  ShopInfoProvider? shopInfoProvider;
  TransactionStatusProvider ?transactionStatusProvider;
  TransactionStatusRepository? transactionStatusRepository;
  TransactionHeaderProvider? transactionHeaderProvider;
  TransactionHeaderRepository? transactionHeaderRepository;
  PointProvider? pointProvider;
  PointRepository? pointRepository;
  ShopInfoRepository ?shopInfoRepository;
  TransactionHeader? transaction;
  Position? _currentPosition;

  @override
  void dispose() {
    animationController!.dispose();
    animation = null;
    super.dispose();
  }

  // @override
  // void didUpdateWidget(Widget oldWidget) {
  //   super.didUpdateWidget(oldWidget);

  //   setState(() {
  //     // _lastKnownPosition = null;
  //     _currentPosition = null;
  //   });
  // }

  dynamic _initCurrentLocation() {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            forceAndroidLocationManager: !true)
        .then((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
        if (_currentPosition != null) {
          pointProvider!.loadAllPoint(
              _currentPosition!.latitude.toString(),
              _currentPosition!.longitude.toString(),
              // '16.797461','96.127490',
              transaction!.transLat!,
              transaction!.transLng!);
        }
      }
    }).catchError((Object e) {
      //
    });
  }
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;
  bool isFinished = false;
  void checkConnection() {
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
      if (isConnectedToInternet && PsConfig.showAdMob) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    transaction = widget.intentTransaction;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _transactionDetailProvider!.nextTransactionDetailList(transaction!);
      }
    });

    animationController =
        AnimationController(duration: PsConfig.animation_duration, vsync: this);

    super.initState();
  }

  dynamic updateTransactionHeader(TransactionHeader transactionHeader) {
    setState(() {
      transaction = transactionHeader;
    });
  }

  dynamic data;
  LatLng? _latlng;
  final double zoom = 15;
  final MapController mapController = MapController();
  @override
  Widget build(BuildContext context) {
    _latlng = LatLng(
        double.parse(
            widget.intentTransaction.transLat!),
        double.parse(
            widget.intentTransaction.transLng!));
    if (!isConnectedToInternet && PsConfig.showAdMob) {
      print('loading ads....');
      checkConnection();
    }
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

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    repo1 = Provider.of<TransactionDetailRepository>(context);
    pointRepository = Provider.of<PointRepository>(context);
    transactionHeaderRepository =
        Provider.of<TransactionHeaderRepository>(context);
    transactionStatusRepository =
        Provider.of<TransactionStatusRepository>(context);
    shopInfoRepository = Provider.of<ShopInfoRepository>(context);
    valueHolder = Provider.of<PsValueHolder?>(context);
    return WillPopScope(
        onWillPop: _requestPop,
        child: MultiProvider(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<TransactionDetailProvider>(
              lazy: false,
              create: (BuildContext context) {
                final TransactionDetailProvider provider =
                    TransactionDetailProvider(
                        repo: repo1!, psValueHolder: valueHolder);
                provider.loadTransactionDetailList(transaction!);
                _transactionDetailProvider = provider;
                return provider;
              },
            ),
            ChangeNotifierProvider<TransactionStatusProvider>(
                lazy: false,
                create: (BuildContext context) {
                  transactionStatusProvider = TransactionStatusProvider(
                      repo: transactionStatusRepository!);
                  transactionStatusProvider!.loadTransactionStatusList();
                  return transactionStatusProvider!;
                }),
            ChangeNotifierProvider<TransactionHeaderProvider>(
                lazy: false,
                create: (BuildContext context) {
                  transactionHeaderProvider = TransactionHeaderProvider(
                      repo: transactionHeaderRepository!,
                      psValueHolder: valueHolder);
                  return transactionHeaderProvider!;
                }),
            ChangeNotifierProvider<PointProvider>(
                lazy: false,
                create: (BuildContext context) {
                  pointProvider = PointProvider(
                      repo: pointRepository!, psValueHolder: valueHolder);
                  _initCurrentLocation();
                  return pointProvider!;
                }),
            ChangeNotifierProvider<ShopInfoProvider>(
                lazy: false,
                create: (BuildContext context) {
                  shopInfoProvider = ShopInfoProvider(
                      repo: shopInfoRepository!,
                      ownerCode: 'CheckoutContainerView',
                      psValueHolder: valueHolder!);
                  if (PsConfig.isMultiRestaurant) {
                    shopInfoProvider!
                        .loadShopInfoById(widget.intentTransaction.shopId!);
                  } else {
                    shopInfoProvider!.loadShopInfo();
                  }
                  return shopInfoProvider!;
                }),
          ],
          child: Consumer<TransactionDetailProvider>(builder:
              (BuildContext context, TransactionDetailProvider provider,
                  Widget? child) {
            return Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarIconBrightness: Utils.getBrightnessForAppBar(context),
                ), 
                iconTheme: Theme.of(context)
                    .iconTheme
                    .copyWith(color: PsColors.mainColorWithWhite),
                title: Text(
                  Utils.getString(context, 'order_detail__title'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: PsColors.mainColorWithWhite),
                ),
                elevation: 0,
              ),
              body: Column(
                  children: <Widget>[
                    Expanded(child:
                    Stack(children: <Widget>[
                      RefreshIndicator(
                        child: CustomScrollView(
                            controller: _scrollController,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            slivers: <Widget>[
                              SliverToBoxAdapter(
                                child: Container(
                                  height: 50,
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 0, left: 0, bottom: 10),
                                  child: ClipRRect(
                                    child: Container(
                                      height: 250,
                                      child: FlutterMap(
                                        mapController: mapController,
                                        options: MapOptions(
                                          center: _latlng,
                                          zoom: zoom,
                                        ),
                                        children: <Widget>[
                                          TileLayer(
                                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                            //tileProvider: CachedNetworkTileProvider(),
                                          ),
                                          MarkerLayer(markers: <Marker>[
                                            Marker(
                                              width: 80.0,
                                              height: 80.0,
                                              point: _latlng!,
                                              builder: (BuildContext context)
                                              {
                                                return Container(
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.location_on,
                                                      color: PsColors.redColor,
                                                    ),
                                                    iconSize: 45,
                                                    onPressed: () {
                                                      launchGoogleMaps(_latlng!);
                                                    },
                                                  ),
                                                );
                                              },
                                            )
                                          ])
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              /*SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: PsDimens.space8, right: PsDimens.space8),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          width: PsDimens.space140,
                                          height: PsDimens.space140,
                                          padding:
                                          const EdgeInsets.all(PsDimens.space8),
                                          child: InkWell(
                                            child: whiteCartWidget(
                                              context,
                                              Utils.getString(context,
                                                  'transaction_list__total_amount'),
                                              '${transaction!.currencySymbol} ${Utils.getPriceFormat(transaction!.balanceAmount!)}',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          width: PsDimens.space140,
                                          height: PsDimens.space140,
                                          padding:
                                          const EdgeInsets.all(PsDimens.space8),
                                          child: InkWell(
                                            child: whiteCartWidget(
                                              context,
                                              Utils.getString(
                                                  context, 'order_detail__payment'),
                                              '${transaction!.paymentMethod}',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),*/
                             /* SliverToBoxAdapter(
                                child: Container(
                                  color: PsColors.backgroundColor,
                                  margin: const EdgeInsets.only(
                                      top: PsDimens.space8,
                                      bottom: PsDimens.space16,
                                      left: PsDimens.space16,
                                      right: PsDimens.space16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      _ShopInfoWidget(
                                          shopId:
                                          widget.intentTransaction.shopId ?? ''),
                                    ],
                                  ),
                                ),
                              ),*/
                              SliverToBoxAdapter(
                                child: Container(
                                  color: PsColors.backgroundColor,
                                  margin: const EdgeInsets.only(
                                      top: PsDimens.space8,
                                      bottom: PsDimens.space16,
                                      left: PsDimens.space16,
                                      right: PsDimens.space16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      _OrderTextWidget(
                                          transaction: transaction!,
                                          transactionStatusProvider:
                                          transactionStatusProvider!,
                                          transactionHeaderProvider:
                                          transactionHeaderProvider!,
                                          updateTransactionHeader:
                                          updateTransactionHeader,
                                          shopInfoProvider: shopInfoProvider!),
                                    ],
                                  ),
                                ),
                              ),
                              /*SliverToBoxAdapter(
                            child: Container(
                                height: 500,
                                width: double.infinity,
                                child: PolylinePage(
                                  pointProvider: pointProvider!,
                                  tranLatLng: LatLng(
                                      double.parse(
                                          widget.intentTransaction.transLat!),
                                      double.parse(
                                          widget.intentTransaction.transLng!)),
                                ))),*/
                              SliverToBoxAdapter(
                                child: _NoOrderWidget(
                                    transaction: transaction!,
                                    valueHolder: valueHolder!,
                                    scaffoldKey: scaffoldKey),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                    if (provider.transactionDetailList.data != null ||
                                        provider
                                            .transactionDetailList.data!.isNotEmpty) {
                                      final int count =
                                          provider.transactionDetailList.data!.length;
                                      return OrderItemView(
                                        animationController: animationController!,
                                        animation: Tween<double>(begin: 0.0, end: 1.0)
                                            .animate(
                                          CurvedAnimation(
                                            parent: animationController!,
                                            curve: Interval((1 / count) * index, 1.0,
                                                curve: Curves.fastOutSlowIn),
                                          ),
                                        ),
                                        transaction: provider
                                            .transactionDetailList.data![index],
                                      );
                                    } else {
                                      return null;
                                    }
                                  },
                                  childCount:
                                  provider.transactionDetailList.data!.length,
                                ),
                              ),
                              SliverToBoxAdapter(
                                  child:
                                  Container(
                                    height: 90,
                                  )
                              ),
                            ]),
                        onRefresh: () {
                          return provider.resetTransactionDetailList(transaction!);
                        },
                      ),
                      Positioned(
                          top: 0, right: 0,left: 0,
                          child: Container(
                              decoration: BoxDecoration(
                                color: Utils.hexToColor(transaction!.transactionStatus!.colorValue!),
                                    //.withOpacity(0.6),
                                /*borderRadius: const BorderRadius.only(topRight: Radius.circular(8),
                                    topLeft: Radius.circular(8)),*/
                              ),
                              //margin: const EdgeInsets.only(top: 8,right: 8,left: 8),
                              //width: 200.0,
                              height: 50,
                              child: Center(
                                child: /*Shimmer.fromColors(
                                  baseColor: Colors.white,
                                  highlightColor: Colors.red,
                                  child: */Text(
                                    transaction!.transactionStatus!.title ?? '-',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight.bold,
                                      color: Colors.white
                                    ),
                                  //),
                                ),
                              )
                          )
                      ),
                      PSProgressIndicator(provider.transactionDetailList.status),
                      if(int.parse(transaction!.transactionStatus!.ordering!) != 0
                      && int.parse(transaction!.transactionStatus!.ordering!) != 5)
                      Positioned(
                          bottom: 0,right: 0,left: 0,
                          child: Container(
                              child:SliderButton(
                                width: double.infinity,
                                radius: 0,
                                action: () async{
                                  //change status to picked up
                                  String updatedStatusOrdering = '4';
                                  //change status to delivered
                                  if(int.parse(transaction!.transactionStatus!.ordering!) == 4)
                                    updatedStatusOrdering = '5';
                                  for (TransactionStatus transactionStatus in transactionStatusProvider!
                                      .transactionStatusList.data!) {
                                        if (transactionStatus.ordering! == updatedStatusOrdering) {
                                          final TransStatusUpdateHolder paymentStatusHolder =
                                          TransStatusUpdateHolder(
                                            transStatusId: transactionStatus.id,
                                            transactionsHeaderId: transaction?.id,
                                          );
                                          transactionHeaderProvider
                                              ?.postTransactionStatusUpdate(
                                              paymentStatusHolder.toMap());
                                          break;
                                        }
                                  }
                                  if (updatedStatusOrdering == '4')
                                  {
                                    await Navigator.pushNamed(context, RoutePaths.messagePage,
                                        arguments: 'Starting Delivery');
                                    launchGoogleMaps(_latlng!);
                                  }
                                  else
                                    await Navigator.pushNamed(context, RoutePaths.messagePage,
                                        arguments: 'Order Delivered');
                                  _requestPop();
                                  return true;
                                },
                                label: Align(
                                  alignment: const Alignment(0.3, 0.0),
                                  child:Text(
                                    int.parse(transaction!.transactionStatus!.ordering!) < 4 ?
                                    'Slide To Start Delivery' :
                                    'Slide To Confirm Delivered',
                                    style: const TextStyle(
                                      color: Color(0xff4a4a4a),
                                      fontWeight: FontWeight.bold, // Set fontWeight to bold
                                      fontSize: 18,
                                    ),
                                  ),
                                ),

                                icon: Center(
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Utils.hexToColor(transaction!.transactionStatus!.colorValue!),
                                      size: 30.0,
                                    )),

                                //width: double.infinity,
                                //radius: 20,
                                buttonColor: PsColors.mainColor,
                                backgroundColor: PsColors.mainColor.withOpacity(0.6),
                                highlightedColor: Utils.hexToColor(transaction!.transactionStatus!.colorValue!),
                                baseColor: PsColors.white,
                              )
                          ),
                      ),
                    ]),
                    ),
                    /*Container(
                      //margin: EdgeInsets.all(20),
                      *//*decoration: BoxDecoration(
                        color: PsColors.mainColor,  // Set your desired background color here
                        borderRadius: BorderRadius.circular(10),  // Optional: Set border radius
                      ),*//*
                      child: *//*SwipeableButtonView(
                        buttonText: 'START DELIVERY',
                        buttonWidget: Container(
                          child: const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                        ),
                        activeColor: PsColors.mainColor,
                        isFinished: isFinished,
                        onWaitingProcess: () {
                          for (TransactionStatus transactionStatus in transactionStatusProvider!
                              .transactionStatusList.data!) {
                            // Change status to picked up
                            if (int.parse(transactionStatus.ordering!) == 4) {
                              final TransStatusUpdateHolder paymentStatusHolder =
                              TransStatusUpdateHolder(
                                transStatusId: transactionStatus.id,
                                transactionsHeaderId: transaction?.id,
                              );
                              transactionHeaderProvider
                                  ?.postTransactionStatusUpdate(paymentStatusHolder.toMap());
                              break;
                            }
                          }

                          Future.delayed(const Duration(seconds: 2), () {
                            setState(() {
                              isFinished = true;
                            });
                          });
                        },
                        onFinish: () async {
                          await Navigator.pushNamed(context, RoutePaths.messagePage,
                              arguments: 'Order Picked Up');
                          setState(() {
                            isFinished = false; // For reverse ripple effect animation
                          });
                        },
                      )*//*

                    ),*/



                  ]
              )

            );
          }),
        ));
  }

  Future<void> launchGoogleMaps(LatLng latlng) async {
    final String url = 'https://www.google.com/maps/dir/?api=1&destination=${latlng.latitude},${latlng.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}

class _ShopInfoWidget extends StatefulWidget {
  const _ShopInfoWidget({required this.shopId});
  final String shopId;
  @override
  __ShopInfoWidgetState createState() => __ShopInfoWidgetState();
}

class __ShopInfoWidgetState extends State<_ShopInfoWidget> {
  @override
  Widget build(BuildContext context) {
    const EdgeInsets _paddingEdgeInsetWidget = EdgeInsets.only(
        left: PsDimens.space16, right: PsDimens.space16, top: PsDimens.space16);
    return Consumer<ShopInfoProvider>(builder:
        (BuildContext context, ShopInfoProvider provider, Widget? child) {
      if (
          provider.shopInfo.data != null) {
        return Column(
          children: <Widget>[
            Padding(
              padding: _paddingEdgeInsetWidget,
              child: Container(),
            ),
            _ImageAndTextWidget(
                data: provider.shopInfo.data,
                shopInfoProvider: provider,
                shopId: widget.shopId),
            const SizedBox(height: PsDimens.space16)
          ],
        );
      } else {
        return Container();
      }
    });
  }
}

Widget whiteCartWidget(BuildContext context, String title, String text) {
  return Container(
      width: PsDimens.space140,
      child: Container(
        decoration: BoxDecoration(
          color: PsColors.whiteColorWithBlack,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(height: 1.3)),
            const SizedBox(height: PsDimens.space8),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold, color: PsColors.mainColor),
            )
          ],
        ),
      ));
}

class _OrderTextWidget extends StatefulWidget {
  const _OrderTextWidget(
      {Key? key,
      required this.transaction,
      required this.transactionStatusProvider,
      required this.transactionHeaderProvider,
      required this.updateTransactionHeader,
      required this.shopInfoProvider})
      : super(key: key);

  final TransactionHeader transaction;
  final TransactionStatusProvider transactionStatusProvider;
  final TransactionHeaderProvider transactionHeaderProvider;
  final Function updateTransactionHeader;
  final ShopInfoProvider shopInfoProvider;

  @override
  __OrderTextWidgetState createState() => __OrderTextWidgetState();
}

class __OrderTextWidgetState extends State<_OrderTextWidget> {
  @override
  Widget build(BuildContext context) {
    const EdgeInsets _paddingEdgeInsetWidget = EdgeInsets.only(
      left: PsDimens.space8,
      right: PsDimens.space8,
      top: PsDimens.space8,
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
          if (await canLaunchUrl(Uri.parse('tel://${widget.transaction.contactPhone}'))) {
            await launchUrl(Uri.parse('tel://${widget.transaction.contactPhone}'));
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

    final Widget _statusTextWidget = Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              Utils.getString(context, 'order_detail__order_status'),
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.normal),
            ),
          ],
        ),
        const SizedBox(height: PsDimens.space8),
        InkWell(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(
                top: PsDimens.space8,
                bottom: PsDimens.space8,
                right: PsDimens.space8,
                left: PsDimens.space8),
            decoration: BoxDecoration(
                color: Utils.hexToColor(
                    widget.transaction.transactionStatus!.colorValue!),
                border: Border.all(color: PsColors.mainLightShadowColor),
                borderRadius:
                    const BorderRadius.all(Radius.circular(PsDimens.space8))),
            child: Text(
              widget.transaction.transactionStatus!.title ?? '-',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: PsColors.black),
            ),
          ),
          onTap: () {
            showDialog<dynamic>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      Utils.getString(
                          context, 'order_detail__choose_trans_status'),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.normal),
                    ),
                    content: SetupAlertDialoadContainer(
                        transactionStatusProvider:
                            widget.transactionStatusProvider,
                        transactionHeaderProvider:
                            widget.transactionHeaderProvider,
                        animationController: animationController,
                        headerId: widget.transaction.id!,
                        tranOrdering:
                            widget.transaction.transactionStatus!.ordering!,
                        updateTransactionHeader:
                            widget.updateTransactionHeader),
                  );
                });
          },
        ),
      ],
    );

    if ( widget.transaction.transCode != null)
      return
          Container(
            padding: _paddingEdgeInsetWidget,
            decoration: BoxDecoration(
              border: Border.all(
                color: PsColors.mainColor, // Border color
                width: 2.0,          // Border width
              ),
              borderRadius: BorderRadius.circular(10.0), // Rounded corners
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
                          const SizedBox(
                            width: PsDimens.space8,
                          ),
                          Icon(
                            Icons.perm_identity_outlined,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(
                            width: PsDimens.space8,
                          ),
                          Expanded(
                            child: Text(
                                'Customer Details',
                                textAlign: TextAlign.left,
                                style: Theme.of(context).textTheme.titleMedium),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                ),
                /*const SizedBox(
                  height: 5,
                ),*/
                _TransactionNoTextWidget(
                  title:
                  'Name :',
                  transationInfoText: widget.transaction.contactName!,
                ),
                _TransactionNoTextWidget(
                  title:
                  'Address :',
                  transationInfoText: widget.transaction.contactAddress!,
                ),
                _TransactionNoTextWidget(
                  title:
                  'Phone Number :',
                  transationInfoText: widget.transaction.contactPhone!,
                ),
                const SizedBox(
                  height: 10,
                ),
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
                              final String url = 'https://www.google.com/maps/dir/?api=1&destination='
                                  '${widget.transaction.transLat},${widget.transaction.transLng}';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                print('Could not launch $url');
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              primary: PsColors.mainColor,
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
                                if (await canLaunch('tel://${widget.transaction.contactPhone}')) {
                                  await launch('tel://${widget.transaction.contactPhone}');
                                } else {
                                  throw 'Could not launch Phone Number';
                                }
                              } catch (e) {
                                print('Error: $e');
                                // Handle the error appropriately (e.g., show a message to the user)
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              primary: PsColors.mainColor,
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
                /*Padding(
                  padding: const EdgeInsets.only(top: PsDimens.space8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const SizedBox(width: PsDimens.space16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.transaction.contactName!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontWeight: FontWeight.normal),
                            ),
                            const SizedBox(height: PsDimens.space8),
                            Text(
                              widget.transaction.contactAddress!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      _callPhoneWidget
                    ],
                  ),
                )*/
              ],
            ),
          );
    else
      return Container();
  }
}

class _ImageAndTextWidget extends StatefulWidget {
  const _ImageAndTextWidget(
      {Key? key,
      required this.data,
      required this.shopInfoProvider,
      required this.shopId})
      : super(key: key);

  final ShopInfo? data;
  final ShopInfoProvider? shopInfoProvider;
  final String shopId;
  @override
  __ImageAndTextWidgetState createState() => __ImageAndTextWidgetState();
}

class __ImageAndTextWidgetState extends State<_ImageAndTextWidget> {
  @override
  Widget build(BuildContext context) {
    final Widget _imageWidget = PsNetworkCircleImage(
      photoKey: '',
      imagePath: widget.data!.defaultPhoto!.imgPath,
      width: PsDimens.space76,
      height: PsDimens.space80,
      boxfit: BoxFit.cover,
      onTap: () {
        if (PsConfig.isMultiRestaurant) {
          Navigator.pushNamed(context, RoutePaths.shop_info_container,
              arguments: widget.shopId);
        } else {
          Navigator.pushNamed(context, RoutePaths.single_shop_info_container,
              arguments: '');
        }
      },
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          width: PsDimens.space16,
        ),
        _imageWidget,
        const SizedBox(
          width: PsDimens.space12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: PsDimens.space16),
              Text(widget.data!.name!,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(
                height: PsDimens.space8,
              ),
              InkWell(
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.phone,
                    ),
                    const SizedBox(
                      width: PsDimens.space8,
                    ),
                    Text(
                      widget.data!.aboutPhone1!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                onTap: () async {
                  if (await canLaunchUrl(Uri.parse('tel://${widget.data!.aboutPhone1}'))) {
                    await launchUrl(Uri.parse('tel://${widget.data!.aboutPhone1}'));
                  } else {
                    throw 'Could not Call Phone Number 1';
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SetupAlertDialoadContainer extends StatefulWidget {
  const SetupAlertDialoadContainer({
    required this.transactionStatusProvider,
    required this.transactionHeaderProvider,
    required this.animationController,
    required this.headerId,
    required this.updateTransactionHeader,
    required this.tranOrdering,
  });
  final TransactionStatusProvider transactionStatusProvider;
  final TransactionHeaderProvider transactionHeaderProvider;
  final AnimationController? animationController;
  final String headerId;
  final String tranOrdering;
  final Function updateTransactionHeader;

  @override
  _SetupAlertDialoadContainerState createState() =>
      _SetupAlertDialoadContainerState();
}

class _SetupAlertDialoadContainerState
    extends State<SetupAlertDialoadContainer> {
  @override
  Widget build(BuildContext context) {
    if (
       // widget.transactionStatusProvider.transactionStatusList == null &&
        widget.transactionStatusProvider.transactionStatusList.data!.isEmpty) {
      return Container();
    } else {
      return Container(
        height: 300, // Change as per your requirement
        width: 300.0, // Change as per your requirement
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget
              .transactionStatusProvider.transactionStatusList.data!.length,
          itemBuilder: (BuildContext context, int index) {
            return OrderStatusListItem(
              transactionStatus: widget
                  .transactionStatusProvider.transactionStatusList.data![index],
              onTap: () async {
                if (int.parse(widget.transactionStatusProvider
                        .transactionStatusList.data![index].ordering!) <
                    int.parse(widget.tranOrdering)) {
                  showDialog<dynamic>(
                      context: context,
                      builder: (BuildContext context) {
                        return WarningDialog(
                          message: Utils.getString(
                              context, 'warning_dialog__status'),
                          onPressed: () {},
                        );
                      });
                } else if (int.parse(widget.transactionStatusProvider
                        .transactionStatusList.data![index].ordering!) ==
                    int.parse(widget.tranOrdering)) {
                  Navigator.of(context).pop();
                } else {
                  await PsProgressDialog.showDialog(context);
                  final TransStatusUpdateHolder paymentStatusHolder =
                      TransStatusUpdateHolder(
                          transStatusId: widget.transactionStatusProvider
                              .transactionStatusList.data![index].id,
                          transactionsHeaderId: widget.headerId);
                  final PsResource<TransactionHeader> _apiStatus = await widget
                      .transactionHeaderProvider
                      .postTransactionStatusUpdate(paymentStatusHolder.toMap());

                  PsProgressDialog.dismissDialog();
                  if (_apiStatus.data != null) {
                    setState(() {
                      widget.updateTransactionHeader(_apiStatus.data);
                    });
                  }
                  Navigator.of(context).pop();
                }
              },
            );
          },
        ),
      );
    }
  }
}

class _NoOrderWidget extends StatelessWidget {
  const _NoOrderWidget({
    Key? key,
    required this.transaction,
    required this.valueHolder,
    this.scaffoldKey,
  }) : super(key: key);

  final TransactionHeader transaction;
  final PsValueHolder valueHolder;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    const Widget _dividerWidget = Divider(
      height: PsDimens.space2,
    );
    return Container(
        color: PsColors.backgroundColor,
        margin: const EdgeInsets.only(top: PsDimens.space8),
        padding: const EdgeInsets.only(
          left: PsDimens.space12,
          right: PsDimens.space12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: PsDimens.space8,
                  right: PsDimens.space12,
                  top: PsDimens.space12,
                  bottom: PsDimens.space12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        const SizedBox(
                          width: PsDimens.space8,
                        ),
                        Icon(
                          Octicons.note,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(
                          width: PsDimens.space8,
                        ),
                        Expanded(
                          child: Text('Order No :',
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        Text(
                            transaction.transCode!,
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _dividerWidget,
            _TransactionNoTextWidget(
              transationInfoText: transaction.totalItemCount!,
              title:
              '${Utils.getString(context, 'transaction_detail__total_item_count')} :',
            ),
            _TransactionNoTextWidget(
              transationInfoText:
              '${transaction.currencySymbol} ${Utils.getPriceFormat(transaction.totalItemAmount!)}',
              title:
              '${Utils.getString(context, 'transaction_detail__total_item_price')} :',
            ),
            _TransactionNoTextWidget(
              transationInfoText: transaction.discountAmount == '0'
                  ? '-'
                  : '${transaction.currencySymbol} ${Utils.getPriceFormat(transaction.discountAmount!)}',
              title:
              '${Utils.getString(context, 'transaction_detail__discount')} :',
            ),
            _TransactionNoTextWidget(
              transationInfoText: transaction.cuponDiscountAmount == '0'
                  ? '-'
                  : '${transaction.currencySymbol} ${Utils.getPriceFormat(transaction.cuponDiscountAmount!)}',
              title:
              '${Utils.getString(context, 'transaction_detail__coupon_discount')} :',
            ),
            const SizedBox(
              height: PsDimens.space12,
            ),
            _dividerWidget,
            _TransactionNoTextWidget(
              transationInfoText:
              '${transaction.currencySymbol} ${Utils.getPriceFormat(transaction.subTotalAmount!)}',
              title:
              '${Utils.getString(context, 'transaction_detail__sub_total')} :',
            ),
            /*_TransactionNoTextWidget(
              transationInfoText:
                  '${transaction.currencySymbol} ${Utils.getPriceFormat(transaction.taxAmount!,valueHolder)}',
              title:
                  '${Utils.getString(context, 'transaction_detail__tax')}(${transaction.taxPercent} %) :',
            ),*/
            _TransactionNoTextWidget(
              transationInfoText:
              '${transaction.currencySymbol} ${Utils.getPriceFormat(transaction.shippingAmount!)}',
              title:
              '${Utils.getString(context, 'checkout__delivery_cost')} :',
            ),
            /*_TransactionNoTextWidget(
              transationInfoText:
                  '${transaction.currencySymbol} ${Utils.calculateShippingTax(transaction.shippingAmount!, transaction.shippingTaxPercent!,valueHolder)}',
              title:
                  '${Utils.getString(context, 'transaction_detail__shipping_tax')}(${transaction.shippingTaxPercent} %) :',
            ),*/
            const SizedBox(
              height: PsDimens.space12,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: PsColors.redColor, // Border color
                  width: 2.0,          // Border width
                ),
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(PsDimens.space12),
                child:Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${Utils.getString(context, 'transaction_detail__total')} :',
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.normal,
                          color: PsColors.redColor
                      ),
                    ),
                    Text(
                      '${transaction.currencySymbol} ${Utils.getPriceFormat(transaction.balanceAmount!)}' ,
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.normal,
                          color: PsColors.redColor
                      ),
                    )
                  ],
                ),
              ),
            ),
            /*const SizedBox(
              height: PsDimens.space12,
            ),*/
          ],
        ));
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
                .copyWith(fontWeight: FontWeight.normal),
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

class ImageAndTextWidget extends StatelessWidget {
  const ImageAndTextWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  final Shop data;
  @override
  Widget build(BuildContext context) {
    final ShopProvider shopProvider = Provider.of<ShopProvider>(context);
    const Widget _spacingWidget = SizedBox(
      height: PsDimens.space4,
    );

    final Widget _imageWidget = PsNetworkImage(
      photoKey: '',
      defaultPhoto: data.defaultPhoto!,
      width: 100,
      height: 100,
      boxfit: BoxFit.cover,
      onTap: () async {
        await shopProvider.replaceShop(data.id!, data.name!);
        Navigator.pushNamed(context, RoutePaths.shopDashboard,
            arguments:
                ShopDataIntentHolder(shopId: data.id!, shopName: data.name!));
      },
    );

    return Padding(
      padding: const EdgeInsets.only(
          left: PsDimens.space12,
          right: PsDimens.space12,
          bottom: PsDimens.space12),
      child: InkWell(
        onTap: () async {
          await shopProvider.replaceShop(data.id!, data.name!);
          Navigator.pushNamed(context, RoutePaths.shopDashboard,
              arguments:
                  ShopDataIntentHolder(shopId: data.id!, shopName: data.name!));
        },
        child: Row(
          children: <Widget>[
            _imageWidget,
            const SizedBox(
              width: PsDimens.space12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(data.name!, style: Theme.of(context).textTheme.titleSmall),
                  _spacingWidget,
                  Text(data.aboutPhone1!,
                      style: Theme.of(context).textTheme.bodyLarge),
                  _spacingWidget,
                  Text(data.status!,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
