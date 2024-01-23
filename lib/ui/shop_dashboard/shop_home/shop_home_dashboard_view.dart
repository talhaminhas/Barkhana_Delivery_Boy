import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterrtdeliveryboyapp/api/common/ps_resource.dart';
import 'package:flutterrtdeliveryboyapp/api/common/ps_status.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_config.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_constants.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_dimens.dart';
import 'package:flutterrtdeliveryboyapp/constant/route_paths.dart';
import 'package:flutterrtdeliveryboyapp/provider/app_info/app_info_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/common/main_dashboard_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/shop_info/shop_info_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/transaction/completed_order_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/transaction/nearest_order_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/transaction/order_accept_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/transaction/pending_order_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/transaction/transaction_header_provider.dart';
import 'package:flutterrtdeliveryboyapp/provider/user/user_provider.dart';
import 'package:flutterrtdeliveryboyapp/repository/shop_info_repository.dart';
import 'package:flutterrtdeliveryboyapp/repository/transaction_header_repository.dart';
import 'package:flutterrtdeliveryboyapp/repository/user_repository.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/dialog/confirm_dialog_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/dialog/error_dialog.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/dialog/rating_dialog/core.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/dialog/rating_dialog/style.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/dialog/success_dialog.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/ps_message_page.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/ps_ui_widget.dart';
import 'package:flutterrtdeliveryboyapp/ui/map/current_location_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/order/item/nearest_order_list_item.dart';
import 'package:flutterrtdeliveryboyapp/ui/order/item/order_list_item.dart';
import 'package:flutterrtdeliveryboyapp/ui/order/item/pending_order_list_item.dart';
import 'package:flutterrtdeliveryboyapp/ui/user/login/login_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/user/pending_user/pending_user_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/user/reject_user/reject_user_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/user/verify/verify_email_view.dart';
import 'package:flutterrtdeliveryboyapp/utils/ps_progress_dialog.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/api_status.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/common/ps_value_holder.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/holder/completed_order_list_holder.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/holder/intent_holder/accept_order_parameter_holder.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/holder/pending_order_list_holder.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/transaction_header.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/transaction_parameter_holder.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ShopHomeDashboardViewWidget extends StatefulWidget {
  const ShopHomeDashboardViewWidget({
    this.animationController,
  });
  final AnimationController? animationController;

  @override
  _ShopHomeDashboardViewWidgetState createState() =>
      _ShopHomeDashboardViewWidgetState();
}

