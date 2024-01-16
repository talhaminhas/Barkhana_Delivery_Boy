import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_colors.dart';
import 'package:flutterrtdeliveryboyapp/config/ps_config.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_constants.dart';
import 'package:flutterrtdeliveryboyapp/constant/ps_dimens.dart';
import 'package:flutterrtdeliveryboyapp/provider/shop_info/shop_info_provider.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/ps_ui_widget.dart';
import 'package:flutterrtdeliveryboyapp/ui/common/smooth_star_rating_widget.dart';
import 'package:flutterrtdeliveryboyapp/ui/shop_info/address_tile_view.dart';
import 'package:flutterrtdeliveryboyapp/ui/shop_info/contact_us_tile_view.dart';
import 'package:flutterrtdeliveryboyapp/utils/utils.dart';
import 'package:flutterrtdeliveryboyapp/viewobject/shop_info.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopInfoView extends StatefulWidget {
  const ShopInfoView(
      {Key? key,
      required this.shopId,
      required this.shopInfoProvider,
      this.animationController,
      this.animation})
      : super(key: key);

  final String shopId;
  final ShopInfoProvider shopInfoProvider;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  _ShopInfoViewState createState() => _ShopInfoViewState();
}

class _ShopInfoViewState extends State<ShopInfoView> {
  @override
  Widget build(BuildContext context) {
    widget.animationController!.forward();

    return SliverToBoxAdapter(
        child: AnimatedBuilder(
            animation: widget.animationController!,
            child: Column(
              children: <Widget>[
                _ShopInfoViewWidget(
                    shopId: widget.shopId,
                    shopInfoProvider: widget.shopInfoProvider),
                // _CustomerReviewListViewWidget(
                //   shopId: widget.shopId,
                //   shopInfoProvider: widget.shopInfoProvider,
                // )
              ],
            ),
            builder: (BuildContext context, Widget? child) {
              return FadeTransition(
                opacity: widget.animation!,
                child: Transform(
                   transform: Matrix4.translationValues(
                      0.0, 30 * (1.0 - widget.animation!.value), 0.0),
            child: child
              // } else {
              //   return Container();
              // }
              // })
            )
          );
        })
      );
  }
}

class _ShopInfoViewWidget extends StatefulWidget {
  const _ShopInfoViewWidget({
    Key? key,
    required this.shopId,
    required this.shopInfoProvider,
  }) : super(key: key);

  final String shopId;
  final ShopInfoProvider shopInfoProvider;

  @override
  __ShopInfoViewWidgetState createState() => __ShopInfoViewWidgetState();
}

class __ShopInfoViewWidgetState extends State<_ShopInfoViewWidget> {
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;

  void checkConnection() {
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
      if (isConnectedToInternet && PsConfig.showAdMob) {
        setState(() {});
      }
    });
  }

  LatLng? _latlng;
  final double zoom = 15;
  final MapController mapController = MapController();
  @override
  Widget build(BuildContext context) {
    _latlng = LatLng(double.parse(widget.shopInfoProvider.shopInfo.data!.lat!),
        double.parse(widget.shopInfoProvider.shopInfo.data!.lng!));
    if (!isConnectedToInternet && PsConfig.showAdMob) {
      print('loading ads....');
      checkConnection();
    }
    return Container(
      color: PsColors.baseColor,
      child: Column(
        children: <Widget>[
          _HeaderBoxWidget(
              shopInfo: widget.shopInfoProvider.shopInfo.data!,
              shopInfoProvider: widget.shopInfoProvider),
          Padding(
            padding: const EdgeInsets.only(right: 8, left: 8),
            child: Container(
              height: 250,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center:
                      _latlng, //LatLng(51.5, -0.09), //LatLng(45.5231, -122.6765),
                  zoom: zoom, //10.0,
                  // onTap: (LatLng latLngr) {
                  //   FocusScope.of(context).requestFocus(FocusNode());
                  // }
                ),
               children: <Widget>[
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  MarkerLayer(markers: <Marker>[
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _latlng!,
                      child: /*builder: (BuildContext ctx)=>*/ Container(
                        child: IconButton(
                          icon: Icon(
                            Icons.location_on,
                            color: PsColors.mainColor,
                          ),
                          iconSize: 45,
                          onPressed: () {},
                        ),
                      ),
                    )
                  ])
                ],
              ),
            ),
          ),
          AddressTileView(
            shopInfo: widget.shopInfoProvider.shopInfo.data!,
          ),
          ContactUsTileView(
            shopInfo: widget.shopInfoProvider.shopInfo.data!,
          ),
        ],
      ),
    );
  }
}

class _HeaderBoxWidget extends StatefulWidget {
  const _HeaderBoxWidget({
    Key? key,
    required this.shopInfo,
    required this.shopInfoProvider,
  }) : super(key: key);

  final ShopInfoProvider shopInfoProvider;
  final ShopInfo shopInfo;

  @override
  __HeaderBoxWidgetState createState() => __HeaderBoxWidgetState();
}

