import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterrtdeliveryboyapp/api/common/ps_resource.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_config.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_dimens.dart';
import 'package:flutterrtdeliveryboyapp/provider/point/point_provider.dart';
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
import 'package:flutterrtdeliveryboyapp/ui/common/ps_ui_widget.dart';
import 'package:flutterrtdeliveryboyapp/ui/map/polyline_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/order/noti_order_detail/noti_order_detail_item_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/order/status/order_status_list_item.dart';
import 'package:flutterrtdeliveryboyapp/utils/ps_progress_dialog.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/common/ps_value_holder.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/holder/trans_status_update_holder.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/transaction_header.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class NotiOrderDetailItemListView extends StatefulWidget {
  const NotiOrderDetailItemListView({
    Key? key,
    required this.intentTransaction,
  }) : super(key: key);

  final TransactionHeader intentTransaction;

  @override
  _NotiOrderDetailItemListViewState createState() => _NotiOrderDetailItemListViewState();
}

class _NotiOrderDetailItemListViewState extends State<NotiOrderDetailItemListView>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  TransactionDetailRepository? repo1;
  TransactionDetailProvider? _transactionDetailProvider;
  AnimationController? animationController;
  Animation<double>? animation;
  PsValueHolder? valueHolder;
  ShopInfoProvider? shopInfoProvider;
  TransactionStatusProvider? transactionStatusProvider;
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
    animationController?.dispose();
    animation = null;
    super.dispose();
  }

  //@override
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
              body: Stack(children: <Widget>[
                RefreshIndicator(
                  child: CustomScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: Container(
                            color: PsColors.backgroundColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _ShopInfoWidget(
                                    pointProvider: pointProvider!,
                                    transaction: transaction!,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            color: PsColors.backgroundColor,
                            margin: const EdgeInsets.only(
                                top: PsDimens.space16,
                                ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                  _TransactionInfoWidget(
                                      pointProvider: pointProvider!,
                                      transaction: transaction!,            
                                  )
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              if (provider.transactionDetailList.data != null ||
                                  provider
                                      .transactionDetailList.data!.isNotEmpty) {
                                return NotiOrderDetailItemView(
                                  transaction: transaction!,
                                  transactionDetail: provider
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
                      ]),
                  onRefresh: () {
                    return provider.resetTransactionDetailList(transaction!);
                  },
                ),
                PSProgressIndicator(provider.transactionDetailList.status)
              ]),
            );
          }),
        ));
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

class _ShopInfoWidget extends StatelessWidget {
  const _ShopInfoWidget({
    Key? key,
    required this.pointProvider,
    required this.transaction,

  }) : super(key: key);

  final PointProvider pointProvider;
  final TransactionHeader transaction;

  @override
  Widget build(BuildContext context) {
    const EdgeInsets _paddingEdgeInsetWidget = EdgeInsets.only(
      left: PsDimens.space16,
      right: PsDimens.space16,
    );
    return Container(
      padding: _paddingEdgeInsetWidget,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
          Padding(
            padding: const EdgeInsets.only(
            left: PsDimens.space8,
            right: PsDimens.space8,
            top: PsDimens.space4,
            bottom: PsDimens.space4
            ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
              children: <Widget>[ 
              Text(
                'Seller',      
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(
                height: PsDimens.space4,
              ),
              Text(
                transaction.shop!.name!,      
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
         ],
        ),
        const SizedBox(height: PsDimens.space16),
        Text(
          transaction.shop!.address1!,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
        ),
        const SizedBox(height: PsDimens.space8),
        Container(
          height: 100,
          width: double.infinity,
          child: PolylinePage(
            pointProvider: pointProvider,
            tranLatLng: LatLng(
                double.parse(
                    transaction.shop!.lat!),
                double.parse(
                    transaction.shop!.lng!)),
        )),
      ],
    ));  
  }
}

class _TransactionInfoWidget extends StatelessWidget {
  const _TransactionInfoWidget({
    Key? key,
    required this.pointProvider,
    required this.transaction,
  }) : super(key: key);

  final PointProvider pointProvider;
  final TransactionHeader transaction;


  @override
  Widget build(BuildContext context) {
    const EdgeInsets _paddingEdgeInsetWidget = EdgeInsets.only(
      left: PsDimens.space16,
      right: PsDimens.space16,
    );
    return Container(
      padding: _paddingEdgeInsetWidget,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            height: PsDimens.space8,
          ),
          Text(
            'Buyer',      
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(
            height: PsDimens.space4,
          ),
          Text(
            transaction.contactName!,      
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: PsDimens.space8),
          Text(
            'Delivery to',      
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(
            height: PsDimens.space4,
          ),
          Text(
            transaction.contactAddress!,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
          ),
          const SizedBox(height: PsDimens.space8),
          Container(
            height: 100,
            width: double.infinity,
            child: PolylinePage(
              pointProvider: pointProvider,
              tranLatLng: LatLng(
                  double.parse(
                      transaction.transLat!),
                  double.parse(
                      transaction.transLng!)),
          )),
          const SizedBox(height: PsDimens.space8),
        ],
      ));  
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
  final AnimationController animationController;
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