class _ShopHomeDashboardViewWidgetState
    extends State<ShopHomeDashboardViewWidget> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    MessagePage(message: 'page1'),
    MessagePage(message: 'page2'),
    MessagePage(message: 'page3'),
  ];  PsValueHolder? psValueHolder;
  ShopInfoRepository? shopInfoRepository;

  NearestOrderProvider ?nearestOrderProvider;
  TransactionHeaderProvider? transactionHeaderProvider;
  CompletedOrderProvider? completedOrderProvider;
  PendingOrderProvider? pendingOrderProvider;
  TransactionHeaderRepository? transactionHeaderRepository;
  UserRepository? userRepository;
  ShopInfoProvider? shopInfoProvider;
  MainDashboardProvider? mainDashboardProvider;
 OrderAcceptProvider? orderAcceptProvider;
  CompletedOrderListHolder? completedOrderListHolder;
  PendingOrderListHolder?pendingOrderListHolder;
  TextEditingController? addressController = TextEditingController();
  AppInfoProvider? appInfoProvider;

  final int count = 8;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final RateMyApp _rateMyApp = RateMyApp(
      preferencesPrefix: 'rateMyApp_',
      minDays: 0,
      minLaunches: 1,
      remindDays: 5,
      remindLaunches: 1);

  @override
  void initState() {
    super.initState();

    /*if (Platform.isAndroid) {
      _rateMyApp.init().then((_) {
        if (_rateMyApp.shouldOpenDialog) {
          _rateMyApp.showStarRateDialog(
            context,
            title: Utils.getString(context, 'home__menu_drawer_rate_this_app'),
            message: Utils.getString(context, 'rating_popup_dialog_message'),
            ignoreNativeDialog: true,
            actionsBuilder: (BuildContext context, double? stars) {
              return <Widget>[
                TextButton(
                  child: Text(
                    Utils.getString(context, 'dialog__ok'),
                  ),
                  onPressed: () async {
                    if (stars != null) {
                      // _rateMyApp.save().then((void v) => Navigator.pop(context));
                      Navigator.pop(context);
                      if (stars < 1) {
                      } else if (stars >= 1 && stars <= 3) {
                        await _rateMyApp
                            .callEvent(RateMyAppEventType.laterButtonPressed);
                        await showDialog<dynamic>(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmDialogView(
                                description: Utils.getString(
                                    context, 'rating_confirm_message'),
                                leftButtonText:
                                    Utils.getString(context, 'dialog__cancel'),
                                rightButtonText:
                                    Utils.getString(context, 'dialog__ok'),
                                onAgreeTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(
                                    context,
                                    RoutePaths.contactUs,
                                  );
                                },
                              );
                            });
                      } else if (stars >= 4) {
                        await _rateMyApp
                            .callEvent(RateMyAppEventType.rateButtonPressed);
                        if (Platform.isIOS) {
                          Utils.launchAppStoreURL(
                            iOSAppId: PsConfig.iOSAppStoreId,
                            // writeReview: true
                          );
                        } else {
                          Utils.launchURL();
                        }
                      }
                    } else {
                      Navigator.pop(context);
                    }
                  },
                )
              ];
            },
            onDismissed: () =>
                _rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
            dialogStyle: const DialogStyle(
              titleAlign: TextAlign.center,
              messageAlign: TextAlign.center,
              messagePadding: EdgeInsets.only(bottom: 16.0),
            ),
            starRatingOptions: const StarRatingOptions(),
          );
        }
      });
    }*/
  }

  Future<void> updateTitle(MainDashboardProvider provider, String title) async {
    provider.updateIndex(provider.currentIndex!, title, mounted);
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation =
        Utils.getTweenAnimation(widget.animationController!, 1);

    shopInfoRepository = Provider.of<ShopInfoRepository>(context);
    transactionHeaderRepository =
        Provider.of<TransactionHeaderRepository>(context);
    userRepository = Provider.of<UserRepository>(context);

    mainDashboardProvider =
        Provider.of<MainDashboardProvider>(context, listen: false);

    psValueHolder = Provider.of<PsValueHolder?>(context);

    Utils.psPrint(psValueHolder!.loginUserId ?? '');
    Utils.psPrint(psValueHolder!.isDeliveryBoy ?? '');
    widget.animationController!.forward();

    // Is user to login
    if (psValueHolder!.isUserToLogin()) {
      updateTitle(
          mainDashboardProvider!, Utils.getString(context, 'login__title'));
      return LoginView(
        animationController: widget.animationController!,
        animation: animation,
        callback: () {
          mainDashboardProvider!.updateIndex(
              PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT,
              Utils.getString(context, 'app_name'),
              mounted);
        },
      );
    }
    // Is user to verify
    else if (psValueHolder!.isUserToVerfity()) {
      updateTitle(mainDashboardProvider!,
          Utils.getString(context, 'email_verify__title'));
      return VerifyEmailView(
        animationController: widget.animationController!,
        callback: () {
          mainDashboardProvider!.updateIndex(
              PsConst.REQUEST_CODE__MENU_HOME_FRAGMENT,
              Utils.getString(context, 'app_name'),
              mounted);
        },
        // userId: psValueHolder.loginUserId,
      );
    }

    // Is user delivery boy status is pending
    else if (psValueHolder!.isDeliveryBoy == PsConst.PENDING_STATUS) {
      updateTitle(mainDashboardProvider!,
          Utils.getString(context, 'user__wait_approve_title'));
      return const PendingUserView();
    }
    // Is user delivery boy status is rejected
    else if (psValueHolder!.isDeliveryBoy == PsConst.REJECT_STATUS) {
      updateTitle(mainDashboardProvider!,
          Utils.getString(context, 'user__reject_title'));
      return const RejectUserView();
    }

    updateTitle(mainDashboardProvider!, Utils.getString(context, 'app_name'));
    return Scaffold(
      key: scaffoldKey,
      body: MultiProvider(
          providers: <SingleChildWidget>[
            ChangeNotifierProvider<NearestOrderProvider>(
                lazy: false,
                create: (BuildContext context) {
                  nearestOrderProvider =
                      NearestOrderProvider(repo: transactionHeaderRepository!);
                  nearestOrderProvider!.loadNearestOrderList(
                      psValueHolder!.loginUserId!,
                      TransactionParameterHolder()
                          .resetParameterHolder());
                  return nearestOrderProvider!;
                }),
            ChangeNotifierProvider<CompletedOrderProvider>(
                lazy: false,
                create: (BuildContext context) {
                  completedOrderProvider =
                      CompletedOrderProvider(repo: transactionHeaderRepository!);
                  completedOrderListHolder = CompletedOrderListHolder(
                      deliveryBoyId: Utils.checkUserLoginId(psValueHolder!),
                    justToday: '1',//'${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
                  );
                  completedOrderProvider!.loadCompletedOrderList(
                      completedOrderListHolder!.toMap(),
                      TransactionParameterHolder()
                          .getCompletedOrderParameterHolder());
                  return completedOrderProvider!;
                }),
            ChangeNotifierProvider<PendingOrderProvider>(
                lazy: false,
                create: (BuildContext context) {
                  pendingOrderProvider =
                      PendingOrderProvider(repo: transactionHeaderRepository!);
                  pendingOrderListHolder = PendingOrderListHolder(
                      deliveryBoyId: Utils.checkUserLoginId(psValueHolder!));
                  pendingOrderProvider!.loadPendingOrderList(
                      pendingOrderListHolder!.toMap(),
                      TransactionParameterHolder()
                          .getPendingOrderParameterHolder());
                  return pendingOrderProvider!;
                }),
           ChangeNotifierProvider<OrderAcceptProvider>(
                lazy: false,
                create: (BuildContext context) {
                  orderAcceptProvider = OrderAcceptProvider(
                      repo: transactionHeaderRepository!,
                      psValueHolder: psValueHolder);
                  return orderAcceptProvider!;
                }),
            ChangeNotifierProvider<TransactionHeaderProvider>(
                lazy: false,
                create: (BuildContext context) {
                  transactionHeaderProvider = TransactionHeaderProvider(
                      repo: transactionHeaderRepository!,
                      psValueHolder: psValueHolder);
                  return transactionHeaderProvider!;
                }),
            ChangeNotifierProvider<ShopInfoProvider>(
                lazy: false,
                create: (BuildContext context) {
                  shopInfoProvider = ShopInfoProvider(
                      repo: shopInfoRepository!,
                      ownerCode: 'ShopDashboardView',
                      psValueHolder: psValueHolder!);
                  if (PsConfig.isMultiRestaurant) {
                    shopInfoProvider!.loadShopInfoById(
                        shopInfoProvider!.psValueHolder.shopId ?? '');
                  } else {
                    shopInfoProvider!.loadShopInfo();
                  }
                  return shopInfoProvider!;
                }),
            ChangeNotifierProvider<UserProvider>(
                lazy: false,
                create: (BuildContext context) {
                  final UserProvider userProvider = UserProvider(
                      repo: userRepository!, psValueHolder: psValueHolder);

                  userProvider.getUser(psValueHolder!.loginUserId ?? '');

                  return userProvider;
                }),
          ],
          child: Container(
            color: PsColors.coreBackgroundColor,
            child: RefreshIndicator(
              onRefresh: () {
                pendingOrderProvider!.resetPendingOrderList(
                    pendingOrderListHolder!.toMap(),
                    TransactionParameterHolder()
                        .getPendingOrderParameterHolder());
                return completedOrderProvider!.resetCompletedOrderList(
                    completedOrderListHolder!.toMap(),
                    TransactionParameterHolder()
                        .getCompletedOrderParameterHolder());
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                slivers: <Widget>[
                  /*SliverToBoxAdapter(
                      child: CurrentLocationWidget(
                    androidFusedLocation: true,
                    textEditingController: addressController,
                    isShowAddress: true,
                    shopInfoProvider: shopInfoProvider,
                  )),*/
                  /*_NearestOrderListWidget(
                    animationController: widget.animationController,
                    scaffoldKey: scaffoldKey,
                    pendingOrderListHolder: pendingOrderListHolder,
                    nearestOrderProvider: nearestOrderProvider,
                    transactionHeaderProvider:
                        transactionHeaderProvider,
                    pendingOrderProvider: pendingOrderProvider,
                    completedOrderProvider: completedOrderProvider,
                    completedOrderListHolder: completedOrderListHolder,
                    orderAcceptProvider: orderAcceptProvider,
                  ),*/
                  if(_currentIndex == 0 || _currentIndex == 1)
                  _PendingOrderListWidget(
                    currentIndex: _currentIndex,
                    provider: pendingOrderProvider,
                    completedOrderProvider: completedOrderProvider,
                    animationController: widget.animationController!,
                    scaffoldKey: scaffoldKey,
                    pendingOrderListHolder: pendingOrderListHolder,
                  ),
                  if(_currentIndex == 2)
                  _TransactionListViewWidget(
                    scaffoldKey: scaffoldKey,
                    animationController: widget.animationController!,
                    provider: completedOrderProvider,
                    completedOrderListHolder: completedOrderListHolder,
                    pendingOrderProvider: pendingOrderProvider,
                  ),
                ],
              ),
            ),
          //_pages[_currentIndex],
          ),
      ),
      bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: PsColors.mainColor,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const <BottomNavigationBarItem>[

        BottomNavigationBarItem(
          icon: Icon(Icons.library_books_outlined),
          label: 'Pending',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_bike_sharp),
          label: 'Delivering',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_add_check_outlined),
          label: 'Completed',
        ),
      ],
    ),
    );
  }
}