class __HeaderBoxWidgetState extends State<_HeaderBoxWidget> {
  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison
    if (widget.shopInfo != null) {
      return Container(
        margin: const EdgeInsets.all(PsDimens.space12),
        decoration: BoxDecoration(
          color: PsColors.backgroundColor,
          borderRadius:
              const BorderRadius.all(Radius.circular(PsDimens.space8)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(PsDimens.space16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.shopInfo.name!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: PsDimens.space8),
                    Row(
                      children: <Widget>[
                        Text(
                          '\$',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: widget.shopInfo.priceLevel ==
                                          PsConst.PRICE_LOW ||
                                      widget.shopInfo.priceLevel ==
                                          PsConst.PRICE_MEDIUM ||
                                      widget.shopInfo.priceLevel ==
                                          PsConst.PRICE_HIGH
                                  ? PsColors.priceLevelColor
                                  : PsColors.grey),
                          maxLines: 2,
                        ),
                        Text(
                          '\$',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: widget.shopInfo.priceLevel ==
                                          PsConst.PRICE_MEDIUM ||
                                      widget.shopInfo.priceLevel ==
                                          PsConst.PRICE_HIGH
                                  ? PsColors.priceLevelColor
                                  : PsColors.grey),
                          maxLines: 2,
                        ),
                        Text(
                          '\$',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: widget.shopInfo.priceLevel ==
                                      PsConst.PRICE_HIGH
                                  ? PsColors.priceLevelColor
                                  : PsColors.grey),
                          maxLines: 2,
                        ),
                        const SizedBox(width: PsDimens.space8),
                        Text(
                          widget.shopInfo.highlightedInfo!,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(),
                          maxLines: 2,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: PsDimens.space12,
                    ),
                    Divider(
                      height: PsDimens.space1,
                      color: PsColors.mainColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: PsDimens.space16, bottom: PsDimens.space4),
                      child: _HeaderRatingWidget(
                        shopInfo: widget.shopInfo,
                        shopInfoProvider: widget.shopInfoProvider,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}

class _HeaderRatingWidget extends StatefulWidget {
  const _HeaderRatingWidget(
      {Key? key, required this.shopInfo, required this.shopInfoProvider})
      : super(key: key);

  final ShopInfo shopInfo;
  final ShopInfoProvider shopInfoProvider;

  @override
  __HeaderRatingWidgetState createState() => __HeaderRatingWidgetState();
}

class __HeaderRatingWidgetState extends State<_HeaderRatingWidget> {
  @override
  Widget build(BuildContext context) {
    if ( widget.shopInfo.ratingDetail != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: () async {},
            child: SmoothStarRating(
                key: Key(widget.shopInfo.ratingDetail!.totalRatingValue!),
                rating:
                    double.parse(widget.shopInfo.ratingDetail!.totalRatingValue!),
                allowHalfRating: false,
                starCount: 5,
                isReadOnly: true,
                size: PsDimens.space16,
                color: PsColors.ratingColor,
                borderColor: PsColors.grey.withAlpha(100),
                onRated: (double? v) async {},
                spacing: 0.0),
          ),
          const SizedBox(
            height: PsDimens.space10,
          ),
          GestureDetector(
              onTap: () async {},
              child: (widget.shopInfo.overallRating != null && widget.shopInfo.overallRating != '0')
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.shopInfo.ratingDetail!.totalRatingValue ?? '',
                          textAlign: TextAlign.left,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(),
                        ),
                        const SizedBox(
                          width: PsDimens.space4,
                        ),
                        Text(
                          '${Utils.getString(context, 'product_detail__out_of_five_stars')}(' +
                              widget.shopInfo.ratingDetail!.totalRatingCount! +
                              ' ${Utils.getString(context, 'product_detail__reviews')})',
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(),
                        ),
                      ],
                    )
                  : Text(
                      Utils.getString(context, 'product_detail__no_rating'))),
          const SizedBox(
            height: PsDimens.space16,
          ),
          Text(
            widget.shopInfo.description!,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.4),
          )
        ],
      );
    } else {
      return Container();
    }
  }
}

class ImageAndTextWidget extends StatelessWidget {
  const ImageAndTextWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  final ShopInfo data;
  @override
  Widget build(BuildContext context) {
    const Widget _spacingWidget = SizedBox(
      height: PsDimens.space4,
    );

    final Widget _imageWidget = PsNetworkImage(
      photoKey: '',
      defaultPhoto: data.defaultPhoto!,
      width: 50,
      height: 50,
      boxfit: BoxFit.cover,
      onTap: () {},
    );

    return Container(
        margin: const EdgeInsets.only(
            left: PsDimens.space16,
            right: PsDimens.space16,
            top: PsDimens.space16),
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
                  Text(
                    data.name!,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: PsColors.mainColor,
                        ),
                  ),
                  _spacingWidget,
                  InkWell(
                    child: Text(
                      data.aboutPhone1!,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                    ),
                    onTap: () async {
                      if (await canLaunchUrl(Uri.parse('tel://${data.aboutPhone1}'))) {
                        await launchUrl(Uri.parse('tel://${data.aboutPhone1}'));
                      } else {
                        throw 'Could not Call Phone Number 1';
                      }
                    },
                  ),
                  _spacingWidget,
                  Row(
                    children: <Widget>[
                      Container(
                          child: const Icon(
                        Icons.email,
                      )),
                      const SizedBox(
                        width: PsDimens.space8,
                      ),
                      InkWell(
                        child: Text(data.codEmail!,
                            style: Theme.of(context).textTheme.bodyMedium),
                        onTap: () async {
                          if (await canLaunchUrl(Uri.parse(
                              'mailto:teamps.is.cool@gmail.com'))) {
                            await launchUrl(Uri.parse('mailto:teamps.is.cool@gmail.com'));
                          } else {
                            throw 'Could not launchUrl teamps.is.cool@gmail.com';
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