class _NearestOrderListWidget extends StatefulWidget {
  const _NearestOrderListWidget(
      {this.animationController,
      this.scaffoldKey,
      required this.pendingOrderListHolder,
      required this.nearestOrderProvider,
      required this.transactionHeaderProvider,
      required this.orderAcceptProvider,
      required this.pendingOrderProvider,
      required this.completedOrderProvider,
      required this.completedOrderListHolder});

  final AnimationController? animationController;
  final GlobalKey<ScaffoldState> ?scaffoldKey;
  final NearestOrderProvider? nearestOrderProvider;
  final PendingOrderListHolder? pendingOrderListHolder;
  final TransactionHeaderProvider? transactionHeaderProvider;
  final PendingOrderProvider? pendingOrderProvider;
  final CompletedOrderProvider? completedOrderProvider;
  final CompletedOrderListHolder ?completedOrderListHolder;
 final OrderAcceptProvider? orderAcceptProvider;

  @override
  __NearestOrderListWidgetState createState() => __NearestOrderListWidgetState();
}

class __NearestOrderListWidgetState extends State<_NearestOrderListWidget> {
  PsValueHolder? valueHolder;
  TransactionHeaderRepository? transactionHeaderRepo;
  

  @override
  Widget build(BuildContext context) {
    final PsValueHolder? psValueHolder =
        Provider.of<PsValueHolder?>(context,
            listen: false);

    return SliverToBoxAdapter(child: Consumer<NearestOrderProvider>(builder:
        (BuildContext context, NearestOrderProvider provider, Widget? child) {
  
      if (
          provider.nearestTransactionList.data != null &&
          provider.nearestTransactionList.data!.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(
              left: PsDimens.space16,
              right: PsDimens.space16,
              bottom: PsDimens.space16,
              ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Text('Nearest Order',
                textAlign: TextAlign.start,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: PsColors.mainColor)),
              Padding(
                padding: const EdgeInsets.only(top: PsDimens.space8),
              child: Container(
                  child: RefreshIndicator(
                child: CustomScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            if (provider.nearestTransactionList.data != null ||
                                provider
                                    .nearestTransactionList.data!.isNotEmpty) {
                              final int count =
                                  provider.nearestTransactionList.data!.length;
                              return NearestOrderListItem(
                                scaffoldKey: widget.scaffoldKey!,
                                animationController: widget.animationController,
                                animation:
                                    Tween<double>(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: widget.animationController!,
                                    curve: Interval((1 / count) * index, 1.0,
                                        curve: Curves.fastOutSlowIn),
                                  ),
                                ),
                                transaction:
                                    provider.nearestTransactionList.data![index],
                                onTap: () async {
                                  final dynamic returnData =
                                      await Navigator.pushNamed(
                                          context, RoutePaths.notiTransactionDetail,
                                          arguments: provider
                                              .nearestTransactionList
                                              .data![index]);
                                  if (returnData) {
                                    final PsValueHolder? psValueHolder =
                                        Provider.of<PsValueHolder?>(context,
                                            listen: false);
      
                                    provider.loadNearestOrderList(
                                        psValueHolder!.loginUserId!,
                                         TransactionParameterHolder()
                                            .resetParameterHolder());

                                     widget.pendingOrderProvider!.loadPendingOrderList(
                                        widget.pendingOrderListHolder!.toMap(),
                                        TransactionParameterHolder()
                                            .getPendingOrderParameterHolder());
                                    final CompletedOrderListHolder completedOrderListHolder = CompletedOrderListHolder(
                                      deliveryBoyId: Utils.checkUserLoginId(psValueHolder!),
                                      justToday: '1',//'${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
                                    );
                                    widget.completedOrderProvider!.loadCompletedOrderList(
                                        completedOrderListHolder.toMap(),
                                        TransactionParameterHolder()
                                            .getCompletedOrderParameterHolder());
                                  }
                                },
                                onAcceptTap: () async {
                                  await PsProgressDialog.showDialog(context);

                                  final AcceptOrderParameterHolder acceptOrderParameterHolder =
                                      AcceptOrderParameterHolder(
                                          deliveryBoyId: psValueHolder!.loginUserId,
                                          transactionHeaderId: provider
                                              .nearestTransactionList
                                              .data![index].id);
                                          
                                  final PsResource<ApiStatus> _apiStatus = await widget.orderAcceptProvider!
                                      .postOrderAccept(acceptOrderParameterHolder.toMap());

                                    if (_apiStatus.data != null) {

                                         PsProgressDialog.dismissDialog();
                                        showDialog<dynamic>(
                                            context: context,
                                            builder: (BuildContext contet) {
                                        return const SuccessDialog(
                                          message: 'Order has benn accepted',
                                      );
                                      });
                                      setState(() {});
                                      provider.resetNearesOrderList(
                                        psValueHolder.loginUserId!,
                                         TransactionParameterHolder()
                                            .resetParameterHolder());

                                      widget.pendingOrderProvider!.resetPendingOrderList(
                                          widget.pendingOrderListHolder!.toMap(),
                                        TransactionParameterHolder()
                                            .getPendingOrderParameterHolder());

                                      widget.completedOrderProvider!.resetCompletedOrderList(
                                          widget.completedOrderListHolder!.toMap(),
                                        TransactionParameterHolder()
                                            .getCompletedOrderParameterHolder());

                                   
                              
                                  } else {
                                    PsProgressDialog.dismissDialog();
                                        showDialog<dynamic>(
                                            context: context,
                                            builder: (BuildContext contet) {
                                        return ErrorDialog(
                                          message: _apiStatus.message,
                                      );
                                    });
                                  }
                                },
                              );
                            } else {
                              return null;
                            }
                          },
                          childCount:
                              provider.nearestTransactionList.data!.length,
                        ),
                      ),
                    ]),
                onRefresh: () {
                  return provider.resetNearesOrderList(
                      psValueHolder!.loginUserId!,
                      TransactionParameterHolder()
                          .resetParameterHolder());
                  },
                )),
              ),
            ]),
          );
      } else {
        return Container();
      }
    }));
  }
}


class _PendingOrderListWidget extends StatelessWidget {
  const _PendingOrderListWidget(
      {required this.currentIndex,
        this.provider,
      this.animationController,
      this.scaffoldKey,
      this.pendingOrderListHolder,
      this.completedOrderProvider});
  final int currentIndex;
  final PendingOrderProvider? provider;
  final AnimationController? animationController;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final PendingOrderListHolder? pendingOrderListHolder;
  final CompletedOrderProvider? completedOrderProvider;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: Consumer<PendingOrderProvider>(builder:
        (BuildContext context, PendingOrderProvider pendingProvider, Widget? child, ) {
      // animationController.forward();
      final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
          .animate(CurvedAnimation(
              parent: animationController!,
              curve:
                  const Interval(0.5 * 1, 1.0, curve: Curves.fastOutSlowIn)));

      if (pendingProvider.pendingTransactionList.data != null) {
        final List<TransactionHeader> pendingTransactions = pendingProvider.pendingTransactionList.data!;
        final List<TransactionHeader> preparingOrderList =
        pendingTransactions.where((TransactionHeader transaction) =>
        transaction.transactionStatus!.ordering == '2').toList();
        final List<TransactionHeader> readyOrderList =
        pendingTransactions.where((TransactionHeader transaction) =>
        transaction.transactionStatus!.ordering == '3').toList();
        final List<TransactionHeader> deliveringOrderList =
        pendingTransactions.where((TransactionHeader transaction) =>
        transaction.transactionStatus!.ordering == '4').toList();

        if ((currentIndex == 0 && readyOrderList.isEmpty && preparingOrderList.isEmpty) ||
            (currentIndex == 1  && deliveringOrderList.isEmpty)) {
          return AnimatedBuilder(
            animation: animationController!,
            child: Stack(
              //alignment: Alignment.center,
                children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: PsDimens.space120),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/empty_active_delivery.png',
                        height: 100,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      currentIndex == 0 ?'No Active Orders' : 'Nothing To Deliver',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                    ),
                    const SizedBox(
                      height: PsDimens.space8,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          PsDimens.space72, 0, PsDimens.space72, 0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          currentIndex == 0 ?
                            'Currently There Are No Active Orders From The Shop.'
                            : 'Currently There Are No Orders To Deliver.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(),
                            textAlign: TextAlign.center),
                      ),
                    ),
                    Visibility(
                      visible: PsStatus.SUCCESS ==
                              pendingProvider.pendingTransactionList.status ||
                          PsStatus.ERROR ==
                              pendingProvider.pendingTransactionList.status,
                      child: InkWell(
                        child: Container(
                          height: PsDimens.space80,
                          width: PsDimens.space80,
                          child: Icon(
                            Icons.refresh,
                            color: PsColors.mainColor,
                            size: PsDimens.space40,
                          ),
                        ),
                        onTap: () {
                          final PsValueHolder? psValueHolder =
                              Provider.of<PsValueHolder?>(context,
                                  listen: false);
                          final PendingOrderListHolder pendingOrderListHolder =
                              PendingOrderListHolder(
                                  deliveryBoyId:
                                      Utils.checkUserLoginId(psValueHolder!));
                           pendingProvider.resetPendingOrderList(
                              pendingOrderListHolder.toMap(),
                              TransactionParameterHolder()
                                  .getPendingOrderParameterHolder());
                        },
                      ),
                    ),
                  ],
                ),
              ),
              PSProgressIndicator(pendingProvider.pendingTransactionList.status),
            ]),
            builder: (BuildContext context, Widget? child) {
              return FadeTransition(
                  opacity: animation,
                  child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 100 * (1.0 - animation.value), 0.0),
                      child: child));
            },
          );
        } else {
          pendingProvider.pendingTransactionList.data!.sort((TransactionHeader a, TransactionHeader b) {
            final int orderingA = int.parse(a.transactionStatus!.ordering!);
            final int orderingB = int.parse(b.transactionStatus!.ordering!);
            return orderingB.compareTo(orderingA);
          });
          return Padding(
            padding: const EdgeInsets.only(
              bottom: PsDimens.space16,
              left: PsDimens.space16,
              right: PsDimens.space16),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Text(currentIndex == 0 ? 'Pending Orders ( '
                  + (readyOrderList.length + preparingOrderList.length).toString() +' )'
                  :'Delivering Now ( '+ deliveringOrderList.length.toString() +' )',
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: PsColors.mainColor)),
               Padding(
                padding: const EdgeInsets.only(),
              child: Container(
                  child: RefreshIndicator(
                child: CustomScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            if (pendingProvider.pendingTransactionList.data != null ||
                                pendingProvider
                                    .pendingTransactionList.data!.isNotEmpty) {
                              final int count =
                                  pendingProvider.pendingTransactionList.data!.length;
                              bool _showOrderListItem = false;
                              if ( currentIndex == 0 &&
                                  (
                                      pendingProvider.pendingTransactionList.data![index].transactionStatus!.ordering == '2'
                                          ||  pendingProvider.pendingTransactionList.data![index].transactionStatus!.ordering == '3'
                                  )
                                  || currentIndex == 1
                                      && pendingProvider.pendingTransactionList.data![index].transactionStatus!.ordering == '4')
                                {
                                  _showOrderListItem = true;
                                }
                              return Visibility(
                                visible: _showOrderListItem,
                                  child: DashboardOrderListItem(
                                scaffoldKey: scaffoldKey!,
                                animationController: animationController,
                                animation:
                                    Tween<double>(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: animationController!,
                                    curve: Interval((1 / count) * index, 1.0,
                                        curve: Curves.fastOutSlowIn),
                                  ),
                                ),
                                transaction:
                                    pendingProvider.pendingTransactionList.data![index],
                                onTap: () async {
                                  final dynamic returnData =
                                      await Navigator.pushNamed(
                                          context, RoutePaths.transactionDetail,
                                          arguments: pendingProvider
                                              .pendingTransactionList
                                              .data![index]);
                                  if (returnData) {
                                    final PsValueHolder? psValueHolder =
                                        Provider.of<PsValueHolder?>(context,
                                            listen: false);
                                    final PendingOrderListHolder
                                        pendingOrderListHolder =
                                        PendingOrderListHolder(
                                            deliveryBoyId:
                                                Utils.checkUserLoginId(
                                                    psValueHolder!));
                                    pendingProvider.loadPendingOrderList(
                                        pendingOrderListHolder.toMap(),
                                        TransactionParameterHolder()
                                            .getPendingOrderParameterHolder());
                                    final CompletedOrderListHolder
                                    completedOrderListHolder =
                                    CompletedOrderListHolder(
                                      justToday: '1',
                                        deliveryBoyId:
                                        Utils.checkUserLoginId(
                                            psValueHolder!));
                                    completedOrderProvider!.loadCompletedOrderList(
                                        completedOrderListHolder.toMap(),
                                        TransactionParameterHolder()
                                            .getCompletedOrderParameterHolder());
                                  }
                                },
                              )
                              );
                            } else {
                              return null;
                            }
                          },
                          childCount:
                              pendingProvider.pendingTransactionList.data!.length,
                        ),
                      ),
                    ]),
                onRefresh: () {
                  return pendingProvider.resetPendingOrderList(
                      pendingOrderListHolder!.toMap(),
                      TransactionParameterHolder()
                          .getPendingOrderParameterHolder());
                },
              )),
            )]),
          );
        }
      } else {
        return Container();
      }
    }));
  }
}

class _OrderAndSeeAllWidget extends StatefulWidget {
  const _OrderAndSeeAllWidget(
      {required this.animationController,
      required this.completedOrderProvider});
  final AnimationController animationController;
  final CompletedOrderProvider? completedOrderProvider;
  @override
  __OrderAndSeeAllWidgetState createState() => __OrderAndSeeAllWidgetState();
}

class __OrderAndSeeAllWidgetState extends State<_OrderAndSeeAllWidget> {
  @override
  Widget build(BuildContext context) {
    // widget.animationController.forward();
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: widget.animationController,
            curve: const Interval(0.5 * 1, 1.0, curve: Curves.fastOutSlowIn)));
    return SliverToBoxAdapter(child: Consumer<CompletedOrderProvider>(builder:
        (BuildContext context, CompletedOrderProvider provider, Widget? child) {
      if (
          provider.completedTransactionList.data != null &&
          provider.completedTransactionList.data!.isNotEmpty) {
        return AnimatedBuilder(
          animation: widget.animationController,
          child: Column(
            children: <Widget>[
              const Divider(
                height: PsDimens.space1,
              ),
              const SizedBox(height: PsDimens.space24),
              InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.completedTransactionList,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: PsDimens.space16,
                        right: PsDimens.space16,
                        bottom: PsDimens.space16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(Utils.getString(context, 'profile__order'),
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(color: PsColors.mainColor)),
                        InkWell(
                          child: Text(
                            Utils.getString(context, 'profile__view_all'),
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
                opacity: animation,
                child: Transform(
                    transform: Matrix4.translationValues(
                        0.0, 100 * (1.0 - animation.value), 0.0),
                    child: child));
          },
        );
      } else {
        return Container();
      }
    }));
  }
}

class _TransactionListViewWidget extends StatelessWidget {
  const _TransactionListViewWidget(
      {Key?key,
      required this.animationController,
      required this.provider,
      required this.scaffoldKey,
      required this.completedOrderListHolder,
      required this.pendingOrderProvider})
      : super(key: key);

  final AnimationController animationController;
  final CompletedOrderProvider? provider;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final CompletedOrderListHolder? completedOrderListHolder;
  final PendingOrderProvider? pendingOrderProvider;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: Consumer<CompletedOrderProvider>(builder:
        (BuildContext context, CompletedOrderProvider provider, Widget? child) {
          final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
              .animate(CurvedAnimation(
              parent: animationController!,
              curve:
              const Interval(0.5 * 1, 1.0, curve: Curves.fastOutSlowIn)));
          if (provider.completedTransactionList.data! == null ||
              provider.completedTransactionList.data!.isEmpty) {
            return AnimatedBuilder(
              animation: animationController!,
              child: Stack(
                  //alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: PsDimens.space120),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/images/empty_active_delivery.png',
                              height: 100,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(
                            'No Delivered Orders',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                          ),
                          const SizedBox(
                            height: PsDimens.space8,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                PsDimens.space72, 0, PsDimens.space72, 0),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                  'Currently There Are No Delivered Orders For Today.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(),
                                  textAlign: TextAlign.center),
                            ),
                          ),
                          Visibility(
                            visible: PsStatus.SUCCESS ==
                                provider.completedTransactionList.status ||
                                PsStatus.ERROR ==
                                    provider.completedTransactionList.status,
                            child: InkWell(
                              child: Container(
                                height: PsDimens.space80,
                                width: PsDimens.space80,
                                child: Icon(
                                  Icons.refresh,
                                  color: PsColors.mainColor,
                                  size: PsDimens.space40,
                                ),
                              ),
                              onTap: () {
                                final PsValueHolder? psValueHolder =
                                Provider.of<PsValueHolder?>(context,
                                    listen: false);
                                final CompletedOrderListHolder completedOrderListHolder =
                                CompletedOrderListHolder(
                                    deliveryBoyId:
                                    Utils.checkUserLoginId(psValueHolder!),
                                  justToday: '1',//'${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
                                );
                                provider.resetCompletedOrderList(
                                    completedOrderListHolder.toMap(),
                                    TransactionParameterHolder()
                                        .getCompletedOrderParameterHolder());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    PSProgressIndicator(provider.completedTransactionList.status),
                  ]),
              builder: (BuildContext context, Widget? child) {
                return FadeTransition(
                    opacity: animation,
                    child: Transform(
                        transform: Matrix4.translationValues(
                            0.0, 100 * (1.0 - animation.value), 0.0),
                        child: child));
              },
            );
          }
          else {
        return Padding(
          padding: const EdgeInsets.only(right: PsDimens.space16,
              left: PsDimens.space16),
          child: Stack(children: <Widget>[

            Container(
                child: RefreshIndicator(
              child: CustomScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Container(
                        height: 25,
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (provider.completedTransactionList.data != null ||
                              provider
                                  .completedTransactionList.data!.isNotEmpty) {
                            final int count =
                                provider.completedTransactionList.data!.length;
                            return DashboardOrderListItem(
                              scaffoldKey: scaffoldKey,
                              animationController: animationController,
                              animation:
                                  Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: animationController,
                                  curve: Interval((1 / count) * index, 1.0,
                                      curve: Curves.fastOutSlowIn),
                                ),
                              ),
                              transaction:
                                  provider.completedTransactionList.data![index],
                              onTap: () async {
                                final dynamic returnData =
                                    await Navigator.pushNamed(
                                        context, RoutePaths.transactionDetail,
                                        arguments: provider
                                            .completedTransactionList
                                            .data![index]);
                                if (returnData) {
                                  final PsValueHolder? psValueHolder =
                                      Provider.of<PsValueHolder?>(context,
                                          listen: false);
                                  final CompletedOrderListHolder
                                      completedOrderListHolder =
                                      CompletedOrderListHolder(
                                          justToday: '1',//'${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
                                          deliveryBoyId: Utils.checkUserLoginId(
                                              psValueHolder!));
                                  provider.loadCompletedOrderList(
                                      completedOrderListHolder.toMap(),
                                      TransactionParameterHolder()
                                          .getCompletedOrderParameterHolder());
                                  //
                                  pendingOrderProvider!.loadPendingOrderList(
                                      completedOrderListHolder.toMap(),
                                      TransactionParameterHolder()
                                          .getPendingOrderParameterHolder());
                                }
                              },
                            );
                          } else {
                            return null;
                          }
                        },
                        childCount:
                            provider.completedTransactionList.data!.length,
                      ),
                    ),
                  ]),
              onRefresh: () {
                return provider.resetCompletedOrderList(
                    completedOrderListHolder!.toMap(),
                    TransactionParameterHolder()
                        .getCompletedOrderParameterHolder());
              },
            )),
            Positioned(
              top: 0, left: 0, right: 0,
              child: Row
                (
                children: <Widget>[
                  Text(
                      'Completed Orders ( ' +provider.completedTransactionList.data!.length.toString() +' )',
                      textAlign: TextAlign.start,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: PsColors.mainColor)),

                ],
              )
            ),
          ]),
        );
      }
    }));
  }
}
